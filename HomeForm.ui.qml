import QtQuick 2.12
import QtQuick.Controls 2.5

Page {
    id: page
    width: 600
    height: 400

    title: qsTr("Home")

    Label {
        text: qsTr("You are on the home page.")
        anchors.centerIn: parent
    }
    TextField {
        id: pField
        y: 260
        width: 200
        height: 60

        anchors.horizontalCenter: parent.horizontalCenter
        placeholderText: qsTr("Password")
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.66}
}
##^##*/
