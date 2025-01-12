/* -*- coding: utf-8 -*-
******************************************************************************
ZYNTHIAN PROJECT: Zynthian Qt GUI

Main Class and Program for Zynthian GUI

Copyright (C) 2021 Marco Martin <mart@kde.org>

******************************************************************************

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

For a full copy of the GNU General Public License see the LICENSE.txt file.

******************************************************************************
*/

import QtQuick 2.11
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.2 as QQC2
import org.kde.kirigami 2.4 as Kirigami


Card {
    id: root

    // instance of zynthian_gui_controller.py, TODO: should be registered in qml?
    property QtObject controller

    Layout.fillWidth: true
    Layout.fillHeight: true

    readonly property string valueType: {
        //FIXME: Ugly heuristics
        if (!root.controller) {
            return "int";
        }
        if (root.controller.value_type === "int" && root.controller.max_value - root.controller.value0 === 1) {
            return "bool";
        }
        if (root.controller.value_print === "on" || root.controller.value_print === "off") {
            return "bool";
        }
        return root.controller.value_type;
    }

    contentItem: ColumnLayout {
        Kirigami.Heading {
            text: root.controller ? root.controller.title : ""
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            level: 2
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            // TODO: manage logarythmic controls?
            QQC2.Dial {
                id: dial
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                    horizontalCenter: parent.horizontalCenter
                    margins: Kirigami.Units.largeSpacing
                }
                width: height
                stepSize: root.controller ? (root.controller.step_size === 0 ? 1 : root.controller.step_size) : 0
                value: root.controller ? root.controller.value : 0
                from: root.controller ? root.controller.value0 : 0
                to: root.controller ? root.controller.max_value : 0
                scale: root.valueType !== "bool"
                enabled: root.valueType !== "bool"
                onMoved: root.controller.value = value


                // HACK for default style
                Binding {
                    target: dial.background
                    property: "color"
                    value: Kirigami.Theme.highlightColor
                }
                Binding {
                    target: dial.handle
                    property: "color"
                    value: Kirigami.Theme.highlightColor
                }
                Kirigami.Heading {
                    anchors.centerIn: parent
                    text: root.controller ? root.controller.value_print :  ""
                }
                /*Behavior on value {
                    enabled: !dialMouse.pressed
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }*/
                //TODO: with Qt >= 5.12 replace this with inputMode: Dial.Vertical
                MouseArea {
                    id: dialMouse
                    anchors.fill: parent
                    preventStealing: true
                    property real startY
                    property real startValue
                    onPressed: {
                        startY = mouse.y;
                        startValue = dial.value
                    }
                    onPositionChanged: {
                        let delta = mouse.y - startY;
                        let value = Math.max(dial.from, Math.min(dial.to, startValue - (dial.to / dial.stepSize) * (delta*dial.stepSize/(Kirigami.Units.gridUnit*10))));
                        if (root.valueType === "int" || root.valueType === "bool") {
                            value = Math.round(value);
                        }
                        root.controller.value = value;
                    }
                }
            }
            MouseArea {
                anchors.fill: parent
                scale: root.valueType === "bool"
                enabled: root.valueType === "bool"
                onClicked: root.controller.value = root.controller.value == root.controller.value0 ? root.controller.max_value : root.controller.value0
                /*Behavior on scale {
                    NumberAnimation {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }*/
                QQC2.Switch {
                    id: switchControl
                    anchors.centerIn: parent
                    width: Math.min(Math.round(parent.width / 4 * 3), Kirigami.Units.gridUnit * 5)
                    height: Kirigami.Units.gridUnit * 3
                    checked: root.controller && root.controller.value !== root.controller.value0
                    onToggled: root.controller.value = checked ? root.controller.max_value : root.controller.value0

                    // HACK for default style
                   /* Binding {
                        target: switchControl.indicator
                        property: "color"
                        value: switchControl.checked ? Kirigami.Theme.highlightColor : switchControl.palette.midlight
                    }*/

                    Kirigami.Heading {
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.bottom
                            //bottomMargin: Kirigami.Units.gridUnit * 2
                        }
                        text: root.controller ? root.controller.value_print : ""
                    }
                }
            }
        }

        // just for debug purposes
        /*QQC2.Label {
            text: "t"+ root.controller.value_type + " s" + root.controller.step_size + " f"+ root.controller.value0 + "\n t" + root.controller.max_value + " v" +root.controller.value
        }*/
        QQC2.Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.controller ? root.controller.midi_bind : ""
        }
    }
}
