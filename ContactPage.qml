/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick
import QtQuick.Controls

import moe.hareru.MILA

Page {
    id: root

    header: ChatToolBar {
        id: toolBar
        height: 48
        ParallelAnimation{
            id: swTbState
            NumberAnimation {
                target: toolBar
                property: "height"
                duration: 500
                from: toolBar.height
                to: 248-toolBar.height
                easing.type: Easing.InOutQuad
            }
            NumberAnimation {
                target: contNameField
                property: "opacity"
                duration: 500
                from: contNameField.opacity
                to: 1-contNameField.opacity
                easing.type: Easing.InOutQuad
            }
        }


        Label {
            text: qsTr("Contacts")
            color: "#FFFFFF"
            anchors.top: parent.top
            font.pixelSize: 20
            anchors.topMargin: 14
            anchors.horizontalCenter: parent.horizontalCenter
        }
        TextField {
            id: contNameField
            width: parent.width*0.5
            height: 60
            placeholderText: "New Friend?"
            placeholderTextColor: "#414141"
            opacity: 0
            y: 84>parent.height/2?parent.height/2:84
            anchors.horizontalCenter: parent.horizontalCenter
            selectByMouse: true
        }
        RoundButton {
            id: addContBtn
            y: contNameField.y
            width: 60
            height: 60
            text: "\uf234"
            anchors.right: parent.right
            anchors.rightMargin: 15
            font.family: "FontAwesome"
            font.pixelSize: 25
            opacity: contNameField.opacity
            enabled: contNameField.text!=""
            contentItem: Text{
                text: addContBtn.text
                font: addContBtn.font
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            Component.onCompleted: addContBtn.background.color="#607D8B"
            onClicked:{
                console.log("add friend request")
                listView.model.addCont(contNameField.text)
                contNameField.text=""
            }
        }
        RoundButton {
            id: addContPaneExtBtn
            y:toolBar.height-height/2
            width: 50
            height: 50
            text: "\uf067"

            anchors.right: parent.right
            anchors.rightMargin: 20


            font.family: "FontAwesome"
            font.pixelSize: 20
            contentItem: Text{
                text: addContPaneExtBtn.text
                font: addContPaneExtBtn.font
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            Component.onCompleted: addContPaneExtBtn.background.color="#607D8B"
            states: [
                State {name: "normal";PropertyChanges { target: addContPaneExtBtn; rotation: 0 }},
                State {name: "rotated";PropertyChanges { target: addContPaneExtBtn; rotation: 45 }}
            ]
            transitions: Transition { RotationAnimation { duration: 500; direction: RotationAnimation.Shortest }}
            onClicked: {
                addContPaneExtBtn.state = addContPaneExtBtn.state=="rotated"?"normal":"rotated"
                swTbState.start()
            }
        }
    }

    ListView {
        id: listView
        objectName: "listView"
        anchors.fill: parent
        topMargin: 48
        leftMargin: 48
        bottomMargin: 48
        rightMargin: 48
        spacing: 20
        model: SqlContactModel { acc: _accMgr }
        delegate: ItemDelegate {
            text: model.display
            width: listView.width - listView.leftMargin - listView.rightMargin
            height: avatar.implicitHeight
            leftPadding: avatar.implicitWidth + 32
            onClicked: root.StackView.view.push("qrc:/ConversationPage.qml", { inConversationWith: model.display })
            Image {
                id: avatar
                source: "avatarCache/" + model.display.replace(" ", "_") + ".png"
                onStatusChanged: {
                    if (avatar.status==Image.Error){
                        avatar.source="avatarCache/Albert_Einstein.png"
                    }
                }
            }
        }
        signal loginFinish()
        Connections{
            target: listView
            function onLoginFinish(){
                listView.model.initDB()
            }
        }
    }
}

