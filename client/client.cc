// client.cpp
// 11.01.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#include <qtextstream.h>

#include "client.h"

Client::Client( QObject* parent, const char* name ):
	QSocket( parent, name ), isopen( false )
{
	connect( this, SIGNAL( readyRead() ), SLOT( readClient() ) );
	connect( this, SIGNAL( error( int ) ), SLOT( errorConnect( int ) ) );
	connect( this, SIGNAL( connectionClosed() ), SLOT( closed() ) );
}

Client::~Client()
{
}

void Client::connectToHost( const QString& host, Q_UINT16 port )
{
	isopen = true;
	QSocket::connectToHost( host, port );
}

void Client::close()
{
	if( isopen )
	{
		isopen = false;
		QSocket::close();
	}
}

void Client::readClient()
{
	if( canReadLine() && state() == Connected )
	{
		waitForMore( 10 );
		QString msg( readLine().section( '\n', 0, 0 ) );
#ifdef DEBUG
		qDebug( ">> " + msg );
#endif
		emit message( msg );
	}
}

void Client::sendMessage( const QString& msg )
{
	if( isopen )
	{
		QTextStream s( this );
		s << msg << "\n";
#ifdef DEBUG
		qDebug( "<< " + msg );
#endif
	}
}

void Client::errorConnect( int error )
{
	if( isopen )
	{
		isopen = false;
		ClientError e( Failed );

		switch( error )
		{
		case ErrConnectionRefused:
			e = Refused;
			break;
		case ErrHostNotFound:
			e = UnknownHost;
			break;
		case ErrSocketRead:
			e = Failed;
			break;
		}

		emit connectionError( e );
	}
}

void Client::closed()
{
	if( isopen )
	{
		isopen = false;
		emit connectionError( Closed );
	}
}

