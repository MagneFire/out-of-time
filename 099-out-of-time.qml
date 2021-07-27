/*
 * Copyright (C) 2021 - Darrel Griët <IDaNLContact@gmail.com>
 *               2018 - Timo Könnecke <el-t-mo@arcor.de>
 *               2016 - Sylvia van Os <iamsylvie@openmailbox.org>
 *               2015 - Florent Revest <revestflo@gmail.com>
 *               2012 - Vasiliy Sorokin <sorokin.vasiliy@gmail.com>
 *                      Aleksey Mikhailichenko <a.v.mich@gmail.com>
 *                      Arto Jalkanen <ajalkane@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 2.1 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.1
import Nemo.Configuration 1.0
import Qt.labs.folderlistmodel 2.1
import org.asteroid.utils 1.0

Item {
    id: root

    property bool displayOn: true
    property bool isDesktop: (typeof(desktop) !== "undefined")
    property bool isApp: !isDesktop && !isSettings
    property bool isSettings: (typeof(layerStack) !== "undefined")

    // This holds the intermediate watchface source
    // needed to keep track of what the previous watchface was when it changed.
    property var newWatchFaceSource

    ConfigurationValue {
        id: previousWatchFaceSource
        key: "/outoftime/watchface"
        defaultValue: "file:///usr/share/asteroid-launcher/watchfaces/000-default-digital.qml"
    }

    ConfigurationValue {
        id: currentWatchFaceSource
        key: "/desktop/asteroid/watchface"
        defaultValue: "file:///usr/share/asteroid-launcher/watchfaces/000-default-digital.qml"
        onValueChanged: {
            // Only keep track of watchface changes in non-desktop(i.e. settings) mode.
            if (!isDesktop) {
                previousWatchFaceSource.value = newWatchFaceSource
                newWatchFaceSource = value
            }
        }
    }

    Timer {
        id: watchfaceTimer
        interval: 150
        repeat: false
        onTriggered: if (isDesktop) watchface.source = previousWatchFaceSource.value
    }

    Component.onCompleted: {
        newWatchFaceSource = currentWatchFaceSource.value
        watchfaceTimer.start()
    }

    Connections {
        target: compositor
        function onDisplayOn() {
            displayOn = true
        }
        function onDisplayOff() {
            displayOn = false
        }
    }

    Item {
        id: layer2mask
        width: parent.width
        height: parent.height
        visible: true
        opacity: 0.0
        layer.enabled: true
        layer.smooth: true

        Rectangle {
            anchors.fill: parent
            color: "black"
        }

        AnimatedImage {
            id: animation
            cache: isSettings ? false : true
            anchors.fill: parent
            scale: displayOn ? 2.0 : 0.5
            fillMode: Image.PreserveAspectFit
            paused: !displayOn
            source: "file:///usr/share/asteroid-launcher/watchfaces-img/out-of-time-img.gif"
            Behavior on scale { NumberAnimation { duration: 200} }
            transform: Rotation {
                id: animationRotation
                origin.x: root.width/2
                origin.y: 0
                angle: displayOn ? 0 : -40
                Behavior on angle { NumberAnimation { duration: 200} }
            }
        }

        Loader {
            id: watchface
            anchors.fill: parent
            active: isDesktop
            visible: isDesktop
            opacity: visible ? 1.0 : 0.0
        }
    }

    Rectangle {
        id: _mask
        anchors.fill: layer2mask
        color: Qt.rgba(0, 1, 0, 0)
        visible: true

        Rectangle {
            anchors.fill: parent
            radius: DeviceInfo.hasRoundScreen ? width/2 : 0
        }

        layer.enabled: true
        layer.samplerName: "maskSource"
        layer.effect: ShaderEffect {
            property variant source: layer2mask
            fragmentShader: "
                    varying highp vec2 qt_TexCoord0;
                    uniform highp float qt_Opacity;
                    uniform lowp sampler2D source;
                    uniform lowp sampler2D maskSource;
                    void main(void) {
                        gl_FragColor = texture2D(source, qt_TexCoord0.st) * (texture2D(maskSource, qt_TexCoord0.st).a) * qt_Opacity;
                    }
                "
        }
    }
}