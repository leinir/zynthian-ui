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
import "pages" as Pages

Kirigami.PageRow {
    id: root
    defaultColumnWidth: width
    globalToolBar.style: Kirigami.ApplicationHeaderStyle.None
    separatorVisible: false

    Component.onCompleted: {
        zynthian.current_screen_id_changed()
    }

    data: [
        Connections {
            target: zynthian
            onCurrent_screen_idChanged: {
                print("SCREEN ID CHANGED: "+zynthian.current_screen_id);

                // This should never happen
                if (zynthian.current_screen_id.length === 0) {
                    print("Warning: empty screen requested")
                    return;
                }

                // Skipping modal screen requests
                if (zynthian.current_screen_id === zynthian.current_modal_screen_id) {
                    return;
                }
                if (root.layers.depth > 1) {
                    root.layers.pop(root)
                }

                for (var i = 0; i < root.depth; ++i) {
                    let child = root.get(i);

                    // It's a MultiSelectorPage
                    if (child.hasOwnProperty("screenIds")) {
                        var j; // if (.. in ..) doesn't work
                        for (j in child.screenIds) {
                            let id = child.screenIds[j];
                            if (id === zynthian.current_screen_id) {
                                root.currentIndex = i;
                                return;
                            }
                        }
                        if (zynthian.current_screen_id in child.screenIds) {
                            root.currentIndex = i;
                            return;
                        }
                    } else if (child.hasOwnProperty("screenId")) {
                        if (child.screenId === zynthian.current_screen_id) {
                            root.currentIndex = i;
                            return;
                        }
                    }
                }
                let file = applicationWindow().pageScreenMapping.pageForScreen(zynthian.current_screen_id);
                if (file.length > 0) {
					root.currentIndex = 1 // HACK to replace whatever page after the 3 columns layers page
                    root.push(file);
                } else {
                    print("Non managed screen " + zynthian.current_screen_id);
                }
            }
        }
    ]
}
