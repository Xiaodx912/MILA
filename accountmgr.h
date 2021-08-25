#ifndef ACCOUNTMGR_H
#define ACCOUNTMGR_H

#include <QObject>

class AccountMgr : public QObject
{
    Q_OBJECT
public:
    //explicit AccountMgr(QObject *parent = nullptr);

signals:
    void loginSuccess();

public slots:
    void LoginWith(const QString &username,const QString &pwd);
};

#endif // ACCOUNTMGR_H
