import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    width: 640
    height: 480
    color: "#aa000000"   // semi-transparent black

    Image {
        anchors.fill: parent
        source: "images/background.png"
        fillMode: Image.PreserveAspectCrop
    }

    Text {
        anchors.centerIn: parent
        text: "Nezuko"
        font.pixelSize: 48
        color: "white"
        opacity: 0.9
    }

    Rectangle {
        id: progressBar
        width: parent.width * 0.6
        height: 6
        color: "#ffffff55"
        radius: 3
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50

        Rectangle {
            width: progressBar.width * 0.4
            height: progressBar.height
            color: "#ffffffcc"
            radius: 3
            anchors.left: parent.left
        }
    }
}
