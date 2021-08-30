import QtQuick 2.9
import QtQuick.Controls 2.12

ApplicationWindow {
    id: mainWindow
    objectName: "mainWindow"
    width: 450
    height: 750
    visible: false
    title: "MILA"

    signal loginFinish()
    Connections{
        target: mainWindow
        function onLoginFinish(){
            mainWindow.visible = true
        }
    }

    StackView {
        id: stackView
        objectName: "stackView"
        anchors.fill: parent
        initialItem: ContactPage {}
    }
}
