import QtQuick 2.9
import QtQuick.Controls 2.4

ApplicationWindow {
    id: loginWindow
    width: 480
    height: 640
    visible: true
    title: qsTr("Login")
    color: "#f8f8f8"


    flags: Qt.FramelessWindowHint
    MouseArea {
            anchors.fill: parent
            property int mx: 0
            property int my: 0
            onPressed: {
                mx=mouseX
                my=mouseY
            }
            onPositionChanged: {
                loginWindow.x+=mouseX-mx
                loginWindow.y+=mouseY-my
            }
        }

    ToolButton{
        id:closeBtn
        text: "\u00d7"
        font.family: "FontAwesome"
        font.pixelSize: Qt.application.font.pixelSize * 1.6
        anchors.right: parent.right
        anchors.top: parent.top
        height: 40
        width: 40
        Component.onCompleted: closeBtn.background.color ="#ff4444"
        onClicked: loginWindow.close()
    }


    TextField {
        id: usernameField
        y: 150
        width: loginWindow.width*0.5
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("Username")
        selectByMouse: true
    }

    TextField {
        id: pwdField
        y: 260
        width: loginWindow.width*0.5
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("Password")
        echoMode: TextField.Password
        selectByMouse: true

    }

    Button {
        id: loginBtn
        y: 380
        width: 200
        height: 60
        text: qsTr("Login")
        anchors.horizontalCenter: parent.horizontalCenter
        Component.onCompleted: loginBtn.background.color="#66ccff"

        BusyIndicator{
            id: logingInd
            opacity: 0
            x: parent.width+30
            anchors.verticalCenter: parent.verticalCenter

        }
        NumberAnimation{
            id: logingIndOpaTrans
            target: logingInd
            properties: "opacity"
            from: logingInd.opacity
            to: 1-logingInd.opacity
            duration: 600
        }



        Connections {
            target: loginBtn
            onClicked: {
                console.log(loginBtn.background)
                if (usernameField.text==""){
                    usernameField.placeholderTextColor="red"
                    return
                }
                if (pwdField.text==""){
                    pwdField.placeholderTextColor="red"
                    return
                }
                //loginBtn.background.color="#66ccff"
                logingIndOpaTrans.start()

                console.log("Try login")
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/


