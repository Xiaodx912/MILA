#include <QDebug>
#include <QObject>
#include <QString>

#include <QElapsedTimer>
#include <QCoreApplication>

#include "accountmgr.h"

void AccountMgr::LoginWith(const QString &username,const QString &pwd){
        qDebug()<<"Login with Username: "<<username<<" and Password: "<<pwd;
        QElapsedTimer t;
        t.start();
        while(t.elapsed()<3000)
            QCoreApplication::processEvents();
        if (username=="a"&&pwd=="b"){
            qDebug()<<"login success";
            emit loginSuccess();
        }
        return;
}
