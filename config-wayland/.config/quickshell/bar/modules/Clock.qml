import QtQuick
import "../.."

// Clock: HH:MM center, always in place. Hover slides the weekday ("ddd") out to
// the LEFT and seconds + date (":ss dd.MM.yy") out to the RIGHT. Both sides
// share the same animation, so the centered bar row grows symmetrically and
// HH:mm never moves on screen.
//
// Clicking the clock toggles a pinned state: the details slide out and STAY
// out (until clicked again). Hover still works as before when not pinned.
//
// NOTE: horizontal positions use direct x bindings, NOT anchors – Item anchors
// snap to whole pixels, which made HH:mm jump ~1px when the module width
// changed between collapsed/expanded. Vertical anchors are fine (no change).
Item {
    id: root

    property var now: new Date()
    property int detailGap: 6
    property bool pinned: false
    readonly property bool expanded: pinned || clockHover.hovered

    height: Theme.barHeight
    // Reserve symmetric space for the WIDER of the two slide-outs: the module
    // then always fully contains the seconds/date detail (which is wider than
    // the weekday), pushing the following module (weather) right instead of
    // letting the detail overlap it. HH:mm stays centered in the module, and
    // the bar's center row is centered, so HH:mm never moves on screen.
    width: timeText.width + 2 * Math.max(leftHolder.width, rightHolder.width)
           + Theme.padH * 2 + detailGap * 2

    HoverHandler { id: clockHover }
    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.pinned = !root.pinned
    }

    // Main value – HH:mm, stays in place
    Text {
        id: timeText
        anchors.verticalCenter: parent.verticalCenter
        x: (parent.width - width) / 2
        text: Qt.formatDateTime(now, "HH:mm")
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    // Slide-out weekday – left of the time
    Item {
        id: leftHolder
        anchors.verticalCenter: parent.verticalCenter
        x: timeText.x - root.detailGap - width
        height: timeText.height
        width: root.expanded ? leftDetail.implicitWidth : 0
        clip: true
        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Text {
            id: leftDetail
            anchors.verticalCenter: parent.verticalCenter
            x: parent.width - width
            text: Qt.formatDateTime(now, "ddd")
            opacity: leftHolder.width > 0
                ? leftHolder.width / Math.max(implicitWidth, 1) : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
            color: root.pinned ? Theme.foreground : Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    // Slide-out seconds + date – right of the time, glued to the minutes
    // (no gap, so hovering reads as HH:mm:ss)
    Item {
        id: rightHolder
        anchors.verticalCenter: parent.verticalCenter
        x: timeText.x + timeText.width
        height: timeText.height
        width: root.expanded ? rightDetail.implicitWidth : 0
        clip: true
        Behavior on width { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        Text {
            id: rightDetail
            anchors.verticalCenter: parent.verticalCenter
            x: 0
            text: Qt.formatDateTime(now, ":ss dd.MM.yy")
            opacity: rightHolder.width > 0
                ? rightHolder.width / Math.max(implicitWidth, 1) : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
            color: root.pinned ? Theme.foreground : Theme.muted
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.now = new Date()
    }
}
