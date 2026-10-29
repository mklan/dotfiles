#!/usr/bin/env python3
"""Generate a VSCode color theme from a pywal scheme file.

The output is a full VSCode color-theme JSON (workbench chrome + TextMate
token scopes + semantic tokens) derived entirely from the 16-color pywal
palette, so VSCode matches the rest of the themed desktop (GTK, kitty,
waybar, Firefox, …).

Usage:
    gen-vscode-theme.py <scheme.json> <output-theme.json> <theme-name> <dark|light>

Two themes are generated this way and shipped in a tiny managed extension
(~/.vscode/extensions/wal.wal-palette-*/), see switch-theme.sh:
    Wal OLED   – from colorschemes/dark/everforest_oled.json
    Wal Light  – from colorschemes/light/everforest_light.json

The theme files are deterministic per scheme, so they only change when the
scheme files change – VSCode then needs a restart to re-read them. Flipping
workbench.colorTheme (switch-theme.sh) is live and needs no reload.

Syntax convention (follows the everforest/Blackforest family):
    red     keywords, storage modifiers
    orange  var/switch keywords, HTML tags        (mix of color1 + color3)
    yellow  attributes                            (color3)
    green   operators, functions, escapes          (color2)
    aqua    strings, modules, annotations          (color6)
    blue    types, classes, properties             (color4)
    purple  numbers, booleans, constants, this     (color5)
    grey    comments                              (color8)
"""

import json
import sys


# ── color helpers ────────────────────────────────────────────────────────────


def hex_to_rgb(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))


def rgb_to_hex(rgb):
    return "#{:02x}{:02x}{:02x}".format(*(max(0, min(255, int(round(v)))) for v in rgb))


def mix(a, b, t):
    """Blend color b over color a with opacity t (0 = a, 1 = b)."""
    ra, rb = hex_to_rgb(a), hex_to_rgb(b)
    return rgb_to_hex(tuple(ra[i] * (1 - t) + rb[i] * t for i in range(3)))


def alpha(h, a):
    """Attach an alpha channel (#RRGGBBAA) – VSCode accepts 8-digit hex."""
    return h[:7] + "{:02x}".format(max(0, min(255, int(round(a * 255)))))


class Palette:
    def __init__(self, scheme, mode):
        special = scheme.get("special", {})
        colors = scheme.get("colors", {})
        self.mode = mode
        self.bg = special.get("background", "#000000")
        self.fg = special.get("foreground", "#ffffff")
        self.cursor = special.get("cursor", self.fg)
        self.c = [colors.get("color%d" % i, self.fg) for i in range(16)]

        # everforest role mapping onto the wal palette
        self.red = self.c[1]
        self.green = self.c[2]
        self.yellow = self.c[3]
        self.blue = self.c[4]
        self.purple = self.c[5]
        self.aqua = self.c[6]
        self.grey = self.c[8]
        self.orange = mix(self.red, self.yellow, 0.5)  # no orange slot in wal

        self.on_accent = "#000000"  # best contrast on green/yellow accents

    def raise_(self, t):
        """Surface slightly lifted off the window background."""
        return mix(self.bg, self.fg, t)

    def tint(self, color, t):
        """A wash of `color` over the background."""
        return mix(self.bg, color, t)


