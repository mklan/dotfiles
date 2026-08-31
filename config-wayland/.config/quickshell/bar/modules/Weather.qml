import QtQuick
import "../.."
import "../../services"

// Weather widget – polls WeatherService singleton
Text {
    text: WeatherService.text
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.padH
    rightPadding: Theme.padH
    verticalAlignment: Text.AlignVCenter

    ToolTip.visible: hoverHandler.hovered
    ToolTip.text: WeatherService.tooltip
    ToolTip.delay: 300

    HoverHandler { id: hoverHandler }
}
