#ifndef ACCOUNTMGR_H
#define ACCOUNTMGR_H

#include <QObject>
#include <QTcpSocket>
#include <QJsonObject>


class AccountMgr : public QObject
{
    Q_OBJECT
private:
    QString username,password;
    QJsonObject makeIdenJson(QString type);
    void handleLoginReply(QJsonObject json);
    void handleRegReply(QJsonObject json);
    void handleMsgSendReply(QJsonObject json);
public:
    //explicit AccountMgr(QObject *parent = nullptr);
    QTcpSocket* clientSocket=nullptr;
    void init_socket(bool force);
    int sendJsonObj(QJsonObject msg);

signals:
    void loginSuccess();
    void loginFail(const QString &reason);

public slots:
    void LoginWith(const QString &username,const QString &pwd,const QString &btnState);
    void onRecvData();
};

#endif // ACCOUNTMGR_H
