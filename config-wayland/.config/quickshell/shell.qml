import QtQuick
import Quickshell
import "./bar"

// Root shell entry point.
// Quickshell loads this file and expects a ShellRoot as the root object.
// Variants spawns one Bar (PanelWindow) per connected screen.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Bar {
            required property var modelData
            screen: modelData
        }
    }
}
