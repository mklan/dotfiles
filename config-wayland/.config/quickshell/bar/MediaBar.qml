import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import ".."

// Bottom media bar – appears only while an MPRIS player (browser, mpv, vlc,
// spotify, ...) is active, shows the track title and transport controls.
// Full-width, same height as the top bar; exclusive zone reserves the strip
// so Hyprland windows never overlap it. Fullscreen windows cover it
// (WlrLayer.Bottom), which is the desired behaviour for video.
PanelWindow {
    id: mediaBar

    WlrLayershell.layer:          isShrunk ? WlrLayer.Overlay : WlrLayer.Bottom
    WlrLayershell.anchors.bottom: true
    WlrLayershell.anchors.left:   !isShrunk
    WlrLayershell.anchors.right:  true
    WlrLayershell.exclusiveZone:  isShrunk ? 0 : Theme.barHeight
    WlrLayershell.keyboardFocus:  WlrKeyboardFocus.None

    // Full-width when expanded; just big enough for the icon when collapsed.
    // The large fallback is overridden by left+right anchors when expanded.
    readonly property int collapsedWidth: Theme.fontSize * 2 + Theme.padH * 2
    width: isShrunk ? collapsedWidth : 9999
    implicitHeight: Theme.barHeight
    color: Theme.background

    // Pick the player to control: any actively playing player wins,
    // otherwise the first paused player. Null -> nothing to show.
    readonly property var activePlayer: {
        const players = Mpris.players.values
        var paused = null
        for (var i = 0; i < players.length; i++) {
            const p = players[i]
            if (p.isPlaying) return p
            if (paused === null && p.playbackState === MprisPlaybackState.Paused)
                paused = p
        }
        return paused
    }

    // Collapse state machine.
    // "collapsing" – animation plays, window stays full-width.
    // "collapsed"  – window shrinks to icon, switches to Overlay.
    // "expanding"  – window grows back to full-width, animation plays.
    // "expanded"   – normal bar.
    property string collapseState: "expanded"
    property bool isShrunk:  collapseState === "collapsed" || collapseState === "expanding"

    // Reset when a new player appears so the bar always starts expanded.
    onActivePlayerChanged: {
        collapseState = "expanded"
        slideAnim.stop()
        barContent.x = 0
    }

    function collapse() {
        slideExpandAnim.stop()
        collapseState = "collapsing"
        slideAnim.target    = barContent
        slideAnim.property  = "x"
        slideAnim.from      = 0
        slideAnim.to        = mediaBar.width
        slideAnim.duration  = 250
        slideAnim.easing.type = Easing.InOutQuad
        slideAnim.restart()
        slideAnim.finished.connect(function finish() {
            slideAnim.finished.disconnect(finish)
            if (collapseState === "collapsing")
                collapseState = "collapsed"
        })
    }

    function expand() {
        collapseState = "expanding"
        // Start from right edge of small window, animate to 0.
        barContent.x = mediaBar.collapsedWidth
        slideExpandAnim.restart()
        slideExpandAnim.finished.connect(function finish() {
            slideExpandAnim.finished.disconnect(finish)
            if (collapseState === "expanding")
                collapseState = "expanded"
        })
    }

    NumberAnimation { id: slideAnim }   // collapse
    NumberAnimation {
        id: slideExpandAnim
        target: barContent
        property: "x"
        to: 0
        duration: 250
        easing.type: Easing.InOutQuad
    }

    // Hidden when no player is active; stays visible while paused so playback
    // can be resumed, disappears when the player stops/quits (track ended).
    visible: activePlayer !== null

    // ── Bar content (slides in/out) ─────────────────────────────────────────
    Item {
        id: barContent
        width: parent.width
        height: parent.height
        clip: true

        Row {
            anchors.centerIn: parent
            spacing: Theme.moduleSpacing

        // ── transport controls ──────────────────────────────────────────────
        ControlButton {
            glyph: "󰒮" // skip_previous
            active: mediaBar.activePlayer !== null && mediaBar.activePlayer.canGoPrevious
            onClicked: if (mediaBar.activePlayer) mediaBar.activePlayer.previous()
        }
        ControlButton {
            glyph: mediaBar.activePlayer !== null && mediaBar.activePlayer.isPlaying
                   ? "󰏤" /* pause */ : "󰐊" /* play */
            active: mediaBar.activePlayer !== null
                    && (mediaBar.activePlayer.canPlay
                        || mediaBar.activePlayer.canPause
                        || mediaBar.activePlayer.canTogglePlaying)
            onClicked: if (mediaBar.activePlayer) mediaBar.activePlayer.togglePlaying()
        }
        ControlButton {
            glyph: "󰒭" // skip_next
            active: mediaBar.activePlayer !== null && mediaBar.activePlayer.canGoNext
            onClicked: if (mediaBar.activePlayer) mediaBar.activePlayer.next()
        }

        // ── separator ────────────────────────────────────────────────────────
        Text {
            text: "│"
            height: Theme.barHeight
            verticalAlignment: Text.AlignVCenter
            color: Theme.disabled
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
        }

        // ── track title ──────────────────────────────────────────────────────
        Text {
            height: Theme.barHeight
            verticalAlignment: Text.AlignVCenter
            text: {
                const p = mediaBar.activePlayer
                if (p === null) return ""
                const t = p.trackTitle.trim()
                const a = p.trackArtist.trim()
                if (t === "") return a
                if (a === "") return t
                return t + "  —  " + a
            }
            width: Math.min(implicitWidth, mediaBar.width * 0.45)
            elide: Text.ElideRight
            color: Theme.foreground
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize
            leftPadding: Theme.padH
            rightPadding: Theme.padH
        }

        // ── collapse button ──────────────────────────────────────────────────
        Text {
            height: Theme.barHeight
            verticalAlignment: Text.AlignVCenter
            text: ">"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 2
            color: collapseHover.hovered ? Qt.lighter(Theme.foreground, 1.3)
                                         : Theme.foreground
            HoverHandler { id: collapseHover }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: mediaBar.collapse()
            }
        }
        } // Row
    } // barContent

    // ── Expand icon (visible when collapsed and during expand animation) ────
    // Stays visible while expanding so there's no blank flash; the bar content
    // slides in underneath it (declared earlier → lower z-order).
    Rectangle {
        anchors.fill: parent
        color: Theme.background
        visible: mediaBar.isShrunk

        Text {
            id: expandIcon
            anchors.centerIn: parent
            text: "󰎈"
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontSize + 2
            color: expandHover.hovered ? Qt.lighter(Theme.foreground, 1.3)
                                       : Theme.foreground
            HoverHandler { id: expandHover }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: mediaBar.expand()
        }
    }

    // Icon button – Nerd Font glyph, dims when the action is unavailable.
    component ControlButton: Text {
        id: control

        property bool active: true
        property string glyph: ""
        signal clicked()

        text: glyph
        height: Theme.barHeight
        verticalAlignment: Text.AlignVCenter
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize + 3 // NF glyphs have internal padding
        color: hovered ? Qt.lighter(Theme.foreground, 1.3)
                       : (active ? Theme.foreground : Theme.disabled)

        HoverHandler { id: btnHover }
        readonly property bool hovered: btnHover.hovered && active

        MouseArea {
            anchors.fill: parent
            cursorShape: control.active ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: if (control.active) control.clicked()
        }
    }
}
