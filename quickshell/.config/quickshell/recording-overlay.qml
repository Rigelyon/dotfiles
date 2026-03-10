import QtQuick
import Quickshell
import Quickshell.Wayland

ShellRoot {
    PanelWindow {
        id: window
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        property int reqX: parseInt(Quickshell.env("RECORD_X")) || 0
        property int reqY: parseInt(Quickshell.env("RECORD_Y")) || 0
        property int reqW: parseInt(Quickshell.env("RECORD_W")) || 200
        property int reqH: parseInt(Quickshell.env("RECORD_H")) || 200

        
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "recording-overlay"
        exclusiveZone: -1
        mask: Region {}
        
        color: "transparent"
        
        Rectangle {
            x: 0; y: 0
            width: parent.width; height: window.reqY
            color: "#80000000"
        }
        
        Rectangle {
            x: 0; y: window.reqY + window.reqH
            width: parent.width; height: parent.height - (window.reqY + window.reqH)
            color: "#80000000"
        }
        
        Rectangle {
            x: 0; y: window.reqY
            width: window.reqX; height: window.reqH
            color: "#80000000"
        }
        
        Rectangle {
            x: window.reqX + window.reqW; y: window.reqY
            width: parent.width - (window.reqX + window.reqW); height: window.reqH
            color: "#80000000"
        }
        
        Rectangle {
            x: window.reqX - 2
            y: window.reqY - 2
            width: window.reqW + 4
            height: window.reqH + 4
            color: "transparent"
            border.color: "white"
            border.width: 2 
        }
    }
}
