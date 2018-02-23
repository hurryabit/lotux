// protocol.h
// 20.04.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#ifndef PROTOCOL_H
#define PROTOCOL_H

#include <qstring.h>

#include "lotus.h"

enum MessageType { ClMove = 0, ClName = 1, ClOk = 2,
	SrvBoard = 3, SrvColor = 4, SrvEnd = 5, SrvMove = 6, SrvName = 7,
	SrvOpponent = 8, SrvOther = 9,
	MsgError = 10 };

enum GameState { GsName, GsBoard, GsOpponent, GsColor, GsGame, GsMove,
	GsOther, GsEnd, GsNoGame };

////////////////////////////////////////////////////////////////////////////////

class MessageParser
{
public:
	MessageParser();
	MessageParser( const MessageParser& message );
	MessageParser( const QString& message );
	~MessageParser();
	MessageParser& operator =( const MessageParser& message );

	bool setMessage( const QString& message );

	bool isValid() const;

	QString message( bool commented = false ) const;
	QString comment() const;
	MessageType type() const;
	Move move() const;
	Stone color() const;
	QString name() const;

	bool forState( GameState state ) const;

	static bool isName( const QString& name );
	static bool isBoard( const QString& name );

private:
	static const QString IDENT_RE, BOARD_RE, MOVE_RE, MESSAGES_RE[MsgError + 1];
	QString _message, _comment;
	MessageType _type;
};

////////////////////////////////////////////////////////////////////////////////

class MessageGenerator
{
public:
	MessageGenerator();
	explicit MessageGenerator( MessageType type );
	explicit MessageGenerator( MessageType type, const QString& name );
	explicit MessageGenerator( MessageType type, const Move& move );
	explicit MessageGenerator( MessageType type, const Stone& color );

	operator QString() const;

	bool setMessage( MessageType type );
	bool setMessage( MessageType type, const QString& name );
	bool setMessage( MessageType type, const Move& move );
	bool setMessage( MessageType type, const Stone& color );

	MessageGenerator& comment( const QString& comm );
	bool commented() const;

	bool isValid() const;

	QString message() const;

private:
	QString _message, _comment;
};

////////////////////////////////////////////////////////////////////////////////

inline MessageParser::MessageParser():
	_message( QString::null ), _comment( QString::null ), _type( MsgError )
{
}

inline MessageParser::MessageParser( const MessageParser& message ):
	_message( message._message ), _comment( message._comment ),
	_type( message._type )
{
}

inline MessageParser::MessageParser( const QString& message )
{
	setMessage( message );
}

inline MessageParser::~MessageParser()
{
}

inline MessageParser& MessageParser::operator =( const MessageParser& message )
{
	_message = message._message;
	_comment = message._comment;
	_type = message._type;
	return *this;
}

inline bool MessageParser::isValid() const
{
	return _type != MsgError;
}

inline QString MessageParser::message( bool commented ) const
{
	if( commented )
		return _message + _comment;
	return _message;
}

inline QString MessageParser::comment() const
{
	return _comment;
}

inline MessageType MessageParser::type() const
{
	return _type;
}

////////////////////////////////////////////////////////////////////////////////

inline MessageGenerator::MessageGenerator():
	_message( "" ), _comment( "" )
{
}

inline MessageGenerator::MessageGenerator( MessageType type )
{
	setMessage( type );
}

inline MessageGenerator::MessageGenerator( MessageType type,
	const QString& name )
{
	setMessage( type, name );
}

inline MessageGenerator::MessageGenerator( MessageType type,
	const Move& move )
{
	setMessage( type, move );
}

inline MessageGenerator::MessageGenerator( MessageType type,
	const Stone& color )
{
	setMessage( type, color );
}

inline bool MessageGenerator::isValid() const
{
	return !_message.isEmpty();
}

inline MessageGenerator& MessageGenerator::comment( const QString& comm )
{
	_comment = comm;
	return *this;
}

inline bool MessageGenerator::commented() const
{
	return !_comment.isEmpty();
}

inline QString MessageGenerator::message() const
{
	return _message + ( commented() ? " # " + _comment : QString::null );
}

inline MessageGenerator::operator QString() const
{
	return message();
}

#endif // PROTOCOL_H

