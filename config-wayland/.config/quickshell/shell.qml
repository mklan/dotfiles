import QtQuick
import Quickshell
import "./bar"

// Root shell entry point.
// Quickshell loads this file and expects a ShellRoot as the root object.
// Variants spawns one instance of the delegate per connected screen,
// providing the top bar and the bottom media bar on each screen.
ShellRoot {
    Variants {
        model: Quickshell.screens

        Item {
            id: screenVariant

            required property var modelData

            Bar { screen: screenVariant.modelData }
            MediaBar { screen: screenVariant.modelData }
        }
    }
}
