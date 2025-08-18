import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15
import QtQuick.Shapes 1.15
import QtGraphicalEffects 1.15

Rectangle {
    id: root
    width: 640
    height: 480
    color: "#000000" // dark background

    // Liquid glass overlay
    Rectangle {
        anchors.fill: parent
        color: "#ffffff11" // semi-transparent white
        radius: 20
        layer.enabled: true
        layer.effect: OpacityMask { maskSource: Rectangle { anchors.fill: parent; color: "white" } }
    }

    // Background image (safe for ksplash)
    Image {
        anchors.fill: parent
        source: "images/background.png"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.8
    }

    // Animated glow text
    Text {
        id: titleText
        anchors.centerIn: parent
        text: "Nezuko"
        font.pixelSize: 60
        font.bold: true
        color: "white"
        opacity: 0.0

        // Fade-in animation
        SequentialAnimation on opacity {
            loops: 1
            NumberAnimation { from: 0.0; to: 0.9; duration: 1500; easing.type: Easing.InOutQuad }
        }

        // Pulsating glow (simulated)
        Behavior on color {
            ColorAnimation { from: "white"; to: "#ffcccc"; duration: 1200; loops: Animation.Infinite; reversible: true; easing.type: Easing.InOutSine }
        }
    }

    // Animated progress bar
    Rectangle {
        id: progressBar
        width: parent.width * 0.6
        height: 8
        color: "#ffffff55"
        radius: 4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50

        Rectangle {
            id: progress
            width: 0
            height: progressBar.height
            color: "#ff9999"
            radius: 4

            Behavior on width {
                NumberAnimation { duration: 2000; easing.type: Easing.InOutQuad }
            }

            Component.onCompleted: width = progressBar.width * 0.7
        }
    }
}
