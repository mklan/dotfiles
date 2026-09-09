import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../.."
import "../../services"

// Todo overlay panel – slides in from below the bar, floats above content.
// Does NOT overlap the bar (margins.top = barHeight).
PanelWindow {
    id: overlay

    WlrLayershell.layer:        WlrLayer.Overlay
    WlrLayershell.anchors.top:   true
    WlrLayershell.anchors.right: true
    WlrLayershell.margins.top:   Theme.barHeight
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    implicitWidth:  340
    implicitHeight: panel.height
    color: "transparent"

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        onActivated: overlay.close()
    }

    function open() {
        openAnim.to = panel.implicitHeight
        openAnim.start()
    }

    function close() {
        closeAnim.start()
        closeTimer.restart()
    }

    NumberAnimation { id: openAnim;  target: panel; property: "height"; duration: 180; easing.type: Easing.OutCubic }
    NumberAnimation { id: closeAnim; target: panel; property: "height"; to: 0;  duration: 160; easing.type: Easing.InCubic }
    Timer { id: closeTimer; interval: 200; onTriggered: overlay.visible = false }

    Rectangle {
        id: panel
        width: parent.width
        height: 0
        implicitHeight: column.implicitHeight + 24
        clip: true
        color: "#0d0d0d"
        border.color: Theme.disabled
        border.width: 1

        Column {
            id: column
            anchors { top: parent.top; left: parent.left; right: parent.right; margins: 12 }
            spacing: 0

            // Header
            Text {
                text: " TODO  (" + TodoService.count + ")"
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize + 1
                bottomPadding: 8
            }

            // Todo items
            Repeater {
                model: TodoService.items

                delegate: MouseArea {
                    required property var modelData
                    width: column.width
                    implicitHeight: itemRow.implicitHeight + 6

                    onClicked: TodoService.markDone(modelData.num)

                    RowLayout {
                        id: itemRow
                        width: parent.width
                        spacing: 6

                        Text {
                            visible: modelData.priority !== ""
                            text: "(" + modelData.priority + ")"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            color: {
                                switch (modelData.priority) {
                                    case "A": return Theme.warning
                                    case "B": return "#d8c57c"
                                    case "C": return Theme.active
                                    default:  return Theme.foreground
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData.text
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            elide: Text.ElideRight
                            HoverHandler { id: rowHover; cursorShape: Qt.PointingHandCursor }
                        }

                        Text {
                            visible: rowHover.hovered
                            text: "✓"
                            color: Theme.active
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                    }

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: Theme.disabled
                        opacity: 0.3
                    }
                }
            }

            // Add-new input row
            Item {
                width: column.width
                implicitHeight: addRow.implicitHeight + 8

                RowLayout {
                    id: addRow
                    width: parent.width
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 6

                    Text { text: "+"; color: Theme.active; font.family: Theme.fontFamily; font.pixelSize: Theme.fontSize }

                    TextField {
                        id: addField
                        Layout.fillWidth: true
                        placeholderText: "Add todo…"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        color: Theme.foreground
                        placeholderTextColor: Theme.disabled
                        background: Rectangle {
                            color: "#1a1a1a"
                            border.color: Theme.disabled
                            border.width: 1
                        }
                        Keys.onReturnPressed: {
                            if (text.trim().length > 0) {
                                TodoService.addTodo(text)
                                text = ""
                            }
                        }
                    }
                }
            }
        }
    }
}
