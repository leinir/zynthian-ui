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
import QtQuick.Window 2.1
import org.kde.kirigami 2.6 as Kirigami

import "components" as ZComponents
import "components/private" as ZComponentsPrivate
import "pages" as Pages

Kirigami.AbstractApplicationWindow {
    id: root

    readonly property PageScreenMapping pageScreenMapping: PageScreenMapping {}
    readonly property Item currentPage: screensLayer.layers.depth > 1 ? modalScreensLayer.currentItem : screensLayer.currentItem

    function showConfirmationDialog() {
        confirmDialog.open()
    }
    function hideConfirmationDialog() {
        confirmDialog.close()
    }

    function goBack() {
        if (root.currentPage && root.currentPage.hasOwnProperty("previousScreen") && root.currentPage.previousScreen.length > 0) {
            if (screensLayer.layers.depth > 1) {
                zynthian.current_modal_screen_id = root.currentPage.previousScreen;
            } else {
                zynthian.current_screen_id = root.currentPage.previousScreen;
            }
        } else {
            zynthian.go_back();
        }
    }

    width: screen.width
    height: screen.height

    header: ZComponents.Breadcrumb {
        //height: Math.max(implicitHeight, Kirigami.Units.gridUnit * 3)
        layerManager: screensLayer.layers
        pageRow: screensLayer
        modalPageRow: modalScreensLayer
        leftHeaderControl: ZComponentsPrivate.BreadcrumbButton {
            id: homeButton
            implicitWidth: height
            icon.name: "go-home"
            icon.color: customTheme.Kirigami.Theme.textColor
            rightPadding: Kirigami.Units.gridUnit
            onClicked: zynthian.current_screen_id = 'main'
            checkable: false
            checked: zynthian.current_screen_id === 'main'
        }
        rightHeaderControl: ZComponents.StatusInfo {}
    }
    pageStack: screensLayer
    ScreensLayer {
        id: screensLayer
        parent: root.contentItem
        anchors.fill: parent
        initialPage: [root.pageScreenMapping.pageForScreen('main'), root.pageScreenMapping.pageForScreen('layer')]
    }

    ModalScreensLayer {
        id: modalScreensLayer
        visible: false
    }

    CustomTheme {
        id: customTheme
    }

    background: Rectangle {
        Kirigami.Theme.inherit: false
        // TODO: this should eventually go to Window and the panels to View
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        color: Kirigami.Theme.backgroundColor
    }

    Instantiator {
        model: zynthian.keybinding.key_sequences_model
        delegate: Shortcut {
            //enabled: zynthian.keybinding.enabled
            sequence: model.display
            context: Qt.ApplicationShortcut
            onActivated: zynthian.process_keybinding_shortcut(model.display)
            onActivatedAmbiguously: zynthian.process_keybinding_shortcut(model.display)
        }
    }

    QQC2.Dialog {
        id: confirmDialog
        x: root.width / 2 - width / 2
        y: root.height / 2 - height / 2
        dim: true
        modal: true
        width: Math.round(Math.max(implicitWidth, root.width * 0.8))
        height: Math.round(Math.max(implicitHeight, root.height * 0.8))
        contentItem: Kirigami.Heading {
            level: 2
            text: zynthian.confirm.text
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        onAccepted: zynthian.confirm.accept()
        onRejected: zynthian.confirm.reject()
        footer: QQC2.Control {
            leftPadding: confirmDialog.leftPadding
            topPadding: Kirigami.Units.largeSpacing
            rightPadding: confirmDialog.rightPadding
            bottomPadding: confirmDialog.bottomPadding
            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing
                QQC2.Button {
                    Layout.fillWidth: true
                    text: qsTr("No")
                    onClicked: confirmDialog.reject()
                }
                QQC2.Button {
                    Layout.fillWidth: true
                    text: qsTr("Yes")
                    onClicked: confirmDialog.accept()
                }
            }
        }
    }

    ZComponents.ModalLoadingOverlay {
        parent: root.contentItem.parent
        anchors.fill: parent
    }

    footer: ZComponents.ActionBar {
        currentPage: root.currentPage
       // height: Math.max(implicitHeight, Kirigami.Units.gridUnit * 3)
    }
}

