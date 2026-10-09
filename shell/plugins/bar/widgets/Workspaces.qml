import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "kestrel.workspaces"

  function tagIds() {
    var ids = []
    var count = Math.max(5, Math.min(9, Mango.tagNum))
    for (var i = 1; i <= count; i++) ids.push(i)

    return ids
  }

  function focusTag(id) {
    Mango.focusTag(id)
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.tagIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.tagIds()

      WidgetButton {
        required property int modelData

        readonly property bool occupied: Mango.tagIsOccupied(modelData)
        readonly property bool focused: Mango.tagIsActive(modelData)

        bar: root.bar
        text: focused ? "\uDB85\uDCFB" : String(modelData)
        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical ? root.barSize : Style.space(20)
        fixedHeight: root.barSize
        onPressed: function() { root.focusTag(modelData) }
      }
    }
  }
}
