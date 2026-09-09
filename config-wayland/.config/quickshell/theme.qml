pragma Singleton
import QtQuick

// Color palette matching waybar style.css
QtObject {
    // Base palette
    readonly property color background: "#000000"
    readonly property color foreground: "#d8caac"
    readonly property color disabled:   "#868d80"
    readonly property color active:     "#87c095"   // green – active workspace
    readonly property color charging:   "#c2e69c"   // pale green – battery charging (brighter)
    readonly property color vpn:        "#89beba"   // teal  – vpn/wifi-vpn-up
    readonly property color warning:    "#ff9c9e"   // red   – wifi-up signal pulse, battery warning
    readonly property color warningOrange: "#d9bb80" // amber/orange – cpu temp ≥ 55°C (everforest color11)
    readonly property color color8:     "#868d80"

    // SauceCodePro NF Mono = Source Code Pro patched with Nerd Font icons
    readonly property string fontFamily: "SauceCodePro Nerd Font Mono"
    readonly property int    fontSize:   11

    // Bar geometry
    readonly property int barHeight:  22
    readonly property int padH:       3   // horizontal padding per widget
    readonly property int moduleSpacing: 7 // extra gap between right-section modules (~= 2 spaces like CPU↔mem)
}
