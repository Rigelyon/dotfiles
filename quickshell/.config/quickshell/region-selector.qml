import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: shell

    PanelWindow {
        id: win

        anchors { top: true; bottom: true; left: true; right: true }
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
        WlrLayershell.namespace: "recording-region-selector"

        // ── Selection State ──────────────────────────────────
        property real selX: 0
        property real selY: 0
        property real selW: 0
        property real selH: 0
        property real mouseXPos: 0
        property real mouseYPos: 0
        property point startPos
        property bool dragging: false
        property real fadeOpacity: 0.0

        Component.onCompleted: { fadeOpacity = 0.0; fadeIn.restart() }

        NumberAnimation {
            id: fadeIn; target: win; property: "fadeOpacity"
            from: 0.0; to: 1.0; duration: 140; easing.type: Easing.OutCubic
        }

        // ── GLSL Shader Dimming ──────────────────────────────
        ShaderEffect {
            anchors.fill: parent; z: 0
            opacity: win.fadeOpacity
            property vector4d selectionRect: Qt.vector4d(win.selX, win.selY, win.selW, win.selH)
            property real dimOpacity: 0.72
            property vector2d screenSize: Qt.vector2d(win.width, win.height)
            property real borderRadius: 0
            property real outlineThickness: 1.5
            fragmentShader: Qt.resolvedUrl("dimming.frag.qsb")
        }

        // ── Crosshair (pre-drag) — Rectangle-based ──────────
        // Shadow lines
        Rectangle {
            visible: !win.dragging; opacity: win.fadeOpacity; z: 2
            x: win.mouseXPos - 1.25; y: 0; width: 2.5; height: win.height
            color: Qt.rgba(0,0,0,0.45)
        }
        Rectangle {
            visible: !win.dragging; opacity: win.fadeOpacity; z: 2
            x: 0; y: win.mouseYPos - 1.25; width: win.width; height: 2.5
            color: Qt.rgba(0,0,0,0.45)
        }
        // White lines
        Rectangle {
            visible: !win.dragging; opacity: win.fadeOpacity; z: 3
            x: win.mouseXPos - 0.5; y: 0; width: 1; height: win.height
            color: Qt.rgba(1,1,1,0.92)
        }
        Rectangle {
            visible: !win.dragging; opacity: win.fadeOpacity; z: 3
            x: 0; y: win.mouseYPos - 0.5; width: win.width; height: 1
            color: Qt.rgba(1,1,1,0.92)
        }

        // ── Edge Guides (during drag) — Rectangle-based ─────
        // Shadow lines (4 edges)
        Rectangle {
            visible: win.dragging; opacity: win.fadeOpacity; z: 2
            x: win.selX - 1.25; y: 0; width: 2.5; height: win.height
            color: Qt.rgba(0,0,0,0.45)
        }
        Rectangle {
            visible: win.dragging; opacity: win.fadeOpacity; z: 2
            x: win.selX + win.selW - 1.25; y: 0; width: 2.5; height: win.height
            color: Qt.rgba(0,0,0,0.45)
        }
        Rectangle {
            visible: win.dragging; opacity: win.fadeOpacity; z: 2
            x: 0; y: win.selY - 1.25; width: win.width; height: 2.5
            color: Qt.rgba(0,0,0,0.45)
        }
        Rectangle {
            visible: win.dragging; opacity: win.fadeOpacity; z: 2
            x: 0; y: win.selY + win.selH - 1.25; width: win.width; height: 2.5
            color: Qt.rgba(0,0,0,0.45)
        }
        // White lines (4 edges)
        Rectangle {
            visible: win.dragging; opacity: win.fadeOpacity; z: 3
            x: win.selX - 0.5; y: 0; width: 1; height: win.height
            color: Qt.rgba(1,1,1,0.92)
        }
        Rectangle {
            visible: win.dragging; opacity: win.fadeOpacity; z: 3
            x: win.selX + win.selW - 0.5; y: 0; width: 1; height: win.height
            color: Qt.rgba(1,1,1,0.92)
        }
        Rectangle {
            visible: win.dragging; opacity: win.fadeOpacity; z: 3
            x: 0; y: win.selY - 0.5; width: win.width; height: 1
            color: Qt.rgba(1,1,1,0.92)
        }
        Rectangle {
            visible: win.dragging; opacity: win.fadeOpacity; z: 3
            x: 0; y: win.selY + win.selH - 0.5; width: win.width; height: 1
            color: Qt.rgba(1,1,1,0.92)
        }

        // ── Corner + Mid-edge Handles ────────────────────────
        Repeater {
            model: (win.dragging && win.selW > 30 && win.selH > 30) ? 8 : 0
            delegate: Rectangle {
                z: 11; width: 7; height: 7; radius: 1; color: "white"
                border.color: Qt.rgba(0,0,0,0.55); border.width: 1
                opacity: win.fadeOpacity
                readonly property real hx: win.selX; readonly property real hy: win.selY
                readonly property real hw: win.selW; readonly property real hh: win.selH
                readonly property real mx: hx + hw / 2; readonly property real my: hy + hh / 2
                x: [hx, mx, hx+hw, hx+hw, hx+hw, mx, hx, hx][index] - 3.5
                y: [hy, hy, hy, my, hy+hh, hy+hh, hy+hh, my][index] - 3.5
            }
        }

        // ── Size Badge ───────────────────────────────────────
        Rectangle {
            visible: win.dragging && win.selW > 20
            opacity: win.fadeOpacity
            x: Math.max(4, Math.min(win.selX + win.selW / 2 - width / 2, win.width - width - 4))
            y: win.selY > 36 ? win.selY - 34 : win.selY + win.selH + 8
            width: selSizeLabel.implicitWidth + 16; height: 26; radius: 6
            color: Qt.rgba(0, 0, 0, 0.75); z: 10
            Text {
                id: selSizeLabel; anchors.centerIn: parent
                text: Math.round(win.selW) + " × " + Math.round(win.selH)
                color: "white"; font.pixelSize: 12; font.family: "monospace"; font.weight: Font.Bold
            }
        }

        // ── Cursor Coordinates ───────────────────────────────
        Rectangle {
            visible: !win.dragging; opacity: win.fadeOpacity; z: 10
            width: coordLabel.implicitWidth + 14; height: 22; radius: 5
            color: Qt.rgba(0, 0, 0, 0.72)
            x: { var bx = win.mouseXPos + 18; return bx + width > win.width - 4 ? win.mouseXPos - width - 18 : bx }
            y: { var by = win.mouseYPos + 18; return by + height > win.height - 4 ? win.mouseYPos - height - 18 : by }
            Text {
                id: coordLabel; anchors.centerIn: parent
                text: Math.round(win.mouseXPos) + ", " + Math.round(win.mouseYPos)
                color: Qt.rgba(1,1,1,0.85); font.pixelSize: 11; font.family: "monospace"
            }
        }

        // ── Mouse Interaction ────────────────────────────────
        MouseArea {
            anchors.fill: parent; hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.CrossCursor; z: 4

            onPressed: (mouse) => {
                if (mouse.button === Qt.RightButton) { Qt.quit(); return }
                win.startPos = Qt.point(mouse.x, mouse.y)
                win.selX = mouse.x; win.selY = mouse.y
                win.selW = 0; win.selH = 0
                win.dragging = true
            }

            onPositionChanged: (mouse) => {
                win.mouseXPos = mouse.x; win.mouseYPos = mouse.y
                if (win.dragging) {
                    win.selX = Math.min(win.startPos.x, mouse.x)
                    win.selY = Math.min(win.startPos.y, mouse.y)
                    win.selW = Math.abs(mouse.x - win.startPos.x)
                    win.selH = Math.abs(mouse.y - win.startPos.y)
                }
            }

            onReleased: (mouse) => {
                if (mouse.button === Qt.RightButton) return
                win.dragging = false
                var w = Math.round(win.selW), h = Math.round(win.selH)
                if (w > 4 && h > 4) {
                    var gx = Math.round(win.selX)
                    var gy = Math.round(win.selY)
                    var geom = gx + "," + gy + " " + w + "x" + h
                    regionWriteProc.exec({ command: [
                        "bash", "-c",
                        "echo '" + geom + "' > /tmp/recording_region.txt"
                    ]})
                } else {
                    Qt.quit()
                }
            }
        }

        Shortcut {
            sequence: "Escape"; enabled: win.visible
            onActivated: Qt.quit()
        }
    }

    Process {
        id: regionWriteProc
        onExited: Qt.quit()
    }
}
