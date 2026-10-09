import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.WindowManager
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "kestrel.workspaces"

  // Mango tags are per monitor and arrive over ext-workspace-v1, which
  // Quickshell's generic WindowManager exposes as windowsets projected onto
  // each screen. The widget renders the projection for its own bar's screen.
  readonly property var screen: root.bar ? root.bar.screen : null
  readonly property var projection: screen ? WindowManager.screenProjection(screen) : null
  readonly property var tags: projection ? projection.windowsets : []

  function focusTag(tag) {
    if (tag && tag.canActivate) tag.activate()
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : Math.max(1, root.tags.length)
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.tags

      WidgetButton {
        required property var modelData

        readonly property bool focused: modelData.active === true
        readonly property bool urgent: modelData.urgent === true

        bar: root.bar
        text: focused ? "\uDB85\uDCFB" : String(modelData.name || "")
        opacity: focused || urgent ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusTag(modelData) }
      }
    }
  }
}
