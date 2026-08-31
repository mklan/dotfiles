import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../.."
import "../../services"

//  Todo immersive overlay panel – slides in from the top of the bar.
// Shown as a dedicated layer-shell popup window.
PanelWindow {
    id: overlay

    // Layer-shell positioning: top of screen, stretching horizontally
    WlrLayerShell.layer: WlrLayerShell.Layer.Overlay
    WlrLayerShell.anchors.top:   true
    WlrLayerShell.anchors.left:  true
    WlrLayerShell.anchors.right: true
    WlrLayerShell.keyboardInteractivity: WlrLayerShell.KeyboardInteractivity.OnDemand

    // The window is large enough for bar + panel content;
    // the inner rectangle slides downward into view.
    implicitHeight: Theme.barHeight + panel.implicitHeight
    color: "transparent"

    // Dismiss on Escape
    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        onActivated: overlay.close()
    }

    function open() {
        slideAnim.to = Theme.barHeight
        slideAnim.start()
    }

    function close() {
        slideAnim.to = -panel.implicitHeight
        slideAnim.start()
        closeTimer.restart()
    }

    Timer {
        id: closeTimer
        interval: 220
        onTriggered: overlay.visible = false
    }

    // Panel slides in from above
    Rectangle {
        id: panel
        width: parent.width
        implicitHeight: column.implicitHeight + 24
        // Start hidden above the bar
        y: -implicitHeight
        color: Theme.background
        border.color: Theme.disabled
        border.width: 1

        NumberAnimation {
            id: slideAnim
            target: panel
            property: "y"
            duration: 180
            easing.type: Easing.OutCubic
        }

        Column {
            id: column
            anchors {
                top: parent.top; left: parent.left; right: parent.right
                margins: 12
            }
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

                        // Priority badge
                        Text {
                            visible: modelData.priority !== ""
                            text: "(" + modelData.priority + ")"
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            color: {
                                switch (modelData.priority) {
                                    case "A": return Theme.warning
                                    case "B": return "#d8c57c"    // yellow
                                    case "C": return Theme.active
                                    default:  return Theme.foreground
                                }
                            }
                        }

                        // Todo text
                        Text {
                            Layout.fillWidth: true
                            text: modelData.text
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                            elide: Text.ElideRight

                            HoverHandler {
                                id: rowHover
                                cursorShape: Qt.PointingHandCursor
                            }
                        }

                        // Done checkmark hint on hover
                        Text {
                            visible: rowHover.hovered
                            text: "✓"
                            color: Theme.active
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize
                        }
                    }

                    // Separator line
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

                    Text {
                        text: "+"
                        color: Theme.active
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                    }

                    TextField {
                        id: addField
                        Layout.fillWidth: true
                        placeholderText: "Add todo…"
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize
                        color: Theme.foreground
                        placeholderTextColor: Theme.disabled
                        background: Rectangle {
                            color: "transparent"
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

    // Click-outside area (below panel) to dismiss
    MouseArea {
        anchors {
            top: panel.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        onClicked: overlay.close()
    }
}

