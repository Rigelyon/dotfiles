import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Networking

FloatingWindow {
    id: window
    width: 350
    height: 450
    color: "#1e1e2e" // Catppuccin Mocha base color

    // Window configuration
    title: "Network Manager"

    // Header/Title Bar
    Rectangle {
        id: titleBar
        width: parent.width
        height: 55
        color: "#11111b" // Crust
        
        // Drag area for floating window
        MouseArea {
            anchors.fill: parent
            property var clickPos: "1,1"
            onPressed: (mouse) => clickPos = Qt.point(mouse.x, mouse.y)
            onPositionChanged: (mouse) => {
                var delta = Qt.point(mouse.x - clickPos.x, mouse.y - clickPos.y)
                window.x += delta.x
                window.y += delta.y
            }
        }

        Text {
            anchors.centerIn: parent
            text: "Network Interfaces"
            color: "#cdd6f4" // Text
            font.pixelSize: 18
            font.bold: true
        }

        // Close Button
        Rectangle {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: 15
            width: 24
            height: 24
            radius: 12
            color: closeMouseArea.containsMouse ? "#f38ba8" : "#45475a" // Red on hover, Surface1 otherwise

            Text {
                anchors.centerIn: parent
                text: "✕"
                color: "#11111b"
                font.bold: true
                font.pixelSize: 12
            }

            MouseArea {
                id: closeMouseArea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: window.close()
            }
        }
    }

    // List of Network Devices
    ListView {
        anchors.top: titleBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 15
        spacing: 12
        clip: true
        
        model: Networking.devices

        delegate: Rectangle {
            width: ListView.view.width
            height: 70
            color: "#313244" // Surface 0
            radius: 10

            RowLayout {
                anchors.fill: parent
                anchors.margins: 15
                spacing: 15

                // Icon / Status Indicator
                Rectangle {
                    width: 40
                    height: 40
                    radius: 20
                    color: modelData.connected ? "#a6e3a1" : "#45475a" // Green if connected

                    Text {
                        anchors.centerIn: parent
                        text: modelData.type === 2 ? "󰤨" : "󰈀" // Wifi or Ethernet icon
                        color: "#11111b"
                        font.pixelSize: 20
                    }
                }

                // Details Column
                Column {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: modelData.name || "Unknown Interface"
                        color: "#cdd6f4"
                        font.pixelSize: 16
                        font.bold: true
                    }
                    
                    Text {
                        text: modelData.connected ? "Connected" : "Disconnected"
                        color: modelData.connected ? "#a6e3a1" : "#a6adc8" // Green or Subtext0
                        font.pixelSize: 12
                    }
                }
                
                // Toggle Switch Placeholder
                Rectangle {
                    width: 40
                    height: 20
                    radius: 10
                    color: modelData.connected ? "#a6e3a1" : "#45475a"
                    
                    Rectangle {
                        width: 16
                        height: 16
                        radius: 8
                        color: "#11111b"
                        anchors.verticalCenter: parent.verticalCenter
                        x: modelData.connected ? parent.width - width - 2 : 2
                        
                        Behavior on x { NumberAnimation { duration: 150 } }
                    }
                }
            }
        }
    }
}
