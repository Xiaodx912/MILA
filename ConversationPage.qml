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
import QtQuick.Layouts
import QtQuick.Controls

import moe.hareru.MILA

Page {
    id: root

    property string inConversationWith

    header: ChatToolBar {
        height: 48
        ToolButton {
            id:backBtn
            font.family: "FontAwesome"
            text: "\uf104"
            contentItem: Text{
                text: backBtn.text
                font: backBtn.font
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            font.pixelSize: 30
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.StackView.view.pop()
        }

        Label {
            id: pageTitle
            text: inConversationWith
            font.pixelSize: 20
            anchors.centerIn: parent
        }
    }
    footer:ChatToolBar{
        id:mesBlock
        height: 0
        background: Rectangle {
            id: emojiDrawer
            color: "#F5F5F5"
            Rectangle{
                height: 1
                color: "#BDBDBD"
                width: parent.width
                anchors.top: parent.top
            }
        }

        property variant emojiArray: ["\ud83d\ude00", "\ud83d\ude01","\ud83d\ude02" ,"\ud83d\ude31","\ud83d\ude04",
            "\ud83d\ude05","\ud83d\ude0d","\ud83d\ude07","\ud83d\ude08","\ud83d\ude2d","\ud83e\udd75","\ud83e\udd21"
            ,"\ud83d\ude12","\ud83d\ude28","\ud83e\udd15","\ud83d\udc4a","\ud83d\ude9b","\ud83d\udc4d","\ud83e\udd14",
            "\ud83e\udd2d"]
        Grid {
            id:emojiBlock
            leftPadding: 28
            rows:4
            columns: 5
            rowSpacing: 5
            columnSpacing: 32
            Layout.fillWidth: true
            anchors.fill: parent
            anchors.margins: 8
            Repeater {
                anchors.fill: parent
                model: emojiBlock.rows*emojiBlock.columns
                ToolButton {
                    id: emojiItem
                    text: mesBlock.emojiArray[index]
                    contentItem: Text{
                        text: emojiItem.text
                        font.pixelSize: 35
                        color: "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.family: "Courier"
                    }
                    onClicked: {
                        console.log("emoji clicked")
                        messageField.text=messageField.text+emojiItem.text
                    }
                }

            }
        }
        NumberAnimation {
            id: emojiBlockOpen
            target: mesBlock
            property: "height"
            from:mesBlock.height
            to: 240-mesBlock.height
            easing.type: Easing.InOutQuad
            duration: 300
        }

    }


    ColumnLayout {
        anchors.fill: parent

        ListView {
            id: listView
            //Layout.rightMargin: 20
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: pane.leftPadding + messageField.leftPadding
            displayMarginBeginning: 40
            displayMarginEnd: 40
            verticalLayoutDirection: ListView.BottomToTop
            spacing: 12
            model: SqlConversationModel {
                acc: _accMgr
                recipient: inConversationWith // set by StackView push in ContactPage
            }
            delegate: Column {
                anchors.right: sentByMe ? listView.contentItem.right : undefined
                spacing: 6

                readonly property bool sentByMe: model.recipient !== _accMgr.getUsername();

                Row {
                    id: messageRow
                    spacing: 6
                    anchors.right: sentByMe ? parent.right : undefined

                    Image {
                        id: avatar
                        source: sentByMe?"":"https://gravatar.loli.net/avatar/?"+_accMgr.getEHash(model.author)+"s=40"
                        onStatusChanged: {
                            if (!sentByMe && avatar.status==Image.Error){
                                avatar.source="https://gravatar.loli.net/avatar/?s=40"
                            }
                        }
                    }

                    Rectangle {
                        width: Math.min(messageText.implicitWidth + 24, listView.width - avatar.width - messageRow.spacing)
                        height: messageText.implicitHeight + 24
                        color: sentByMe ? "lightgrey" : "steelblue"
                        radius: 10

                        Label {
                            id: messageText
                            text: model.message
                            color: sentByMe ? "black" : "white"
                            anchors.fill: parent
                            anchors.margins: 12
                            wrapMode: Label.Wrap
                        }
                    }
                }

                Label {
                    id: timestampText
                    text: Qt.formatDateTime(model.timestamp, " MMM d hh:mm")
                    color: "lightgrey"
                    anchors.right: sentByMe ? parent.right : undefined
                }
            }
            ScrollBar.vertical: ScrollBar {
                id: scrollbar
                width: 8
                anchors.right: parent.right
                anchors.rightMargin: -10
            }

        }

        Pane {
            id: pane
            Layout.fillWidth: true

            RowLayout {
                width: parent.width

                TextArea {
                    id: messageField
                    width: parent.width-100
                    anchors.left: mesBlock.left
                    anchors.leftMargin: 5
                    Layout.fillWidth: true
                    placeholderText: qsTr("说点什么?")
                    wrapMode: TextArea.Wrap
                }

                Button {
                    id: sendButton
                    text: "发送"
                    contentItem: Text{
                        text: sendButton.text
                        font: sendButton.font
                        color: "#fffafa"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    anchors.right: parent.right
                    anchors.rightMargin: 40
                    Component.onCompleted: sendButton.background.color="#8BC34A"
                    enabled: messageField.length > 0
                    onClicked: {
                        listView.model.sendMessage(inConversationWith, messageField.text)
                        messageField.text = ""
                    }
                }

                ToolButton{
                    id:emojiButton
                    text: "\uf118"
                    anchors.right: parent.right
                    anchors.rightMargin: -5
                    font.family: "FontAwesome"
                    font.pixelSize: 30
                    contentItem: Text{
                        text: emojiButton.text
                        font: emojiButton.font
                        color: "#000000"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    onClicked: {
                        emojiBlockOpen.start()
                    }
                }
            }
        }
    }
}

