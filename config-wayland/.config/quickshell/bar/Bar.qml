import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."
import "./modules"

// Main bar – full-width, height 22, anchored to top of a monitor.
// Instantiated once per screen by shell.qml via Variants.
PanelWindow {
    id: barWindow

    // Layer-shell: top of screen, fill width, exclusive zone so windows don't go under bar
    WlrLayerShell.layer:                 WlrLayerShell.Layer.Top
    WlrLayerShell.anchors.top:           true
    WlrLayerShell.anchors.left:          true
    WlrLayerShell.anchors.right:         true
    WlrLayerShell.exclusiveZone:         Theme.barHeight
    WlrLayerShell.keyboardInteractivity: WlrLayerShell.KeyboardInteractivity.None

    implicitHeight: Theme.barHeight
    color: Theme.background

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin:  0
        anchors.rightMargin: 0
        spacing: 0

        // ── Left ──────────────────────────────────────────────
        RowLayout {
            spacing: 0
            AppLauncher {}
            Workspaces {}
        }

        // ── Spacer ────────────────────────────────────────────
        Item { Layout.fillWidth: true }

        // ── Center ────────────────────────────────────────────
        RowLayout {
            spacing: 0
            Clock {}
            Weather {}
        }

        // ── Spacer ────────────────────────────────────────────
        Item { Layout.fillWidth: true }

        // ── Right ─────────────────────────────────────────────
        RowLayout {
            spacing: 0
            Todo {}
            Hardware {}
            Audio {}
            Backlight {}
            Bluetooth {}
            Network {}
            Battery {}
            PowerMenu {}
        }
    }
}
