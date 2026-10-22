import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."
import "./modules"

// Main bar – full-width, height 22, anchored to top of a monitor.
// Instantiated once per screen by shell.qml via Variants; the instantiator
// passes the screen to anchor to.
PanelWindow {
    id: barWindow

    // Layer-shell: top of screen, fill width, exclusive zone so windows don't go under bar
    WlrLayershell.layer:        WlrLayer.Top
    WlrLayershell.anchors.top:  true
    WlrLayershell.anchors.left: true
    WlrLayershell.anchors.right: true
    WlrLayershell.exclusiveZone: Theme.barHeight
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    implicitHeight: Theme.barHeight
    color: Theme.background

    Item {
        anchors.fill: parent

        // ── Left ──────────────────────────────────────────────
        Row {
            id: leftSection
            anchors { left: parent.left; verticalCenter: parent.verticalCenter }
            spacing: 0
            AppLauncher {}
            Workspaces {}
        }

        // ── Center – truly centered regardless of left/right widths ───────────
        // Explicit layout, NOT a Row: the Row's positioner re-lays out one frame
        // behind the clock's animated width, so HH:mm wobbled a few px to the
        // right while the detail slide-outs animate. Here the clock module's
        // center is pinned to the old Row's resting position (bar center minus
        // half the weather width) via a direct x binding that compensates the
        // width change exactly: HH:mm never moves, rest or expanded. Weather
        // just follows the clock's right edge and gets pushed out of the way.
        Item {
            id: centerSection
            anchors.fill: parent

            Clock {
                id: centerClock
                x: centerSection.width / 2 - width / 2 - centerWeather.width / 2
                anchors.verticalCenter: parent.verticalCenter
            }
            Weather {
                id: centerWeather
                x: centerClock.x + centerClock.width
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ── Right ─────────────────────────────────────────────
        Row {
            id: rightSection
            anchors { right: parent.right; verticalCenter: parent.verticalCenter }
            spacing: Theme.moduleSpacing
            Todo {}
            Hardware {}
            Audio {}
            Backlight {}
            Row {
                id: connectivityGroup
                spacing: 0   // BT + wifi read as one connectivity group
                Bluetooth {}
                Network {}
            }
            Battery {}
            PowerMenu {}
        }
    }
}
