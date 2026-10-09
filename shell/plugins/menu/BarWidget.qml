import QtQuick
import qs.Ui

BarWidget {
  id: root
  moduleName: "kestrel.menu"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\ue900"
    fontFamily: "kestrel"
    centerFigures: false
    horizontalMargin: 7.5
    onPressed: function(button) {
      if (!root.bar) return
      if (button === Qt.RightButton) root.bar.run("xdg-terminal-exec")
      else root.bar.run("kestrel-shell shell toggle kestrel.menu '{\"menu\":\"root\"}'")
    }
  }
}
