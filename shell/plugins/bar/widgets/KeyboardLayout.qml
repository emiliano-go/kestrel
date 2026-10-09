import QtQuick
import Quickshell
import Quickshell.Io
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "kestrel.keyboard-layout"

  property string layoutFull: ""
  property bool multipleLayouts: true

  function refresh() {
    if (!queryProc.running) queryProc.running = true
  }

  // Mango exposes the current layout name. Toggle through the configured
  // layouts with the switch_keyboard_layout dispatcher.
  function cycleLayout() {
    Mango.dispatch("switch_keyboard_layout")
    refreshTimer.restart()
  }

  Component.onCompleted: refresh()

  Process {
    id: queryProc
    command: ["mmsg", "get", "keyboardlayout"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          root.layoutFull = String(JSON.parse(text || "{}").layout || "")
        } catch (e) {
          root.layoutFull = ""
        }
      }
    }
  }

  Timer {
    id: refreshTimer
    interval: 600
    onTriggered: root.refresh()
  }

  visible: layoutFull !== "" && multipleLayouts
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.layoutFull
    fontSize: Style.font.caption
    horizontalMargin: 6
    tooltipText: root.layoutFull
    onPressed: function() { root.cycleLayout() }
  }
}
