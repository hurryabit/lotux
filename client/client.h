// client.h
// 11.01.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#ifndef CLIENT_H
#define CLIENT_H

#include <qsocket.h>

enum ClientError { UnknownHost, Refused, Failed, Closed };

class Client: public QSocket
{
	Q_OBJECT

public:


	Client( QObject* parent = 0, const char* name = 0 );
	~Client();

	void connectToHost( const QString& host, Q_UINT16 port );
	void sendMessage( const QString& msg );

public slots:

	void close();

protected slots:

	void readClient();
	void errorConnect( int error );
	void closed();

signals:

	void message( QString msg );
	void connectionError( ClientError error );

private:
	bool isopen;
};

#endif //CLIENT_H

