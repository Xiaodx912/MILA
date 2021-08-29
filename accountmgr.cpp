#include <QDebug>
#include <QObject>
#include <QString>

#include <QElapsedTimer>
#include <QCoreApplication>
#include <QTcpSocket>
#include <QJsonObject>
#include <QJsonDocument>

#include "accountmgr.h"

#include <string.h>
#include <string>

//#define sIP "82.156.25.45"
#define sIP "127.0.0.1"
#define sPORT 5433

constexpr size_t HASH_STRING_PIECE(const char *string_piece,size_t hashNum=0){
    return *string_piece?HASH_STRING_PIECE(string_piece+1,(hashNum*131)+*string_piece):hashNum;
}
constexpr size_t operator "" _HASH(const char *string_pice,size_t){
    return HASH_STRING_PIECE(string_pice);
}
size_t CALC_STRING_HASH(const std::string& str){
    return HASH_STRING_PIECE(str.c_str());
}//for string switch

void AccountMgr::LoginWith(const QString &uname,const QString &pwd,const QString &btnState){
    username=uname;
    password=pwd;
//        QElapsedTimer t;
//        t.start();
//        while(t.elapsed()<3000)
//            QCoreApplication::processEvents();
    QString mode = btnState=="Login"?"login":"reg";
    qDebug()<<mode;
    if(sendJsonObj(makeIdenJson(mode))==-1) qDebug()<<"send login pkg err";
}

int AccountMgr::sendJsonObj(QJsonObject msg){
    if (clientSocket==nullptr)init_socket(false);
    QJsonDocument req(msg);
    QByteArray reqStr = req.toJson(QJsonDocument::Compact);
    qDebug()<<"sending json: "<<reqStr;
    int stat = clientSocket->write(reqStr);
    return stat;
}

void AccountMgr::onRecvData(){
    char recvBuffer[65536] = {0};
    if (clientSocket->read(recvBuffer,65536)==-1){
        qDebug()<<"recv Err";
        return;
    }
    QJsonDocument ret=QJsonDocument::fromJson(recvBuffer);
    QJsonObject msgRet = ret.object();
    qDebug()<<"recv json: "<<msgRet;
    switch(CALC_STRING_HASH(msgRet["type"].toString().toStdString())){
    case "login_re"_HASH: handleLoginReply(msgRet); break;
    case "reg_re"_HASH: handleRegReply(msgRet); break;
    case "msg_re"_HASH: handleMsgSendReply(msgRet); break;
    default: qDebug("uknown type"); break;
    }
}

void AccountMgr::handleLoginReply(QJsonObject json){
    if (json["stats"].toString()=="OK"){
        qDebug()<<"login success";
        emit loginSuccess();
    }else {
        qDebug()<<"login fail";
        emit loginFail(json["stats"].toString());
    }
}
void AccountMgr::handleRegReply(QJsonObject json){
    if (json["stats"].toString()=="OK"){
        qDebug()<<"register success";
        emit loginSuccess();
    }else {
        qDebug()<<"register fail";
        emit loginFail(json["stats"].toString());
    }
}
void AccountMgr::handleMsgSendReply(QJsonObject json){

}

void AccountMgr::init_socket(bool force){
    if ((clientSocket != nullptr)&&!force) return;
    clientSocket = new QTcpSocket();
    clientSocket->connectToHost(sIP,sPORT);
    if (clientSocket->waitForConnected()) connect(clientSocket, SIGNAL(readyRead()), this, SLOT(onRecvData()));
    else qDebug()<<"socket connect failed";
}

QJsonObject AccountMgr::makeIdenJson(QString type){
    QJsonObject json;
    json.insert("type", type);
    json.insert("username", username);
    json.insert("password", password);
    return json;
}
