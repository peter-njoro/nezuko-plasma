import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Animations 2.15
import QtMultimedia 5.15



Window {
        id: root
        width: 640
        height: 480
        visible: true
        flags: Qt.FramelessWindowHint
        color: "#000000"

        property string resourcePath: Qt.resolvedUrl(appDir + "/../share/plasma/look-and-feel/org.kde.nezuko/contents/splash")

        // Video background with fallback
    Loader {
        id: backgroundLoader
        anchors.fill: parent
        sourceComponent: Video {
            id: bgVideo
            source: resourcePath + "/videos/background.mp4"
            autoPlay: true
            loops: MediaPlayer.Infinite
            fillMode: VideoOutput.PreserveAspectCrop
            onErrorChanged: {
                if (error !== MediaPlayer.NoError) {
                    backgroundLoader.sourceComponent = imageComponent
                }
            }
        }
    }
    Component {
        id: imageComponent
        Image {
            source: resourcePath + "/images/background.png"
            fillMode: Image.PreserveAspectCrop
        }
    }

    // Fallback static image
    Image {
        anchors.fill: parent
        source: "images/background.png"
        fillMode: Image.PreserveAspectCrop
        visible: !bgVideo.visible
    }

    // Liquid glass overlay
    Rectangle {
        anchors.fill: parent
        color: "#ffffff11"
        radius: 20
    }

    // Glow animated title text
    Text {
        id: titleText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        text: "Nezuko"
        font.pixelSize: 60
        font.bold: true
        color: "white"

        Behavior on color {
            ColorAnimation {
                duration: 1000
                from: "white"
                to: "#ff9999"
                loops: Animation.Infinite
                reversible: true
                easing.type: Easing.InOutSine
            }
        }

        SequentialAnimation on scale {
            loops: Animation.Infinite
            NumberAnimation { from: 0.9; to: 1.1; duration: 800; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 1.1; to: 0.9; duration: 800; easing.type: Easing.InOutQuad }
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
            height: parent.height
            color: "#ff9999"
            radius: 4

            Behavior on width {
                NumberAnimation { duration: 3000; easing.type: Easing.InOutQuad }
            }

            Component.onCompleted: width = progressBar.width
        }
    }

    // Auto-close splash after 5 seconds
    Timer {
        interval: 5000
        running: true
        repeat: false
        onTriggered: root.close()
    }
}

