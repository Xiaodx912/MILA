/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include "sqlcontactmodel.h"

#include <QDebug>
#include <QSqlError>
#include <QSqlQuery>

static void createTable(){
    QSqlQuery query;
    if (!QSqlDatabase::database().tables().contains(QStringLiteral("Contacts"))) {
        if (!query.exec("CREATE TABLE IF NOT EXISTS 'Contacts' ("
                        "   'name' TEXT NOT NULL,"
                        "   'email' TEXT,"
                        "   PRIMARY KEY(name)"
                        ")"))
            qFatal("Failed to create database: %s", qPrintable(query.lastError().text()));
    }
//    query.exec("INSERT INTO Contacts VALUES('Albert Einstein','')");
//    query.exec("INSERT INTO Contacts VALUES('Ernest Hemingway','')");
//    query.exec("INSERT INTO Contacts VALUES('Hans Gude','')");
}

SqlContactModel::SqlContactModel(QObject *parent): QSqlQueryModel(parent) {
    createTable();
//    QSqlQuery query;
//    if (!query.exec("SELECT * FROM Contacts"))
//        qFatal("Contacts SELECT query failed: %s", qPrintable(query.lastError().text()));
//    setQuery(query);
//    if (lastError().isValid())
//        qFatal("Cannot set query on SqlContactModel: %s", qPrintable(lastError().text()));
}

AccountMgr* SqlContactModel::acc(){
    return myAcc;
}

void SqlContactModel::setAcc(AccountMgr *acc){
    if (acc==nullptr)return;
    myAcc=acc;
    myAcc->ScontDB=(QSqlTableModel*)this;
}
void SqlContactModel::initDB(){
    qDebug()<<"init cont DB";
    isInit=true;
    fetchFromConv();
    myAcc->refreshContEmail();
    refreshQuery();
}

void SqlContactModel::fetchFromConv(){
    QSqlQuery query;
    query.exec( "INSERT INTO Contacts SELECT u name,NULL email FROM "
                "(SELECT recipient u FROM Conversations UNION "
                "SELECT author u FROM Conversations) "
                "WHERE u NOT IN (SELECT name FROM Contacts)");
    const QString queryString = QString::fromLatin1("DELETE FROM Contacts WHERE name='%1'").arg(myAcc->getUsername());
    if (!query.exec(queryString))
        qFatal("Contacts SELECT query failed: %s", qPrintable(query.lastError().text()));
}

void SqlContactModel::addCont(const QString &name){
    if(name==myAcc->getUsername()){
        qDebug()<<"add self";
        return;
    }
    QSqlQuery query;
    const QString queryString = QString::fromLatin1("INSERT INTO Contacts VALUES('%1',NULL)").arg(name);
    if (!query.exec(queryString))
        qInfo("contact exist");
    myAcc->refreshContEmail();
    refreshQuery();
}

void SqlContactModel::refreshQuery(){
    QSqlQuery query;
    if (!query.exec("SELECT * FROM Contacts"))
        qFatal("Contacts SELECT query failed: %s", qPrintable(query.lastError().text()));
    setQuery(query);
    if (lastError().isValid())
        qFatal("Cannot set query on SqlContactModel: %s", qPrintable(lastError().text()));
}

void SqlContactModel::onTop(){
    if (!isInit)return;
    fetchFromConv();
    myAcc->refreshContEmail();
    refreshQuery();
}


QVariant SqlContactModel::data(const QModelIndex &index, int role) const {
    if (role < Qt::UserRole) return QSqlQueryModel::data(index, role);

    const QSqlRecord sqlRecord = record(index.row());
    return sqlRecord.value(role - Qt::UserRole);
}
QHash<int, QByteArray> SqlContactModel::roleNames() const {
    QHash<int, QByteArray> names;
    names[Qt::UserRole] = "name";
    names[Qt::UserRole + 1] = "email";
    return names;
}
