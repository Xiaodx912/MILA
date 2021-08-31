#include "accountmgr.h"

#define sIP "82.156.25.45"
//#define sIP "127.0.0.1"
#define sPORT 54321

constexpr size_t HASH_STRING_PIECE(const char *string_piece,size_t hashNum=0){
    return *string_piece?HASH_STRING_PIECE(string_piece+1,(hashNum*131)+*string_piece):hashNum;
}
constexpr size_t operator "" _HASH(const char *string_pice,size_t){
    return HASH_STRING_PIECE(string_pice);
}
size_t CALC_STRING_HASH(const std::string& str){
    return HASH_STRING_PIECE(str.c_str());
}//for string switch

void AccountMgr::LoginWith(const QString &uname,const QString &pwd,const QString &btnState,const QString &email){
    username=uname;
    password=pwd;
    eml=email;
//        QElapsedTimer t;
//        t.start();
//        while(t.elapsed()<3000)
//            QCoreApplication::processEvents();
    QString mode = btnState=="Login"?"login":"reg";
    if(sendJsonObj(makeIdenJson(mode))==-1){
        qDebug()<<"send login pkg err";
        init_socket(true);
    }
}

int AccountMgr::sendJsonObj(QJsonObject msg){
    if (clientSocket==nullptr)init_socket(false);
    QJsonDocument req(msg);
    QByteArray reqStr = req.toJson(QJsonDocument::Compact);
    qDebug()<<"sending data: "<<reqStr;
    reqStr+='\0';
    int stat = clientSocket->write(reqStr);
    return stat;
}

void AccountMgr::onRecvData(){
    char recvBuffer[65536] = {0};
    if (clientSocket->read(recvBuffer,65536)==-1){
        qDebug()<<"recv Err";
        return;
    }
    qDebug()<<"recv data: "<<QByteArray(recvBuffer);
    QJsonDocument ret=QJsonDocument::fromJson(QByteArray(recvBuffer));
    QJsonObject msgRet = ret.object();
    switch(CALC_STRING_HASH(msgRet["type"].toString().toStdString())){
    case "login_re"_HASH: handleLoginReply(msgRet); break;
    case "reg_re"_HASH: handleRegReply(msgRet); break;
    case "msg_re"_HASH: handleMsgSendReply(msgRet); break;
    case "msg"_HASH: handleIncomingMsg(msgRet); break;
    default: qDebug("uknown type"); break;
    }
}

void AccountMgr::handleLoginReply(QJsonObject json){
    if (json["stats"].toString()=="OK"){
        qDebug()<<"login success";
        initDB();
        if(json.contains("msg")){
            QJsonArray msgArr=json["msg"].toArray();
            qDebug()<<"recv "<<msgArr.size()<<" msg at login";
            while (!msgArr.empty()) {
                QJsonObject msgItem=msgArr.first().toObject();
                msgArr.removeFirst();
                handleIncomingMsg(msgItem);
            }
        }
        emit loginSuccess();
    }else {
        qDebug()<<"login fail";
        emit loginFail(json["stats"].toString());
    }
}
void AccountMgr::handleRegReply(QJsonObject json){
    if (json["stats"].toString()=="OK"){
        qDebug()<<"register success";
        emit regSuccess();

    }else {
        qDebug()<<"register fail";
        emit loginFail(json["stats"].toString());
    }
}
void AccountMgr::handleMsgSendReply(QJsonObject json){
    return;
}

void AccountMgr::initDB(){
    convDB = new QSqlTableModel();
    convDB->setTable("Conversations");
    convDB->setEditStrategy(QSqlTableModel::OnManualSubmit);

    if (!QSqlDatabase::database().tables().contains("Conversations")){
        QSqlQuery query;
        if (!query.exec(
                    "CREATE TABLE IF NOT EXISTS 'Conversations' ("
                    "'author' TEXT NOT NULL,"
                    "'recipient' TEXT NOT NULL,"
                    "'timestamp' TEXT NOT NULL,"
                    "'message' TEXT NOT NULL,"
                    "FOREIGN KEY('author') REFERENCES Contacts ( name ),"
                    "FOREIGN KEY('recipient') REFERENCES Contacts ( name )"
                    ")")) {
            qFatal("Failed to query database: %s", qPrintable(query.lastError().text()));
        }
//        query.exec("INSERT INTO Conversations VALUES('a', 'Ernest Hemingway', '2016-01-07T14:36:06', 'Hello!')");
//        query.exec("INSERT INTO Conversations VALUES('Ernest Hemingway', 'a', '2016-01-07T14:36:16', 'Good afternoon.')");
//        query.exec("INSERT INTO Conversations VALUES('a', 'Albert Einstein', '2016-01-01T11:24:53', '测试！')");
//        query.exec("INSERT INTO Conversations VALUES('Albert Einstein', 'a', '2015-01-07T14:36:16', 'Good morning.')");
//        query.exec("INSERT INTO Conversations VALUES('Hans Gude', 'a', '2015-11-20T06:30:02', 'God morgen. Har du fått mitt maleri?')");
//        query.exec("INSERT INTO Conversations VALUES('a', 'Hans Gude', '2015-11-20T08:21:03', 'God morgen, Hans. Ja, det er veldig fint. Tusen takk! "
//               "Hvor mange timer har du brukt på den?')");
    }

}

void AccountMgr::handleIncomingMsg(QJsonObject json){
    QSqlTableModel* dbPtr = SconvDB==nullptr?convDB:SconvDB;
    if (SconvDB!=nullptr){
        QSqlRecord newRecord = dbPtr->record();
        newRecord.setValue("author", json["from"].toString());
        newRecord.setValue("recipient", json["to"].toString());
        newRecord.setValue("timestamp", json["timestamp"].toString());
        newRecord.setValue("message", json["data"].toString());
        if (!dbPtr->insertRecord(dbPtr->rowCount(), newRecord)) {
            qWarning() << "Failed to insert message into DB:" << dbPtr->lastError().text();
            return;
        }
        if(!dbPtr->submitAll()){
            qDebug()<<dbPtr->lastError();
        }
    }
    else{
        QSqlQuery query;
        const QString filterString = QString::fromLatin1("INSERT INTO Conversations VALUES('%1', '%2', '%3', '%4')")
                .arg(json["from"].toString(),json["to"].toString(),json["timestamp"].toString(),json["data"].toString());
        if(!query.exec(filterString)){
            qDebug()<<"insert msg err: "<<dbPtr->lastError();
        }
    }

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
    if(eml!="")json.insert("email", eml);
    return json;
}

void AccountMgr::sendMsg(const QString &target,const QString &timestamp,const QString &msgText){
    QJsonObject json = {
        {"type", "msg"},
        {"from", username},
        {"to", target},
        {"timestamp", timestamp},
        {"data", msgText}
    };
    if(sendJsonObj(json)==-1) qDebug()<<"send msg pkg err";
}
void AccountMgr::addContact(const QString &target){

}

QString AccountMgr::getUsername(){
    return username;
}
