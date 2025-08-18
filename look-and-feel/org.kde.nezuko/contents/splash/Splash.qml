import QtQuick 2.15
import QtQuick.Controls 2.15
import QtMultimedia 5.15
import QtQuick.Animations 2.15

Rectangle {
    id: root
    width: 640
    height: 480
    color: "#000000" 

    Image {
        anchors.fill: parent
        source: "look-and-feel/org.kde.nezuko/contents/splash/images/background.png"
        fillMode: Image.PreserveAspectCrop
        id: fallbackImage
        visible: false
    }
 

    // Video background
    Video {
        id: backgroundVideo
        anchors.fill: parent
        source: "look-and-feel/org.kde.nezuko/contents/splash/videos/background.mp4"  // change to your video path
        autoPlay: true
        loops: MediaPlayer.Infinite
        fillMode: VideoOutput.PreserveAspectCrop
    }

    // Dark overlay for cinematic feel
    Rectangle {
        anchors.fill: parent
        color: "#00000077" // semi-transparent black
    }

    // Main text with glow and fade-in
    Text {
        id: titleText
        anchors.centerIn: parent
        text: "Nezuko"
        font.pixelSize: 60
        color: "white"
        opacity: 0.0
        font.bold: true

        // Glow effect
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle { width: titleText.width; height: titleText.height; color: "white" }
        }

        SequentialAnimation on opacity {
            loops: 1
            NumberAnimation { from: 0.0; to: 0.9; duration: 1500; easing.type: Easing.InOutQuad }
        }

        // Slight pulsating glow
        Behavior on color {
            ColorAnimation { duration: 1000; from: "white"; to: "#ffcccc"; easing.type: Easing.InOutSine; loops: Animation.Infinite; reversible: true }
        }
    }

    // Animated progress bar at bottom
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

            // Animate the progress bar
            Behavior on width {
                NumberAnimation { duration: 2000; easing.type: Easing.InOutQuad }
            }

            Component.onCompleted: {
                width = progressBar.width * 0.7  // animated fill
            }
        }
    }
}
