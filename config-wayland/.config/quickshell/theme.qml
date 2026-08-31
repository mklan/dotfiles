pragma Singleton
import QtQuick

// Color palette matching waybar style.css
QtObject {
    // Base palette
    readonly property color background: "#000000"
    readonly property color foreground: "#d8caac"
    readonly property color disabled:   "#868d80"
    readonly property color active:     "#87c095"   // green – active workspace, battery charging
    readonly property color vpn:        "#89beba"   // teal  – vpn/wifi-vpn-up
    readonly property color warning:    "#ff9c9e"   // red   – wifi-up signal pulse, battery warning
    readonly property color color8:     "#868d80"

    // Font
    readonly property string fontFamily: "Source Code Pro Medium"
    readonly property int    fontSize:   11

    // Bar geometry
    readonly property int barHeight:  22
    readonly property int padH:       3   // horizontal padding per widget
}
