#include <QtCore>
#include <QObject>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QSqlDatabase>
#include <QSqlError>
#include <QQmlContext>

#include <QFontDatabase>

#include "accountmgr.h"

#include "sqlcontactmodel.h"
#include "sqlconversationmodel.h"

static void connectToDatabase()
{
    QSqlDatabase database = QSqlDatabase::database();
    if (!database.isValid()) {
        database = QSqlDatabase::addDatabase("QSQLITE");
        if (!database.isValid())
            qFatal("Cannot add database: %s", qPrintable(database.lastError().text()));
    }

    const QDir writeDir = QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
    if (!writeDir.mkpath("."))
        qFatal("Failed to create writable directory at %s", qPrintable(writeDir.absolutePath()));

    // Ensure that we have a writable location on all devices.
    const QString fileName = writeDir.absolutePath() + "/chat-database.sqlite3";
    // When using the SQLite driver, open() will create the SQLite database if it doesn't exist.
    database.setDatabaseName(fileName);
    qDebug()<<fileName;
    if (!database.open()) {
        qFatal("Cannot open database: %s", qPrintable(database.lastError().text()));
        QFile::remove(fileName);
    }
}

int main(int argc, char *argv[]){
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    qmlRegisterType<SqlContactModel>("moe.hareru.MILA", 1, 0, "SqlContactModel");
    qmlRegisterType<SqlConversationModel>("moe.hareru.MILA", 1, 0, "SqlConversationModel");
    connectToDatabase();
    qRegisterMetaType<AccountMgr*>("AccountMgrPtr");
    AccountMgr mgr;
    engine.rootContext()->setContextProperty("_accMgr",&mgr);

    engine.load("qrc:/Login.qml");
    engine.load("qrc:/main.qml");


    QList<QObject*> root = engine.rootObjects();
    if(root.size()!=2 || root[0]->objectName() != "loginWindow" || root[1]->objectName() != "mainWindow"){
        qFatal("Engine Load Fail");
        return -1;
    }
    QObject *loginWindow=root[0], *mainWindow=root[1];

    QObject::connect(loginWindow,SIGNAL(doLogin(QString,QString,QString)),
                     &mgr,SLOT(LoginWith(QString,QString,QString)));
    QObject::connect(&mgr,SIGNAL(loginSuccess()),
                     loginWindow,SIGNAL(loginSuccess()));
    QObject::connect(&mgr,SIGNAL(regSuccess()),
                     loginWindow,SIGNAL(regSuccess()));
    QObject::connect(&mgr,SIGNAL(loginFail(QString)),
                     loginWindow,SIGNAL(loginFail(QString)));

    QObject::connect(loginWindow,SIGNAL(goToMainView()),
                     mainWindow,SIGNAL(loginFinish()));

    QObject* listView=mainWindow->findChild<QObject*>("listView");
    QObject::connect(&mgr,SIGNAL(loginSuccess()),
                     listView,SIGNAL(loginFinish()));






    app.exec();

    qDebug()<<"exec fin";
    return 0;
}


