import QtQuick 2.9
import QtQuick.Controls 2.4

ApplicationWindow {
    id: loginWindow
    objectName: "loginWindow"
    width: 480
    height: 640
    visible: true
    title: qsTr("Login")
    color: "#00000000"
    flags: Qt.FramelessWindowHint

    signal doLogin(string username,string pwd,string state,string email)
    signal loginSuccess()
    signal regSuccess()
    signal loginFail(string reason)
    signal goToMainView()

    Timer {id: timer}
    function delay(delayTime, cb) {
        timer.interval = delayTime;
        timer.repeat = false;
        timer.triggered.connect(cb);
        timer.start();
    }

    Rectangle{
        id: windowBg
        radius: 20
        opacity: 1
        color: "#F5F5F5"
        anchors.fill: parent
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
        Rectangle{
            radius: parent.radius
            id: iconBg
            color: "#00BCD4"
            width: parent.width
            height: 220
            Rectangle{
                id:bgRadiusPatch
                anchors.bottom: parent.bottom
                color: parent.color
                width: parent.width
                height: parent.radius
            }
            Text{
                text: "\uf2b7"
                font.family: closeBtn.font
                font.pixelSize: 50
                color: "#B2EBF2"
                anchors.verticalCenter: parent.verticalCenter
                x: 120
                Text {
                    text: "MILA"
                    font.family: "Advent Pro Light"
                    font.pixelSize: 50
                    color: "#FFFFFF"
                    x: parent.width+60
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }


    ToolButton{
        id:closeBtn
        text: "\uf00d"
        font.family: "FontAwesome"
        font.pixelSize: Qt.application.font.pixelSize * 1.6
        contentItem: Text{
            text: closeBtn.text
            font: closeBtn.font
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        //anchors.right: parent.right
        //anchors.top: parent.top
        x: loginWindow.width-20-width/2
        y: 20-height/2
        height: 40
        width: 40
        Component.onCompleted: closeBtn.background.color ="#F44336"

        ParallelAnimation{
            id: loginWindowCloseAni
            NumberAnimation {
                target: closeBtn
                property: "height"
                to: 2500
                duration: 800
                easing.type: Easing.InQuint
            }
            NumberAnimation {
                target: closeBtn
                property: "width"
                to: 2500
                duration: 800
                easing.type: Easing.InQuint
            }
            ColorAnimation {
                target: closeBtn.background
                property: "color"
                to: "#00F44336"
                duration: 800
                easing.type: Easing.InQuart
            }
        }

        onClicked: {
            loginWindowCloseAni.start()
            delay(800, function(){loginWindow.close()})
        }
    }


    TextField {
        id: usernameField
        y: 250
        width: loginWindow.width*0.5
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("Username")
        placeholderTextColor: "#757575"
        selectByMouse: true
    }

    TextField {
        id: pwdField
        y: usernameField.y+usernameField.height+30
        width: loginWindow.width*0.5
        height: 60
        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("Password")
        placeholderTextColor: "#757575"
        echoMode: TextField.Password
        selectByMouse: true
    }

    TextField {
        id: emailField
        y: pwdField.y+60
        width: loginWindow.width*0.5
        height: 0
        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("Email")
        placeholderTextColor: "#757575"
        selectByMouse: true
        enabled: false
        opacity: 0
    }

    ParallelAnimation{
        id: registerAppearAni
        NumberAnimation {
            target: emailField
            property: "y"
            from:emailField.y
            to: emailField.y==pwdField.y+60?pwdField.y+pwdField.height+30:pwdField.y+60
            duration: 800
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: emailField
            property: "opacity"
            from:emailField.opacity
            to:1-emailField.opacity
            duration: 800
        }
        NumberAnimation {
            target: emailField
            property: "height"
            from:emailField.height
            to:60-emailField.height
            duration: 600
            easing.type: Easing.InOutQuad
        }
        NumberAnimation {
            target: loginBtn
            property: "y"
            from:loginBtn.y
            to:usernameField.y+280+usernameField.y+210-loginBtn.y
            duration: 800
            easing.type: Easing.InOutQuad
        }
    }

    Button {
        id: loginBtn
        y: usernameField.y+210
        width: 200
        height: 60
        text: "Login"
        contentItem: Text{
            text: loginBtn.text
            font: loginBtn.font
            color: "#FFFFFF"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        anchors.horizontalCenter: parent.horizontalCenter
        Component.onCompleted: loginBtn.background.color="#607D8B"

        BusyIndicator{
            id: logingInd
            running: false
            x: parent.width+30
            anchors.verticalCenter: parent.verticalCenter
            Text{
                id: logingResultMark
                opacity: 0
                font.pixelSize: 50
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.family: closeBtn.font
                color: "#8BC34A"
            }
            SequentialAnimation{
                id: logingResultShow
                NumberAnimation {
                    target: logingResultMark
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 1200
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: logingResultMark
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 800
                    easing.type: Easing.InQuart
                }
            }
        }
        onClicked: {
            if (usernameField.text == ""){
                usernameField.placeholderTextColor="#F44336"
                return
            }
            if (pwdField.text == ""){
                pwdField.placeholderTextColor="#F44336"
                return
            }
            modeSwBtn.enabled=false
            logingInd.running=true
            loginWindow.doLogin(usernameField.text,pwdField.text,loginBtn.text,emailField.text)
        }
        ColorAnimation {
            id: btnSwAni
            target: loginBtn.background
            property: "color"
            from: loginBtn.background.color
            to: (loginBtn.background.color=="#607d8b")?"#0097A7":"#607d8b"
            duration: 200
        }
        RoundButton {
            id: modeSwBtn
            x:-25
            anchors.verticalCenter: parent.verticalCenter
            text: "\uf021"
            font.family: closeBtn.font
            font.pixelSize: 20
            contentItem: Text{
                text: modeSwBtn.text
                font: modeSwBtn.font
                color: "#212121"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            Component.onCompleted: modeSwBtn.background.color="#B2EBF2"
            onClicked: {
                loginBtn.text = (loginBtn.text=="Register"?"Login":"Register")
                btnSwAni.start()
                registerAppearAni.start()
                emailField.enabled= !emailField.enabled
            }
        }
    }


    Connections{
        target: loginWindow
        function onLoginSuccess(){ loginWindow.showLoginResult(true,"",true) }
        function onRegSuccess(){ loginWindow.showLoginResult(true,"",false) }
        function onLoginFail(reason){ loginWindow.showLoginResult(false,reason) }
    }
    function showLoginResult(isSuc,reason,goMainView){
        logingInd.running=false
        logingResultMark.text=isSuc?"\uf058":"\uf057"
        logingResultMark.color=isSuc?"#8BC34A":"#F44336"
        logingResultShow.start()
        console.log("qml_ev:login "+(isSuc?"success":"fail"))
        if (!isSuc){console.log(reason)}
        if (loginBtn.text=="Register" && isSuc){
            loginBtn.text = (loginBtn.text=="Register"?"Login":"Register")
            btnSwAni.start()
        }
        if (goMainView && isSuc){
            delay(2000, function(){
                loginWindow.goToMainView()
                loginWindow.visible=false
            })
        }
        modeSwBtn.enabled=true
    }

}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.5}
}
##^##*/


