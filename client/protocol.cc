// protocol.cpp
// 20.04.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#include <qregexp.h>

#include "protocol.h"

const QString MessageParser::IDENT_RE =
	"[A-Za-z0-9ƒ÷‹‰ˆ¸ﬂ\\(\\)\\[\\]<>\\{\\}\\-\\+\\*/=_#\\.:,;\\?!ß\\$%&@~ ]*";

const QString MessageParser::BOARD_RE = "[A-Za-z0-9_\\.\\-]+";

const QString MessageParser::MOVE_RE = "\\((1?[0-9]|2[0-4]),(L|R)\\)";

const QString MessageParser::MESSAGES_RE[] = {
	"Ich_ziehe " + MOVE_RE,
	"Ich_bin \"" + IDENT_RE + "\"", "OK",
	"Das_Spielfeld_ist " + BOARD_RE,
	"(Du_beginnst|Der_andere_beginnt)",
	"Ende",
	"Wo_ziehst_du",
	"Wer_bist_du",
	"Dein_Gegner_ist \"" + IDENT_RE + "\"",
	"Der_andere_zieht " + MOVE_RE,
	".*"
};

bool MessageParser::setMessage( const QString& message )
{
	int num(-1), pos;
	QRegExp re;
	do
	{
		re.setPattern( MESSAGES_RE[++num] );
		pos = re.search( message );
	} while( pos != 0 );

	int len( re.matchedLength() );
	_message = message.left( len );
	_comment = message.mid( len );
	_type = MessageType( num );
	return isValid();
}

Move MessageParser::move() const
{
	QRegExp re;
	switch( _type )
	{
	case ClMove:
	case SrvOther:
		re.setPattern( MOVE_RE );
		re.search( _message );
		return Move( re.cap() );
	default:
		return Move();
	}
}

Stone MessageParser::color() const
{
	if( _type == SrvColor )
		return _message[1] == 'u' ? Stone::S : Stone::W;
	return Stone::X;
}

QString MessageParser::name() const
{
	QRegExp re;
	switch( _type )
	{
	case ClName:
	case SrvOpponent:
		re.setPattern( "\"(" + IDENT_RE + ")\"" );
		re.search( _message );
		return re.cap( 1 );
	case SrvBoard:
		return _message.mid( _message.find( ' ' ) + 1 );
	default:
		return QString::null;
	}
}

bool MessageParser::isName( const QString& name )
{
	return QRegExp( IDENT_RE ).exactMatch( name );
}

bool MessageParser::isBoard( const QString& name )
{
	return QRegExp( BOARD_RE ).exactMatch( name );
}

bool MessageParser::forState( GameState state ) const
{
	switch( state )
	{
	case GsName: return _type == ClName || _type == SrvName;
	case GsBoard: return _type == ClOk || _type == SrvBoard;
	case GsOpponent: return _type == ClOk || _type == SrvOpponent;
	case GsColor: return _type == ClOk || _type == SrvColor;
	case GsGame: return _type == SrvMove || _type == SrvOther || _type == SrvEnd;
	case GsMove: return _type == ClMove;
	case GsOther: return _type == ClOk;
	case GsEnd: return _type == ClOk;
	case GsNoGame: return false;
	}
	return false;
}

bool MessageGenerator::setMessage( MessageType type )
{
	switch( type )
	{
	case ClOk:
		_message = "OK";
		break;
	case SrvEnd:
		_message = "Ende";
		break;
	case SrvMove:
		_message = "Wo_ziehst_du";
		break;
	case SrvName:
		_message = "Wer_bist_du";
		break;
	default:
		_message = "";
	}
	return isValid();
}

bool MessageGenerator::setMessage( MessageType type, const QString& name )
{
	switch( type )
	{
	case ClName:
		_message = MessageParser::isName( name ) ?
			"Ich_bin \"" + name + "\"" : QString( "" );
		break;
	case SrvBoard:
		_message = MessageParser::isBoard( name ) ?
			"Das_Spielfeld_ist " + name : QString( "" );
		break;
	case SrvOpponent:
		_message = MessageParser::isName( name ) ?
			"Dein_Gegner_ist \"" + name + "\"" : QString( "" );
		break;
	default:
		_message = "";
	}
	return isValid();
}

bool MessageGenerator::setMessage( MessageType type, const Move& move )
{
	switch( type )
	{
	case ClMove:
		_message.sprintf( "Ich_ziehe %s", move.show() );
		break;
	case SrvOther:
		_message.sprintf( "Der_andere_zieht %s", move.show() );
		break;
	default:
		_message = "";
	}
	return isValid();
}

bool MessageGenerator::setMessage( MessageType type, const Stone& color )
{
	_message = type == SrvColor && color.isValid() ?
		( color.isS() ? "Du_beginnst" : "Der_andere_beginnt" ) : "";
	return isValid();
}

		
