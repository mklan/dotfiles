pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Color palette driven by pywal (~/.cache/wal/colors.json) – the same source
// as waybar's style.css, so the bar follows scripts/switch-theme.sh
// (everforest_oled black / everforest_light cream). Falls back to the
// everforest_oled palette if the file is missing. Values hot-reload on
// theme switch (FileView watchChanges).
//
// Geometry/fonts stay hand-tuned below; colors are generated.
QtObject {
    id: root

    // SauceCodePro NF Mono = Source Code Pro patched with Nerd Font icons
    readonly property string fontFamily: "SauceCodePro Nerd Font Mono"
    readonly property int    fontSize:   11

    // Bar geometry
    readonly property int barHeight:  22
    readonly property int padH:       3   // horizontal padding per widget
    readonly property int moduleSpacing: 7 // extra gap between right-section modules (~= 2 spaces like CPU↔mem)

    // pywal palette (semantic mapping onto the wal indices)
    property FileView walFile: FileView {
        path: Quickshell.env("HOME") + "/.cache/wal/colors.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: wal
            property JsonObject special: JsonObject {
                property string background: ""
            }
            property JsonObject colors: JsonObject {
                property string color1: ""
                property string color2: ""
                property string color8: ""
                property string color11: ""
                property string color12: ""
                property string color14: ""
                property string color15: ""
            }
        }
    }

    // Base palette
    readonly property color background: wal.special.background || "#000000"
    readonly property color foreground: wal.colors.color15 || "#d8caac"
    readonly property color disabled:   wal.colors.color8  || "#868d80"
    readonly property color active:     wal.colors.color14 || "#87c095"   // green – active workspace (focused monitor)
    readonly property color visibleWs:  wal.colors.color12 || "#89beba"   // teal  – workspace visible on another monitor
    readonly property color charging:   wal.colors.color2  || "#c2e69c"   // pale green – battery charging (brighter)
    readonly property color vpn:        wal.colors.color12 || "#89beba"   // teal  – vpn/wifi-vpn-up
    readonly property color warning:    wal.colors.color1  || "#ff9c9e"   // red   – wifi-up signal pulse, battery warning
    readonly property color warningOrange: wal.colors.color11 || "#d9bb80" // amber/orange – cpu temp ≥ 55°C (everforest color11)
    readonly property color color8:     wal.colors.color8  || "#868d80"

    // Desktop background – visible in the window gaps (deployed by
    // DesktopBackground.qml at the layer Background level). In the light
    // theme it sits a bit lighter than the bar/window background so the
    // gaps read as a subtle matte. Pitch-black palettes (everforest_oled)
    // MUST stay #000000 – no lifting, or the "black" reads dark grey.
    readonly property color desktopBg: background.hslLightness < 0.02
        ? background
        : Qt.hsla(
            background.hslHue,
            background.hslSaturation,
            Math.min(1, background.hslLightness + 0.04),
            1)
}
