pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Kestrel compositor helper for the few things Quickshell's generic
// WindowManager (ext-workspace) does not expose: the monitor list, the
// focused monitor, and a raw mmsg dispatch. Workspaces and tags come from
// Quickshell.WindowManager instead.
QtObject {
  id: root

  // All monitors, as reported by mmsg. Each entry has at least:
  // name, active, width, height, scale, x, y, tag_num, active_tags, tags.
  property var monitors: []
  // The focused monitor (mmsg marks it active: true).
  property var focusedMonitor: null

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
    } catch (e) {
      // mmsg missing or Mango not running; keep the previous values.
    }
  }

  // Run mmsg dispatch <fn> [args...]. fn may contain commas, e.g. resizewin,100,0.
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
