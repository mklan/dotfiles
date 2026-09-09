import QtQuick
import Quickshell.Io
import "../.."

// Power menu button
Text {
    text: "\uF011"
    height: Theme.barHeight
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.padH
    rightPadding: Theme.padH
    verticalAlignment: Text.AlignVCenter

    Process { id: powerMenuProc; command: ["power-menu"]; running: false }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: powerMenuProc.running = true
    }
}