def build_theme(scheme, name, mode):
    p = Palette(scheme, mode)
    a = alpha
    bg, fg = p.bg, p.fg
    sel = a(fg, 0.28)              # editor selection
    line_hl = a(fg, 0.055)         # current line
    raise5, raise8 = p.raise_(0.05), p.raise_(0.08)
    raise12, raise15 = p.raise_(0.12), p.raise_(0.15)
    raise20, raise30 = p.raise_(0.20), p.raise_(0.30)

    colors = {
        # ── base ──────────────────────────────────────────────────────────
        "contrastBorder": "#00000000",
        "contrastActiveBorder": "#00000000",
        "focusBorder": a(p.blue, 0.7),
        "foreground": fg,
        "disabledForeground": a(fg, 0.45),
        "descriptionForeground": a(fg, 0.7),
        "errorForeground": p.red,
        "icon.foreground": fg,
        "sash.hoverBorder": a(p.blue, 0.6),
        "window.activeBorder": raise15,
        "window.inactiveBorder": raise12,
        "window.inactiveForeground": a(fg, 0.55),

        "textBlockQuote.background": raise5,
        "textBlockQuote.border": a(p.blue, 0.6),
        "textCodeBlock.background": raise5,
        "textLink.foreground": p.blue,
        "textLink.activeForeground": mix(p.blue, fg, 0.3),
        "textPreformat.foreground": p.yellow,
        "textSeparator.foreground": raise15,

        "toolbar.hoverBackground": a(fg, 0.1),
        "toolbar.activeBackground": a(fg, 0.15),
        "toolbar.hoverOutline": "#00000000",

        # ── widgets ───────────────────────────────────────────────────────
        "button.background": p.green,
        "button.foreground": p.on_accent,
        "button.hoverBackground": mix(p.green, fg, 0.15),
        "button.separator": a(p.on_accent, 0.4),
        "button.secondaryBackground": raise12,
        "button.secondaryForeground": fg,
        "button.secondaryHoverBackground": raise20,

        "checkbox.background": raise8,
        "checkbox.foreground": fg,
        "checkbox.border": raise20,

        "dropdown.background": raise8,
        "dropdown.foreground": fg,
        "dropdown.border": raise20,
        "dropdown.listBackground": raise8,

        "input.background": raise5,
        "input.foreground": fg,
        "input.border": raise20,
        "input.placeholderForeground": a(fg, 0.5),
        "inputOption.activeBackground": a(p.blue, 0.25),
        "inputOption.activeBorder": a(p.blue, 0.8),
        "inputOption.activeForeground": fg,
        "inputOption.hoverBackground": a(fg, 0.1),
        "inputValidation.errorBackground": p.tint(p.red, 0.2),
        "inputValidation.errorBorder": p.red,
        "inputValidation.errorForeground": fg,
        "inputValidation.warningBackground": p.tint(p.yellow, 0.2),
        "inputValidation.warningBorder": p.yellow,
        "inputValidation.warningForeground": fg,
        "inputValidation.infoBackground": p.tint(p.blue, 0.2),
        "inputValidation.infoBorder": p.blue,
        "inputValidation.infoForeground": fg,

        "scrollbar.shadow": "#00000000",
        "scrollbarSlider.background": a(fg, 0.14),
        "scrollbarSlider.hoverBackground": a(fg, 0.24),
        "scrollbarSlider.activeBackground": a(fg, 0.34),

        "badge.background": p.green,
        "badge.foreground": p.on_accent,
        "progressBar.background": p.blue,

        "pickerGroup.border": raise15,
        "pickerGroup.foreground": p.blue,
        "quickInput.background": raise5,
        "quickInput.foreground": fg,
        "quickInputTitle.background": raise8,
        "quickInputList.focusBackground": a(p.green, 0.25),
        "quickInputList.focusForeground": fg,
        "quickInputList.focusIconForeground": fg,

        "keybindingLabel.background": raise12,
        "keybindingLabel.foreground": fg,
        "keybindingLabel.border": raise20,
        "keybindingLabel.bottomBorder": raise30,
        "keybindingLabel.shadow": "#00000000",
        "keybindingTable.headerBackground": raise5,
        "keybindingTable.rowsBackground": p.raise_(0.03),

        "menu.background": raise8,
        "menu.foreground": fg,
        "menu.selectionBackground": a(p.green, 0.25),
        "menu.selectionForeground": fg,
        "menu.selectionBorder": "#00000000",
        "menu.separatorBackground": raise15,
        "menu.border": raise15,
        "menuButton.background": raise12,
        "menuButton.foreground": fg,
        "menuButton.hoverBackground": raise20,
        "menubar.selectionBackground": a(fg, 0.12),
        "menubar.selectionForeground": fg,

        # ── notifications / banner ────────────────────────────────────────
        "notifications.background": raise8,
        "notifications.foreground": fg,
        "notifications.border": raise15,
        "notificationCenter.border": raise15,
        "notificationCenterHeader.background": raise8,
        "notificationCenterHeader.foreground": fg,
        "notificationToast.border": raise15,
        "notificationsErrorIcon.foreground": p.red,
        "notificationsWarningIcon.foreground": p.yellow,
        "notificationsInfoIcon.foreground": p.blue,

        "banner.background": a(p.blue, 0.2),
        "banner.foreground": fg,
        "banner.link": p.blue,
        "banner.linkHover": mix(p.blue, fg, 0.3),

        # ── lists & trees ─────────────────────────────────────────────────
        "list.activeSelectionBackground": a(p.green, 0.28),
        "list.activeSelectionForeground": fg,
        "list.activeSelectionIconForeground": fg,
        "list.inactiveSelectionBackground": a(fg, 0.12),
        "list.inactiveSelectionForeground": fg,
        "list.inactiveSelectionIconForeground": a(fg, 0.7),
        "list.hoverBackground": a(fg, 0.08),
        "list.hoverForeground": fg,
        "list.dropBackground": a(p.blue, 0.15),
        "list.focusBackground": a(p.green, 0.22),
        "list.focusForeground": fg,
        "list.focusHighlightForeground": p.blue,
        "list.highlightForeground": p.green,
        "list.focusOutline": "#00000000",
        "list.invalidItemForeground": p.red,
        "list.errorForeground": p.red,
        "list.warningForeground": p.yellow,
        "list.filterMatchBackground": a(p.yellow, 0.25),
        "list.filterMatchBorder": a(p.yellow, 0.7),
        "list.deemphasizedForeground": a(fg, 0.5),
        "list.dropBetweenBorder": raise30,
        "tree.indentGuidesStroke": a(fg, 0.15),
        "tree.tableColumnsBorder": raise15,
        "tree.tableOddRowsBackground": a(fg, 0.03),

        # ── activity bar / side bar / title bar / status bar ─────────────
        "activityBar.background": bg,
        "activityBar.foreground": fg,
        "activityBar.inactiveForeground": a(fg, 0.5),
        "activityBar.border": raise12,
        "activityBar.activeBorder": p.green,
        "activityBar.activeBackground": a(fg, 0.05),
        "activityBar.activeFocusBorder": p.blue,
        "activityBar.dropBorder": p.blue,
        "activityBarBadge.background": p.green,
        "activityBarBadge.foreground": p.on_accent,
        "activityBarTop.foreground": fg,
        "activityBarTop.activeBorder": p.green,
        "activityBarTop.inactiveForeground": a(fg, 0.5),
        "activityBarTop.dropBorder": p.blue,

        "sideBar.background": bg,
        "sideBar.foreground": fg,
        "sideBar.border": raise12,
        "sideBar.dropBackground": a(p.blue, 0.15),
        "sideBarTitle.foreground": fg,
        "sideBarSectionHeader.background": bg,
        "sideBarSectionHeader.foreground": a(fg, 0.8),
        "sideBarSectionHeader.border": raise12,

        "titleBar.activeBackground": bg,
        "titleBar.activeForeground": fg,
        "titleBar.inactiveBackground": bg,
        "titleBar.inactiveForeground": a(fg, 0.55),
        "titleBar.border": raise12,

        "statusBar.background": bg,
        "statusBar.foreground": fg,
        "statusBar.border": raise12,
        "statusBar.debuggingBackground": p.tint(p.yellow, 0.35),
        "statusBar.debuggingForeground": p.on_accent if mode == "light" else fg,
        "statusBar.debuggingBorder": raise12,
        "statusBar.noFolderBackground": bg,
        "statusBar.noFolderForeground": fg,
        "statusBar.noFolderBorder": raise12,
        "statusBar.item.activeBackground": a(fg, 0.12),
        "statusBar.item.hoverBackground": a(fg, 0.08),
        "statusBar.item.prominentBackground": a(fg, 0.12),
        "statusBar.item.prominentForeground": fg,
        "statusBar.item.prominentHoverBackground": a(fg, 0.18),
        "statusBar.errorBackground": p.red,
        "statusBar.errorForeground": p.on_accent,
        "statusBar.warningBackground": p.yellow,
        "statusBar.warningForeground": p.on_accent,
        "statusBar.remoteBackground": p.blue,
        "statusBar.remoteForeground": p.on_accent,
        "statusBar.offlineBackground": p.red,
        "statusBar.offlineForeground": p.on_accent,

        # ── tabs & editor groups ──────────────────────────────────────────
        "editorGroup.border": raise12,
        "editorGroup.dropBackground": a(p.blue, 0.15),
        "editorGroup.emptyBackground": bg,
        "editorGroup.emptyOtherWindowBackground": bg,
        "editorGroup.focusedEmptyBorder": p.blue,
        "editorGroupHeader.tabsBackground": bg,
        "editorGroupHeader.tabsBorder": raise12,
        "editorGroupHeader.noTabsBackground": bg,
        "editorGroupHeader.border": raise12,

        "tab.activeBackground": bg,
        "tab.activeForeground": fg,
        "tab.activeBorder": "#00000000",
        "tab.activeBorderTop": p.green,
        "tab.activeBorderLeft": "#00000000",
        "tab.inactiveBackground": p.raise_(0.03),
        "tab.inactiveForeground": a(fg, 0.55),
        "tab.inactiveBorder": "#00000000",
        "tab.border": raise12,
        "tab.hoverBackground": raise5,
        "tab.hoverForeground": fg,
        "tab.hoverBorder": "#00000000",
        "tab.unfocusedActiveBackground": bg,
        "tab.unfocusedActiveForeground": a(fg, 0.7),
        "tab.unfocusedInactiveBackground": p.raise_(0.02),
        "tab.unfocusedInactiveForeground": a(fg, 0.4),
        "tab.unfocusedHoverBackground": p.raise_(0.04),
        "tab.lastPinnedBorder": raise15,
        "tab.activeModifiedBorder": p.yellow,
        "tab.inactiveModifiedBorder": p.yellow,
        "tab.unfocusedActiveModifiedBorder": p.yellow,
        "tab.unfocusedInactiveModifiedBorder": p.yellow,
        "tab.dragAndDropBorder": p.blue,
        "tab.closeBackground": "#00000000",
        "tab.closeForeground": a(fg, 0.55),
        "tab.closeHoverBackground": a(p.red, 0.25),
        "tab.closeHoverForeground": fg,
        "tab.activeCloseTopBorder": raise12,

        "sideBySideEditor.background": bg,
        "sideBySideEditor.border": raise12,

        # ── editor ────────────────────────────────────────────────────────
        "editor.background": bg,
        "editor.foreground": fg,
        "editorCursor.background": bg,
        "editorCursor.foreground": p.cursor,
        "editorMultiCursor.primary.foreground": p.cursor,
        "editorMultiCursor.secondary.foreground": p.purple,

        "editorLineNumber.foreground": a(fg, 0.35),
        "editorLineNumber.activeForeground": a(fg, 0.85),

        "editor.selectionBackground": sel,
        "editor.selectionForeground": "#00000000",
        "editor.inactiveSelectionBackground": a(fg, 0.16),
        "editor.selectionHighlightBackground": a(fg, 0.12),
        "editor.selectionHighlightBorder": "#00000000",
        "editor.wordHighlightBackground": a(fg, 0.12),
        "editor.wordHighlightBorder": "#00000000",
        "editor.wordHighlightStrongBackground": a(fg, 0.18),
        "editor.wordHighlightStrongBorder": "#00000000",
        "editor.wordHighlightTextBackground": a(fg, 0.12),
        "editor.wordHighlightTextBorder": "#00000000",
        "editor.findMatchBackground": a(p.yellow, 0.35),
        "editor.findMatchForeground": "#00000000",
        "editor.findMatchBorder": "#00000000",
        "editor.findMatchHighlightBackground": a(p.yellow, 0.2),
        "editor.findMatchHighlightForeground": "#00000000",
        "editor.findMatchHighlightBorder": "#00000000",
        "editor.findRangeHighlightBackground": a(fg, 0.1),
        "editor.findRangeHighlightBorder": "#00000000",
        "editor.rangeHighlightBackground": a(p.blue, 0.12),
        "editor.rangeHighlightBorder": "#00000000",
        "editor.hoverHighlightBackground": a(fg, 0.1),
        "editor.symbolHighlightBackground": a(p.yellow, 0.2),
        "editor.symbolHighlightBorder": "#00000000",

        "editor.lineHighlightBackground": line_hl,
        "editor.lineHighlightBorder": "#00000000",
        "editorWhitespace.foreground": a(fg, 0.12),
        "editorUnicodeHighlight.border": p.yellow,
        "editorUnicodeHighlight.background": a(p.yellow, 0.15),
        "editorIndentGuide.background1": a(fg, 0.12),
        "editorIndentGuide.activeBackground1": a(fg, 0.32),
        "editorRuler.foreground": a(fg, 0.12),
        "editorCodeLens.foreground": a(fg, 0.55),
        "editorLightBulb.foreground": p.yellow,
        "editorLightBulbAutoFix.foreground": p.blue,
        "editorLink.activeForeground": p.blue,

        "editorBracketMatch.background": a(p.blue, 0.2),
        "editorBracketMatch.border": a(p.blue, 0.6),
        "editorBracketHighlight.foreground1": a(p.red, 0.8),
        "editorBracketHighlight.foreground2": a(p.yellow, 0.8),
        "editorBracketHighlight.foreground3": a(p.green, 0.8),
        "editorBracketHighlight.foreground4": a(p.aqua, 0.8),
        "editorBracketHighlight.foreground5": a(p.blue, 0.8),
        "editorBracketHighlight.foreground6": a(p.purple, 0.8),
        "editorBracketHighlight.unexpectedBracket.foreground": p.red,
        "editorBracketPairGuide.activeBackground1": a(p.red, 0.5),
        "editorBracketPairGuide.activeBackground2": a(p.yellow, 0.5),
        "editorBracketPairGuide.activeBackground3": a(p.green, 0.5),
        "editorBracketPairGuide.activeBackground4": a(p.aqua, 0.5),
        "editorBracketPairGuide.activeBackground5": a(p.blue, 0.5),
        "editorBracketPairGuide.activeBackground6": a(p.purple, 0.5),
        "editorBracketPairGuide.background1": a(p.red, 0.12),
        "editorBracketPairGuide.background2": a(p.yellow, 0.12),
        "editorBracketPairGuide.background3": a(p.green, 0.12),
        "editorBracketPairGuide.background4": a(p.aqua, 0.12),
        "editorBracketPairGuide.background5": a(p.blue, 0.12),
        "editorBracketPairGuide.background6": a(p.purple, 0.12),

        "editor.foldBackground": a(p.blue, 0.12),
        "editor.foldPlaceholderForeground": a(fg, 0.5),
        "editorGhostText.foreground": a(fg, 0.45),
        "editorGhostText.background": "#00000000",
        "editorInlayHint.foreground": a(fg, 0.65),
        "editorInlayHint.background": a(fg, 0.1),
        "editorInlayHint.parameterForeground": a(fg, 0.65),
        "editorInlayHint.parameterBackground": a(fg, 0.1),
        "editorInlayHint.typeForeground": a(p.purple, 0.8),
        "editorInlayHint.typeBackground": a(p.purple, 0.12),
        "editor.snippetTabstopHighlightBackground": a(p.blue, 0.2),
        "editor.snippetTabstopHighlightBorder": a(p.blue, 0.5),
        "editor.snippetFinalTabstopHighlightBackground": a(p.green, 0.2),
        "editor.snippetFinalTabstopHighlightBorder": a(p.green, 0.5),
        "editor.stackFrameHighlightBackground": a(p.yellow, 0.25),
        "editor.focusedStackFrameHighlightBackground": a(p.green, 0.25),

        "editorError.foreground": p.red,
        "editorError.background": a(p.red, 0.12),
        "editorWarning.foreground": p.yellow,
        "editorWarning.background": a(p.yellow, 0.12),
        "editorInfo.foreground": p.blue,
        "editorInfo.background": a(p.blue, 0.12),
        "editorHint.foreground": p.aqua,
        "unnecessaryCode.opacity": "#00000080",

        "editorGutter.background": bg,
        "editorGutter.modifiedBackground": p.yellow,
        "editorGutter.addedBackground": p.green,
        "editorGutter.deletedBackground": p.red,
        "editorGutter.commentRangeForeground": a(fg, 0.4),
        "editorGutter.commentGlyphForeground": p.blue,
        "editorGutter.commentUnresolvedGlyphForeground": p.yellow,
        "editorGutter.foldingControlForeground": a(fg, 0.5),
        "editorGutter.itemGlyphForeground": fg,

        "editorOverviewRuler.border": raise12,
        "editorOverviewRuler.background": "#00000000",
        "editorOverviewRuler.findMatchForeground": a(p.yellow, 0.6),
        "editorOverviewRuler.rangeHighlightForeground": a(p.blue, 0.4),
        "editorOverviewRuler.selectionHighlightForeground": a(fg, 0.3),
        "editorOverviewRuler.wordHighlightForeground": a(fg, 0.3),
        "editorOverviewRuler.wordHighlightStrongForeground": a(fg, 0.4),
        "editorOverviewRuler.modifiedForeground": p.yellow,
        "editorOverviewRuler.addedForeground": p.green,
        "editorOverviewRuler.deletedForeground": p.red,
        "editorOverviewRuler.errorForeground": p.red,
        "editorOverviewRuler.warningForeground": p.yellow,
        "editorOverviewRuler.infoForeground": p.blue,
        "editorOverviewRuler.bracketMatchForeground": a(p.blue, 0.6),
        "editorOverviewRuler.incomingForeground": p.blue,
        "editorOverviewRuler.currentForeground": p.green,

        # ── editor widgets ────────────────────────────────────────────────
        "editorWidget.background": raise8,
        "editorWidget.foreground": fg,
        "editorWidget.border": raise15,
        "editorWidget.resizeBorder": a(p.blue, 0.6),

        "editorSuggestWidget.background": raise8,
        "editorSuggestWidget.border": raise15,
        "editorSuggestWidget.foreground": fg,
        "editorSuggestWidget.focusHighlightForeground": p.blue,
        "editorSuggestWidget.highlightForeground": p.green,
        "editorSuggestWidget.selectedBackground": a(p.green, 0.22),
        "editorSuggestWidget.selectedForeground": fg,
        "editorSuggestWidget.selectedIconForeground": fg,
        "editorSuggestWidget.statusBarForeground": a(fg, 0.6),

        "editorHoverWidget.background": raise8,
        "editorHoverWidget.border": raise15,
        "editorHoverWidget.foreground": fg,
        "editorHoverWidget.highlightForeground": p.blue,
        "editorHoverWidget.statusBarBackground": raise5,
        "editorHoverWidget.statusBarForeground": a(fg, 0.6),

        "editorMarkerNavigationError.background": p.tint(p.red, 0.25),
        "editorMarkerNavigationError.headerBackground": a(p.red, 0.25),
        "editorMarkerNavigationWarning.background": p.tint(p.yellow, 0.25),
        "editorMarkerNavigationWarning.headerBackground": a(p.yellow, 0.25),
        "editorMarkerNavigationInfo.background": p.tint(p.blue, 0.25),
        "editorMarkerNavigationInfo.headerBackground": a(p.blue, 0.25),

        "peekView.border": p.blue,
        "peekViewEditor.background": raise5,
        "peekViewEditorGutter.background": raise5,
        "peekViewEditor.matchHighlightBackground": a(p.yellow, 0.3),
        "peekViewEditor.matchHighlightBorder": "#00000000",
        "peekViewResult.background": p.raise_(0.03),
        "peekViewResult.fileForeground": fg,
        "peekViewResult.lineForeground": a(fg, 0.6),
        "peekViewResult.matchHighlightBackground": a(p.yellow, 0.25),
        "peekViewResult.selectionBackground": a(fg, 0.2),
        "peekViewResult.selectionForeground": fg,
        "peekViewTitle.background": raise8,
        "peekViewTitleDescription.foreground": a(fg, 0.6),
        "peekViewTitleLabel.foreground": fg,

        "problemsErrorIcon.foreground": p.red,
        "problemsWarningIcon.foreground": p.yellow,
        "problemsInfoIcon.foreground": p.blue,

        # ── panels / terminal ─────────────────────────────────────────────
        "panel.background": p.raise_(0.03),
        "panel.border": raise12,
        "panel.dropBorder": p.blue,
        "panelTitle.activeBorder": p.green,
        "panelTitle.activeForeground": fg,
        "panelTitle.inactiveForeground": a(fg, 0.6),
        "panelInput.border": raise15,
        "panelSection.border": raise12,
        "panelSection.dropBackground": a(p.blue, 0.15),
        "panelSectionHeader.background": raise5,
        "panelSectionHeader.foreground": fg,
        "panelSectionHeader.border": raise12,
        "panelStickyScroll.background": p.raise_(0.03),
        "panelStickyScroll.border": raise12,
        "panelStickyScroll.shadow": "#00000000",

        "terminal.background": bg,
        "terminal.foreground": fg,
        "terminal.border": raise12,
        "terminal.selectionBackground": a(fg, 0.3),
        "terminal.selectionForeground": "#00000000",
        "terminal.inactiveSelectionBackground": a(fg, 0.18),
        "terminal.findMatchBackground": a(p.yellow, 0.35),
        "terminal.findMatchBorder": "#00000000",
        "terminal.findMatchHighlightBackground": a(p.yellow, 0.2),
        "terminal.findMatchHighlightBorder": "#00000000",
        "terminal.hoverHighlightBackground": a(p.blue, 0.15),
        "terminal.dropBackground": a(p.blue, 0.15),
        "terminalCursor.foreground": p.cursor,
        "terminalCursor.background": bg,
        "terminal.tab.activeBorder": p.green,
        "terminal.initialHintForeground": a(fg, 0.5),
        "terminalCommandDecoration.defaultBackground": p.blue,
        "terminalCommandDecoration.errorBackground": p.red,
        "terminalCommandDecoration.successBackground": p.green,
        "terminalOverviewRuler.cursorForeground": p.cursor,
        "terminalOverviewRuler.findMatchForeground": a(p.yellow, 0.6),
        "terminalStickyScrollHover.background": raise12,
        "terminal.ansiBlack": p.c[0],
        "terminal.ansiRed": p.c[1],
        "terminal.ansiGreen": p.c[2],
        "terminal.ansiYellow": p.c[3],
        "terminal.ansiBlue": p.c[4],
        "terminal.ansiMagenta": p.c[5],
        "terminal.ansiCyan": p.c[6],
        "terminal.ansiWhite": p.c[7],
        "terminal.ansiBrightBlack": p.c[8],
        "terminal.ansiBrightRed": p.c[9],
        "terminal.ansiBrightGreen": p.c[10],
        "terminal.ansiBrightYellow": p.c[11],
        "terminal.ansiBrightBlue": p.c[12],
        "terminal.ansiBrightMagenta": p.c[13],
        "terminal.ansiBrightCyan": p.c[14],
        "terminal.ansiBrightWhite": p.c[15],

        # ── SCM / git decorations ─────────────────────────────────────────
        "gitDecoration.addedResourceForeground": p.green,
        "gitDecoration.modifiedResourceForeground": p.yellow,
        "gitDecoration.deletedResourceForeground": p.red,
        "gitDecoration.renamedResourceForeground": p.blue,
        "gitDecoration.stageModifiedResourceForeground": p.yellow,
        "gitDecoration.stageDeletedResourceForeground": p.red,
        "gitDecoration.untrackedResourceForeground": p.aqua,
        "gitDecoration.ignoredResourceForeground": a(fg, 0.4),
        "gitDecoration.conflictResourceForeground": p.purple,
        "gitDecoration.incomingResourceForeground": p.blue,
        "scmGraph.historyItemRefColor": p.blue,
        "scmGraph.historyItemRemoteRefColor": p.purple,
        "scmGraph.historyItemRefLabelBackground": a(p.blue, 0.2),
        "scmGraph.historyItemRefLabelForeground": fg,
        "scm.providerBorder": raise12,

        # ── diff & merge ──────────────────────────────────────────────────
        "diffEditor.insertedTextBackground": a(p.green, 0.18),
        "diffEditor.removedTextBackground": a(p.red, 0.18),
        "diffEditor.insertedLineBackground": a(p.green, 0.12),
        "diffEditor.removedLineBackground": a(p.red, 0.12),
        "diffEditor.border": raise12,
        "diffEditor.diagonalFill": raise12,
        "diffEditorGutter.insertedLineBackground": a(p.green, 0.15),
        "diffEditorGutter.removedLineBackground": a(p.red, 0.15),
        "diffEditorOverview.insertedForeground": a(p.green, 0.6),
        "diffEditorOverview.removedForeground": a(p.red, 0.6),
        "merge.currentHeaderBackground": a(p.green, 0.3),
        "merge.currentContentBackground": a(p.green, 0.12),
        "merge.incomingHeaderBackground": a(p.blue, 0.3),
        "merge.incomingContentBackground": a(p.blue, 0.12),
        "merge.commonHeaderBackground": a(fg, 0.15),
        "merge.commonContentBackground": a(fg, 0.08),
        "merge.border": raise12,
        "editorOverviewRuler.currentForeground": p.green,

        # ── minimap ───────────────────────────────────────────────────────
        "minimap.background": p.raise_(0.02),
        "minimap.foregroundOpacity": "#00000000",
        "minimap.selectionHighlight": a(p.blue, 0.5),
        "minimap.selectionOccurrenceHighlight": a(fg, 0.3),
        "minimap.findMatchHighlight": a(p.yellow, 0.5),
        "minimap.errorHighlight": a(p.red, 0.7),
        "minimap.warningHighlight": a(p.yellow, 0.7),
        "minimapGutter.addedBackground": p.green,
        "minimapGutter.modifiedBackground": p.yellow,
        "minimapGutter.deletedBackground": p.red,
        "minimapSlider.background": a(fg, 0.12),
        "minimapSlider.hoverBackground": a(fg, 0.2),
        "minimapSlider.activeBackground": a(fg, 0.3),

        # ── settings ──────────────────────────────────────────────────────
        "settings.headerForeground": fg,
        "settings.headerBorder": raise15,
        "settings.settingsHeaderHoverForeground": p.blue,
        "settings.modifiedItemIndicator": p.yellow,
        "settings.dropdownBackground": raise8,
        "settings.dropdownForeground": fg,
        "settings.dropdownBorder": raise20,
        "settings.dropdownListBorder": raise15,
        "settings.checkboxBackground": raise8,
        "settings.checkboxForeground": fg,
        "settings.checkboxBorder": raise20,
        "settings.textInputBackground": raise5,
        "settings.textInputForeground": fg,
        "settings.textInputBorder": raise20,
        "settings.textLinkForeground": p.blue,
        "settings.textLinkActiveForeground": mix(p.blue, fg, 0.3),
        "settings.focusedRowBackground": a(fg, 0.05),
        "settings.focusedRowBorder": a(p.blue, 0.5),
        "settings.rowHoverBackground": a(fg, 0.04),
        "settings.itemHoverBackground": a(fg, 0.04),
        "settings.syncIgnoredForeground": a(fg, 0.5),

        # ── breadcrumbs / outline ─────────────────────────────────────────
        "breadcrumb.background": bg,
        "breadcrumb.foreground": a(fg, 0.6),
        "breadcrumb.focusForeground": fg,
        "breadcrumb.activeSelectionForeground": fg,
        "breadcrumb.activeSelectionBackground": raise8,
        "breadcrumb.focusBackground": raise5,
        "breadcrumbPicker.background": raise8,

        # ── symbol icons ──────────────────────────────────────────────────
        "symbolIcon.arrayForeground": p.yellow,
        "symbolIcon.booleanForeground": p.purple,
        "symbolIcon.classForeground": p.blue,
        "symbolIcon.colorForeground": p.purple,
        "symbolIcon.constantForeground": p.purple,
        "symbolIcon.constructorForeground": p.yellow,
        "symbolIcon.enumeratorForeground": p.yellow,
        "symbolIcon.enumeratorMemberForeground": p.yellow,
        "symbolIcon.eventForeground": p.aqua,
        "symbolIcon.fieldForeground": p.blue,
        "symbolIcon.fileForeground": fg,
        "symbolIcon.folderForeground": fg,
        "symbolIcon.functionForeground": p.green,
        "symbolIcon.interfaceForeground": p.blue,
        "symbolIcon.keyForeground": p.red,
        "symbolIcon.keywordForeground": p.red,
        "symbolIcon.methodForeground": p.green,
        "symbolIcon.moduleForeground": p.aqua,
        "symbolIcon.namespaceForeground": p.aqua,
        "symbolIcon.nullForeground": p.purple,
        "symbolIcon.numberForeground": p.purple,
        "symbolIcon.objectForeground": p.blue,
        "symbolIcon.operatorForeground": p.green,
        "symbolIcon.packageForeground": p.aqua,
        "symbolIcon.propertyForeground": p.blue,
        "symbolIcon.referenceForeground": p.blue,
        "symbolIcon.snippetForeground": p.aqua,
        "symbolIcon.stringForeground": p.aqua,
        "symbolIcon.structForeground": p.blue,
        "symbolIcon.typeParameterForeground": p.blue,
        "symbolIcon.unitForeground": p.purple,
        "symbolIcon.variableForeground": fg,

        # ── debug ─────────────────────────────────────────────────────────
        "debugToolBar.background": raise8,
        "debugToolBar.border": raise15,
        "debugConsole.errorForeground": p.red,
        "debugConsole.warningForeground": p.yellow,
        "debugConsole.infoForeground": p.blue,
        "debugConsole.sourceForeground": fg,
        "debugConsoleInputIcon.foreground": fg,
        "debugIcon.breakpointForeground": p.red,
        "debugIcon.breakpointDisabledForeground": a(p.red, 0.4),
        "debugIcon.breakpointUnverifiedForeground": a(p.red, 0.5),
        "debugIcon.breakpointCurrentStackframeForeground": p.yellow,
        "debugIcon.breakpointStackframeForeground": p.yellow,
        "debugIcon.startForeground": p.green,
        "debugIcon.pauseForeground": p.yellow,
        "debugIcon.stopForeground": p.red,
        "debugIcon.disconnectForeground": p.purple,
        "debugIcon.restartForeground": p.green,
        "debugIcon.stepOverForeground": p.blue,
        "debugIcon.stepIntoForeground": p.blue,
        "debugIcon.stepOutForeground": p.blue,
        "debugIcon.continueForeground": p.green,
        "debugIcon.stepBackForeground": p.blue,
        "debugTokenExpression.name": p.blue,
        "debugTokenExpression.value": fg,
        "debugTokenExpression.string": p.aqua,
        "debugTokenExpression.boolean": p.purple,
        "debugTokenExpression.number": p.purple,
        "debugTokenExpression.error": p.red,
        "debugView.exceptionLabelForeground": fg,
        "debugView.exceptionLabelBackground": p.tint(p.red, 0.25),
        "debugView.stateLabelForeground": fg,
        "debugView.stateLabelBackground": raise12,
        "debugView.valueChangedHighlight": a(p.yellow, 0.35),

        # ── testing ───────────────────────────────────────────────────────
        "testing.iconFailed": p.red,
        "testing.iconErrored": p.red,
        "testing.iconPassed": p.green,
        "testing.iconQueued": p.yellow,
        "testing.iconSkipped": a(fg, 0.5),
        "testing.iconUnset": a(fg, 0.6),
        "testing.peekBorder": p.red,
        "testing.peekHeaderBackground": raise8,
        "testing.message.error.decorationForeground": p.red,
        "testing.message.error.lineBackground": a(p.red, 0.15),
        "testing.message.info.decorationForeground": p.blue,
        "testing.message.info.lineBackground": a(p.blue, 0.15),
        "testing.message.warning.decorationForeground": p.yellow,
        "testing.message.warning.lineBackground": a(p.yellow, 0.15),

        # ── extensions / welcome / walk-through ───────────────────────────
        "extensionButton.prominentBackground": p.green,
        "extensionButton.prominentForeground": p.on_accent,
        "extensionButton.prominentHoverBackground": mix(p.green, fg, 0.15),
        "extensionButton.secondaryBackground": raise12,
        "extensionButton.secondaryForeground": fg,
        "extensionButton.secondaryHoverBackground": raise20,
        "extensionButton.separator": a(fg, 0.2),
        "extensionBadge.remoteBackground": p.blue,
        "extensionBadge.remoteForeground": p.on_accent,
        "extensionIcon.starForeground": p.yellow,
        "extensionIcon.verifiedForeground": p.blue,
        "extensionIcon.preReleaseForeground": p.yellow,
        "extensionIcon.sponsorForeground": p.purple,

        "welcomePage.background": bg,
        "welcomePage.progress.background": raise8,
        "welcomePage.progress.foreground": p.blue,
        "welcomePage.tileBackground": raise5,
        "welcomePage.tileHoverBackground": raise8,
        "welcomePage.tileBorder": raise15,
        "welcomePage.buttonBackground": raise12,
        "welcomePage.buttonHoverBackground": raise20,
        "walkThrough.embeddedEditorBackground": p.raise_(0.03),

        # ── charts ────────────────────────────────────────────────────────
        "charts.foreground": fg,
        "charts.lines": a(fg, 0.3),
        "charts.red": p.red,
        "charts.blue": p.blue,
        "charts.yellow": p.yellow,
        "charts.orange": p.orange,
        "charts.green": p.green,
        "charts.purple": p.purple,

        # ── ports / comments / profile ────────────────────────────────────
        "ports.iconRunningProcessForeground": p.green,
        "commentsView.resolvedIconForeground": a(fg, 0.5),
        "commentsView.unresolvedIconForeground": p.yellow,
        "profileBadge.background": raise12,
        "profileBadge.foreground": fg,
    }

    token_colors = [
        {"settings": {"foreground": fg, "background": bg}},
        # comments
        {"scope": ["comment", "punctuation.definition.comment"],
         "settings": {"foreground": p.grey, "fontStyle": "italic"}},
        # keywords & storage
        {"scope": ["keyword", "storage.type.function", "storage.type.class",
                   "storage.type.enum", "storage.type.interface",
                   "storage.type.struct", "storage.type.type",
                   "storage.modifier", "keyword.other.debugger"],
         "settings": {"foreground": p.red}},
        {"scope": ["keyword.var", "keyword.control.case", "keyword.control.switch",
                   "entity.name.tag", "storage.modifier.import"],
         "settings": {"foreground": p.orange}},
        {"scope": ["keyword.operator", "keyword.control.at-rule",
                   "keyword.control.import", "keyword.control.export",
                   "storage.type.namespace", "storage.type.annotation"],
         "settings": {"foreground": p.green}},
        # strings & escapes
        {"scope": ["string", "punctuation.definition.string.begin",
                   "punctuation.definition.string.end", "string.quasi",
                   "constant.other.caps"],
         "settings": {"foreground": p.aqua}},
        {"scope": ["constant.character.escape", "punctuation.quasi.element",
                   "punctuation.definition.template-expression",
                   "punctuation.definition.templateexpression",
                   "constant.character.entity", "keyword.other.template"],
         "settings": {"foreground": p.green}},
        {"scope": ["string.regexp", "constant.other.character-class.regexp",
                   "keyword.operator.quantifier.regexp",
                   "punctuation.definition.string.regexp"],
         "settings": {"foreground": p.aqua}},
        # functions
        {"scope": ["entity.name.function", "support.function",
                   "variable.function", "meta.function-call.generic",
                   "entity.name.function.member", "entity.name.function.macro"],
         "settings": {"foreground": p.green}},
        # types & classes
        {"scope": ["storage.type", "support.type", "entity.name.type",
                   "keyword.type", "entity.name.type.class",
                   "support.class", "entity.name.class",
                   "entity.other.inherited-class", "entity.name.namespace",
                   "support.module", "support.node", "support.other.module",
                   "support.type.object.module"],
         "settings": {"foreground": p.blue}},
        # properties
        {"scope": ["variable.object.property", "support.variable.property",
                   "variable.other.property", "variable.other.object.property",
                   "support.type.property-name", "entity.name.tag.css",
                   "meta.object-literal.key"],
         "settings": {"foreground": p.blue}},
        # numbers, constants, this/self
        {"scope": ["constant.numeric", "constant.language.boolean",
                   "constant.language", "support.constant",
                   "variable.language.this", "variable.language.self",
                   "variable.language.super", "keyword.other.this",
                   "entity.name.function.preprocessor", "keyword.other.unit"],
         "settings": {"foreground": p.purple}},
        # attributes & labels
        {"scope": ["entity.other.attribute-name", "entity.name.label",
                   "constant.other.label", "variable.other.enummember"],
         "settings": {"foreground": p.yellow}},
        # variables & punctuation
        {"scope": ["variable", "support.variable", "meta.definition.variable"],
         "settings": {"foreground": fg}},
        {"scope": ["punctuation", "meta.brace", "meta.delimiter", "meta.bracket",
                   "keyword.operator.assignment", "keyword.operator.arithmetic",
                   "keyword.operator.logical", "keyword.operator.comparison"],
         "settings": {"foreground": fg}},
        # invalid / deprecated
        {"scope": ["invalid", "invalid.deprecated"],
         "settings": {"foreground": p.red}},
        {"scope": ["markup.inserted", "meta.diff.header.to-file"],
         "settings": {"foreground": p.green}},
        {"scope": ["markup.deleted", "meta.diff.header.from-file"],
         "settings": {"foreground": p.red}},
        {"scope": ["markup.changed"],
         "settings": {"foreground": p.yellow}},
        {"scope": ["markup.ignored", "markup.untracked"],
         "settings": {"foreground": p.grey}},
        # markdown
        {"scope": ["heading.1.markdown", "markup.heading.setext.1.markdown",
                   "markup.heading.markdown punctuation.definition.heading.markdown"],
         "settings": {"foreground": p.red, "fontStyle": "bold"}},
        {"scope": ["heading.2.markdown", "markup.heading.setext.2.markdown"],
         "settings": {"foreground": p.orange, "fontStyle": "bold"}},
        {"scope": ["heading.3.markdown"],
         "settings": {"foreground": p.yellow, "fontStyle": "bold"}},
        {"scope": ["heading.4.markdown"],
         "settings": {"foreground": p.green, "fontStyle": "bold"}},
        {"scope": ["heading.5.markdown"],
         "settings": {"foreground": p.blue, "fontStyle": "bold"}},
        {"scope": ["heading.6.markdown"],
         "settings": {"foreground": p.purple, "fontStyle": "bold"}},
        {"scope": ["markup.underline.link.markdown",
                   "markup.underline.link.image.markdown",
                   "string.other.link.title.markdown",
                   "string.other.link.description.markdown",
                   "constant.other.reference.link.markdown"],
         "settings": {"foreground": p.green}},
        {"scope": ["markup.fenced_code.block.markdown",
                   "markup.inline.raw.string.markdown",
                   "markup.raw.block.markdown"],
         "settings": {"foreground": p.aqua}},
        {"scope": ["markup.bold.markdown", "markup.bold"],
         "settings": {"fontStyle": "bold"}},
        {"scope": ["markup.italic.markdown", "markup.italic"],
         "settings": {"fontStyle": "italic"}},
        {"scope": ["punctuation.definition.list.begin.markdown",
                   "punctuation.definition.quote.begin.markdown"],
         "settings": {"foreground": p.red}},
        {"scope": ["meta.separator.markdown", "punctuation.definition.markdown"],
         "settings": {"foreground": p.yellow}},
        {"scope": ["markup.quote.markdown"],
         "settings": {"foreground": p.grey, "fontStyle": "italic"}},
    ]

    semantic_tokens = {
        "namespace": p.aqua,
        "class": p.blue,
        "enum": p.blue,
        "interface": p.blue,
        "struct": p.blue,
        "type": p.blue,
        "typeParameter": p.blue,
        "parameter": {"foreground": fg, "fontStyle": "italic"},
        "variable": fg,
        "property": p.blue,
        "enumMember": p.yellow,
        "event": p.aqua,
        "function": p.green,
        "method": p.green,
        "macro": p.purple,
        "keyword": p.red,
        "modifier": p.red,
        "comment": {"foreground": p.grey, "fontStyle": "italic"},
        "string": p.aqua,
        "number": p.purple,
        "regexp": p.aqua,
        "operator": p.green,
        "decorator": p.aqua,
        "boolean": p.purple,
        "selfKeyword": p.purple,
    }

    return {
        "name": name,
        "type": "dark" if mode == "dark" else "light",
        "semanticHighlighting": True,
        "semanticTokenColors": semantic_tokens,
        "colors": colors,
        "tokenColors": token_colors,
    }


def main():
    if len(sys.argv) != 5 or sys.argv[4] not in ("dark", "light"):
        sys.exit(__doc__.strip().splitlines()[-4].strip())
    scheme_path, output_path, name, mode = sys.argv[1:5]

    with open(scheme_path) as f:
        scheme = json.load(f)

    theme = build_theme(scheme, name, mode)
    with open(output_path, "w") as f:
        json.dump(theme, f, indent=2)
        f.write("\n")
    print("wrote %s  (%s, %d workbench colors, %d token groups)"
          % (output_path, mode, len(theme["colors"]), len(theme["tokenColors"])))


if __name__ == "__main__":
    main()
