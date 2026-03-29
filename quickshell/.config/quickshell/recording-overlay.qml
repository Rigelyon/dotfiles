import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    id: shell

    property int reqX: parseInt(Quickshell.env("RECORD_X")) || 0
    property int reqY: parseInt(Quickshell.env("RECORD_Y")) || 0
    property int reqW: parseInt(Quickshell.env("RECORD_W")) || 200
    property int reqH: parseInt(Quickshell.env("RECORD_H")) || 200

    property int _elapsed: 0

    function formatTime(secs) {
        var m = Math.floor(secs / 60)
        var s = secs % 60
        return (m < 10 ? "0" : "") + m + ":" + (s < 10 ? "0" : "") + s
    }

    function stopRecording() {
        elapsedTimer.stop()
        stopProc.exec({ command: [
            "bash", "-c",
            "$HOME/.config/hypr/scripts/record.sh --stop"
        ]})
    }

    // ── Processes ─────────────────────────────────────────────

    Process { id: stopProc }

    // ── Timers ────────────────────────────────────────────────

    Timer {
        id: elapsedTimer
        interval: 1000; repeat: true; running: true
        onTriggered: shell._elapsed++
    }

    PanelWindow {
        id: overlayWindow

        anchors { top: true; bottom: true; left: true; right: true }
        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "recording-overlay"
        exclusiveZone: -1
        color: "transparent"

        mask: Region { item: btnAnchor }

        // ── GLSL Shader Dimming ──────────────────────────────
        ShaderEffect {
            anchors.fill: parent; z: 0
            property vector4d selectionRect: Qt.vector4d(shell.reqX, shell.reqY, shell.reqW, shell.reqH)
            property real dimOpacity: 0.65
            property vector2d screenSize: Qt.vector2d(overlayWindow.width, overlayWindow.height)
            property real borderRadius: 4.0
            property real outlineThickness: 1.5
            fragmentShader: Qt.resolvedUrl("dimming.frag.qsb")
        }

        // ── Red Recording Border ─────────────────────────────
        Rectangle {
            x: shell.reqX - 2; y: shell.reqY - 2
            width: shell.reqW + 4; height: shell.reqH + 4
            color: "transparent"; border.color: "#FF4444"; border.width: 2
            radius: 5; opacity: 0.85; z: 1
        }

        // ── Corner + Mid-edge Handles ────────────────────────
        Repeater {
            model: (shell.reqW > 30 && shell.reqH > 30) ? 8 : 0
            delegate: Rectangle {
                z: 2; width: 7; height: 7; radius: 1; color: "white"
                border.color: Qt.rgba(0,0,0,0.55); border.width: 1
                readonly property real hx: shell.reqX; readonly property real hy: shell.reqY
                readonly property real hw: shell.reqW; readonly property real hh: shell.reqH
                readonly property real mx: hx + hw / 2; readonly property real my: hy + hh / 2
                x: [hx, mx, hx+hw, hx+hw, hx+hw, mx, hx, hx][index] - 3.5
                y: [hy, hy, hy, my, hy+hh, hy+hh, hy+hh, my][index] - 3.5
            }
        }

        // ── Size Badge ───────────────────────────────────────
        Rectangle {
            id: sizeBadge
            visible: shell.reqW > 20; z: 11
            x: Math.max(4, Math.min(shell.reqX + shell.reqW / 2 - width / 2, overlayWindow.width - width - 4))
            y: {
                if (btnAnchor.placedAbove) {
                    return btnAnchor.y - height - 4
                } else {
                    return shell.reqY > 36 ? shell.reqY - 34 : shell.reqY + shell.reqH + 8
                }
            }
            width: sizeLabel.implicitWidth + 16; height: 26; radius: 6
            color: Qt.rgba(0, 0, 0, 0.75)
            Text {
                id: sizeLabel; anchors.centerIn: parent
                text: shell.reqW + " × " + shell.reqH
                color: "white"; font.pixelSize: 12; font.family: "monospace"; font.weight: Font.Bold
            }
        }

        // ── Control Group (REC indicator + Stop button) ──────
        Item {
            id: btnAnchor; z: 10

            readonly property real grpW: controlCol.implicitWidth + 2
            readonly property real grpH: controlCol.implicitHeight + 2
            readonly property real spaceBelow: overlayWindow.height - (shell.reqY + shell.reqH)
            readonly property real spaceAbove: shell.reqY
            readonly property real spaceRight: overlayWindow.width - (shell.reqX + shell.reqW)
            readonly property real spaceLeft: shell.reqX
            readonly property bool placedAbove: spaceBelow < grpH + 16 && spaceAbove >= grpH + 16

            x: {
                if (spaceBelow >= grpH + 16 || spaceAbove >= grpH + 16) {
                    return Math.max(8, Math.min(
                        shell.reqX + (shell.reqW - grpW) / 2,
                        overlayWindow.width - grpW - 8))
                } else if (spaceRight >= grpW + 10) {
                    return shell.reqX + shell.reqW + 8
                } else if (spaceLeft >= grpW + 10) {
                    return shell.reqX - grpW - 8
                } else {
                    return Math.max(8, overlayWindow.width - grpW - 8)
                }
            }
            y: {
                if (spaceBelow >= grpH + 16) {
                    return shell.reqY + shell.reqH + 8
                } else if (spaceAbove >= grpH + 16) {
                    return shell.reqY - grpH - 8
                } else if (spaceRight >= grpW + 10 || spaceLeft >= grpW + 10) {
                    return Math.max(8, Math.min(
                        shell.reqY + (shell.reqH - grpH) / 2,
                        overlayWindow.height - grpH - 8))
                } else {
                    return Math.max(8, overlayWindow.height - grpH - 8)
                }
            }
            width: grpW; height: grpH

            Column {
                id: controlCol
                anchors.centerIn: parent; spacing: 6

                // ── REC Indicator ────────────────────────
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: recRow.implicitWidth + 12; height: 22; radius: 6
                    color: Qt.rgba(0, 0, 0, 0.75)
                    Row {
                        id: recRow; anchors.centerIn: parent; spacing: 4
                        Rectangle {
                            width: 7; height: 7; radius: 4; color: "#FF4444"
                            anchors.verticalCenter: parent.verticalCenter
                            SequentialAnimation on opacity {
                                running: true; loops: Animation.Infinite
                                NumberAnimation { to: 0.15; duration: 600 }
                                NumberAnimation { to: 1.0; duration: 600 }
                            }
                        }
                        Text {
                            text: "REC " + shell.formatTime(shell._elapsed)
                            color: "white"; font.weight: Font.Bold; font.pixelSize: 11
                            font.family: "monospace"; anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // ── Stop Button ──────────────────────────
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    height: 34; radius: 4; width: stopRow.implicitWidth + 24
                    color: stopBtn.containsMouse ? "#FF4444" : '#25252f'
                    border.color: Qt.rgba(1, 1, 1, 0.12); border.width: 1
                    Row {
                        id: stopRow; anchors.centerIn: parent; spacing: 6
                        Rectangle {
                            width: 10; height: 10; radius: 2
                            color: stopBtn.containsMouse ? "white" : "#FF4444"
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: "Stop Recording"
                            color: stopBtn.containsMouse ? "white" : "white"
                            font.weight: Font.Bold; font.pixelSize: 13
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    MouseArea {
                        id: stopBtn; anchors.fill: parent; hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: shell.stopRecording()
                    }
                }
            }
        }
    }
}
