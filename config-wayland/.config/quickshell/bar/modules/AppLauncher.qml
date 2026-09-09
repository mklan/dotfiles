import QtQuick
import Quickshell.Io
import "../.."

// 󰀻 icon – left-click opens rofi run launcher
Text {
    text: "󰀻"
    height: Theme.barHeight
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.padH
    rightPadding: Theme.padH
    verticalAlignment: Text.AlignVCenter

    Process { id: rofiProc; command: ["sh", "-c", "killall rofi || rofi -show run"]; running: false }
    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: rofiProc.running = true }
}
