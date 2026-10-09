pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Kestrel compositor adapter.
//
// The shell was written against Quickshell's Hyprland module. Kestrel runs on
// Mango, whose IPC is `mmsg`. This singleton exposes the small surface the
// shell needs — the monitor list, the focused monitor, the focused monitor's
// tags, the keyboard layout, and a dispatch helper — by polling
// `mmsg get all-monitors` and shelling out to `mmsg dispatch`.
QtObject {
  id: root

  // All monitors, as reported by mmsg. Each entry has at least:
  // name, active, width, height, scale, x, y, tag_num, active_tags, tags,
  // keyboardlayout, keymode.
  property var monitors: []
  // The focused monitor (mmsg marks it `active: true`).
  property var focusedMonitor: null
  // Tags of the focused monitor: [{index, is_active, is_urgent, client_count, layout}]
  property var tags: []
  property int tagNum: 9
  property string keyboardLayout: ""
  property string keymode: ""

  // Poll cadence. Mango has no push channel wired here yet, so poll. A watch
  // stream on `mmsg watch all-monitors` is the follow-up.
  property int pollInterval: 400

  function refreshMonitors() {
    if (!poll.running) poll.running = true
  }

  function _apply(text) {
    try {
      var data = JSON.parse(String(text))
      var list = data.monitors || []
      var focused = null
      for (var i = 0; i < list.length; i++) {
        if (list[i].active === true) focused = list[i]
      }
      root.monitors = list
      root.focusedMonitor = focused
      if (focused) {
        root.tags = focused.tags || []
        root.tagNum = focused.tag_num || 9
        root.keyboardLayout = focused.keyboardlayout || ""
        root.keymode = focused.keymode || ""
      }
    } catch (e) {
      // mmsg missing or Mango not running — keep the previous values.
    }
  }

  // True when the tag is currently the focused monitor's active tag.
  function tagIsActive(index) {
    for (var i = 0; i < root.tags.length; i++) {
      if (root.tags[i].index === index) return root.tags[i].is_active === true
    }
    return false
  }

  function tagIsOccupied(index) {
    for (var i = 0; i < root.tags.length; i++) {
      if (root.tags[i].index === index) return (root.tags[i].client_count || 0) > 0
    }
    return false
  }

  function tagIsUrgent(index) {
    for (var i = 0; i < root.tags.length; i++) {
      if (root.tags[i].index === index) return root.tags[i].is_urgent === true
    }
    return false
  }

  // Focus a tag on the focused monitor.
  function focusTag(index) {
    dispatch("view," + String(index))
  }

  // Run `mmsg dispatch <fn> [args...]`. fn may itself contain commas, e.g.
  // `resizewin,100,0`. Extra arguments are appended.
  function dispatch(fn) {
    var args = ["mmsg", "dispatch", String(fn)]
    for (var i = 1; i < arguments.length; i++) args.push(String(arguments[i]))
    Quickshell.execDetached(args)
  }

  property Process poll: Process {
    id: poll
    command: ["mmsg", "get", "all-monitors"]
    stdout: StdioCollector {
      id: pollOut
      waitForEnd: true
      onStreamFinished: root._apply(pollOut.text)
    }
  }

  property Timer tick: Timer {
    interval: root.pollInterval
    running: true
    repeat: true
    onTriggered: root.refreshMonitors()
  }
}
