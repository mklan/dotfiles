import QtQuick
import "../.."

// Clock: HH:MM center, tooltip shows date, click toggles full format
Text {
    id: root

    property bool expanded: false

    text: expanded
        ? Qt.formatDateTime(now, "   ddd HH:mm:ss dd.MM.yy")
        : Qt.formatDateTime(now, "HH:mm")

    property var now: new Date()

    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.padH
    rightPadding: Theme.padH
    verticalAlignment: Text.AlignVCenter

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }

    ToolTip.visible: hoverHandler.hovered
    ToolTip.text: Qt.formatDateTime(root.now, "dd.MM.yy")
    ToolTip.delay: 300

    HoverHandler { id: hoverHandler }
}
