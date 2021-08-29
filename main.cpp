#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QFontDatabase>

#include "accountmgr.h"

int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/Login.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    AccountMgr mgr;
    QList<QObject*> root = engine.rootObjects();
    QObject::connect(root[0],SIGNAL(doLogin(QString,QString,QString)),
                     &mgr,SLOT(LoginWith(QString,QString,QString)));
    QObject::connect(&mgr,SIGNAL(loginSuccess()),
                     root[0],SIGNAL(loginSuccess()));
    QObject::connect(&mgr,SIGNAL(loginFail(QString)),
                     root[0],SIGNAL(loginFail(QString)));
    app.exec();

    qDebug()<<"exec fin";
    return 0;
}


