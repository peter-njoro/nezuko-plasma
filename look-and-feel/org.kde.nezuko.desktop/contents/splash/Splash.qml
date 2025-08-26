/*
    SPDX-FileCopyrightText: 2023 Nezuko Theme
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.kirigami 2 as Kirigami

Rectangle {
    id: root
    color: "black"
    property int stage

    onStageChanged: {
        if (stage == 2) {
            introAnimation.running = true;
        } else if (stage == 5) {
            introAnimation.target = busyIndicator;
            introAnimation.from = 1;
            introAnimation.to = 0;
            introAnimation.running = true;
        }
    }

    // Liquid glass overlay
    Rectangle {
        anchors.fill: parent
        color: "#ffffff11"
        radius: 20
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                anchors.fill: parent;
                color: "white"
                radius: 20
            }
        }
    }

    // Background image
    Image {
        anchors.fill: parent
        source: "images/background.png"
        fillMode: Image.PreserveAspectCrop
        opacity: 0.8
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: 0

        Image {
            id: logo
            readonly property real size: Kirigami.Units.gridUnit * 8

            anchors.centerIn: parent
            asynchronous: true
            source: "images/nezuko.svg"
            sourceSize.width: size
            sourceSize.height: size

            // Pulsating glow effect
            Behavior on opacity {
                NumberAnimation {
                    duration: 1200
                    easing.type: Easing.InOutSine
                }
            }
        }

        // Animated loading indicator
        Image {
            id: busyIndicator
            y: parent.height - (parent.height - logo.y) / 2 - height/2
            anchors.horizontalCenter: parent.horizontalCenter
            asynchronous: true
            source: "images/loading-spinner.svg"
            sourceSize.height: Kirigami.Units.gridUnit * 2
            sourceSize.width: Kirigami.Units.gridUnit * 2

            RotationAnimator on rotation {
                id: rotationAnimator
                from: 0
                to: 360
                duration: 1500
                loops: Animation.Infinite
                running: Kirigami.Units.longDuration > 1
            }

            // Glow effect
            layer.enabled: true
            layer.effect: Glow {
                color: "#ff66aa"
                radius: 8
                samples: 17
            }
        }

        // Nezuko text with animation
        Text {
            id: titleText
            anchors {
                bottom: busyIndicator.top
                bottomMargin: Kirigami.Units.gridUnit * 2
                horizontalCenter: parent.horizontalCenter
            }
            text: "Nezuko"
            font.pixelSize: Kirigami.Units.gridUnit * 3
            font.bold: true
            color: "white"

            // Pulsating glow animation
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                NumberAnimation {
                    from: 0.7;
                    to: 1.0;
                    duration: 800;
                    easing.type: Easing.InOutQuad
                }
                NumberAnimation {
                    from: 1.0;
                    to: 0.7;
                    duration: 800;
                    easing.type: Easing.InOutQuad
                }
            }

            layer.enabled: true
            layer.effect: Glow {
                color: "#ff66aa"
                radius: 10
                samples: 17
                spread: 0.3
            }
        }

        // Progress bar
        Rectangle {
            id: progressBar
            width: parent.width * 0.6
            height: Kirigami.Units.gridUnit / 2
            color: "#ffffff22"
            radius: height / 2
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: busyIndicator.bottom
                topMargin: Kirigami.Units.gridUnit * 2
            }

            Rectangle {
                id: progressFill
                width: 0
                height: parent.height
                color: "#ff66aa"
                radius: height / 2

                SequentialAnimation on width {
                    loops: Animation.Infinite
                    NumberAnimation {
                        from: 0;
                        to: progressBar.width;
                        duration: 2000;
                        easing.type: Easing.InOutQuad
                    }
                    NumberAnimation {
                        from: progressBar.width;
                        to: 0;
                        duration: 2000;
                        easing.type: Easing.InOutQuad
                    }
                }

                layer.enabled: true
                layer.effect: Glow {
                    color: "#ff66aa"
                    radius: 4
                    samples: 9
                }
            }
        }
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: Kirigami.Units.veryLongDuration * 2
        easing.type: Easing.InOutQuad
    }
}