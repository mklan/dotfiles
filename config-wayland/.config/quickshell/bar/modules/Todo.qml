import QtQuick
import QtQuick.Controls
import "../overlays"
import "../.."
import "../../services"

// Todo bar chip – shows count, opens floating overlay on click
Item {
    id: root
    implicitWidth: label.implicitWidth + Theme.padH * 2
    implicitHeight: Theme.barHeight

    property var _overlay: null

    function ensureOverlay() {
        if (!_overlay) _overlay = overlayComp.createObject(null)
        return _overlay
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: "\uF046 " + TodoService.count
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            const ov = root.ensureOverlay()
            if (ov.visible) {
                ov.close()
            } else {
                ov.visible = true
                ov.open()
            }
        }
    }

    Component {
        id: overlayComp
        TodoOverlay {}
    }
}
