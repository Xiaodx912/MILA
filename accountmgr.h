#ifndef ACCOUNTMGR_H
#define ACCOUNTMGR_H

#include <QDebug>
#include <QObject>
#include <QString>
#include <QSqlTableModel>
#include <QSqlRecord>
#include <QSqlError>
#include <QSqlQuery>

#include <QElapsedTimer>
#include <QCoreApplication>
#include <QTcpSocket>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QCryptographicHash>

#include <QTimer>

#include <string.h>
#include <string>

class AccountMgr : public QObject
{
    Q_OBJECT
private:
    QString username,password,eml;
    QJsonObject makeIdenJson(QString type);
    void handleLoginReply(QJsonObject json);
    void handleRegReply(QJsonObject json);
    void handleMsgSendReply(QJsonObject json);
    void handleIncomingMsg(QJsonObject json);
    void handleEmailQueryReply(QJsonObject json);
    QSqlTableModel *convDB=nullptr,*contDB=nullptr;
    void initDB();
    QTimer* heartbeatTimer;

public:
    //explicit AccountMgr(QObject *parent = nullptr);
    QTcpSocket* clientSocket=nullptr;
    void init_socket(bool force);
    int sendJsonObj(QJsonObject msg);
    QSqlTableModel *SconvDB=nullptr,*ScontDB=nullptr;
    void refreshContEmail();

signals:
    void loginSuccess();
    void loginFail(const QString &reason);
    void regSuccess();
    void fetchCont();
    void refreshContQuery();

public slots:
    void LoginWith(const QString &username,const QString &pwd,const QString &btnState,const QString &email);
    void onRecvData();
    void sendMsg(const QString &target,const QString &timestamp,const QString &msgText);
    void addContact(const QString &target);
    QString getUsername();
    QString getEHash(const QString& name);
    void sendHeartbeat();
};

#endif // ACCOUNTMGR_H
