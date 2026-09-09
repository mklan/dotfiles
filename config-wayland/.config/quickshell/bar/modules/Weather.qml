import QtQuick
import QtQuick.Controls
import "../.."
import "../../services"

// Weather widget – polls WeatherService singleton
Text {
    id: root
    text: WeatherService.text
    height: Theme.barHeight
    color: Theme.foreground
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    leftPadding: Theme.padH
    rightPadding: Theme.padH
    verticalAlignment: Text.AlignVCenter

}
