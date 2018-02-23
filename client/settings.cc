// settings.cpp
// 09.12.2001
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#include <cstdlib>

#include <iostream>

#include <qfile.h>
#include <qregexp.h>
#include <qsettings.h>
#include <qtextcodec.h>

#include "config.h"

#include "settings.h"

// Data tables
const QStringList Settings::lang_codes =
	QStringList::split( ',', "en,de" );
const QStringList Settings::lang_names =
	QStringList::split( ',', "English,Deutsch" );

// Default values
const QColor Settings::def_bgcolor = QColor( "#ffff7f" );
const unsigned Settings::def_language = 0;
const QString Settings::def_filepath = DATA_DIR;
const QString Settings::def_name = "Player";
const QString Settings::def_email = QString::null;
const QString Settings::def_server = "lotux.homelinux.org";
const Q_UINT16 Settings::def_port = 5180;

// Path to rc file
const QString Settings::PATH = "/lotux/";


Settings::Settings():
	_bgcolor( def_bgcolor ), _language( def_language ), _filepath( def_filepath),
	_name( def_name ), _email( def_email ), _server( def_server ),
	_port( def_port ),
	c_bgcolor( false ), c_language( false ), c_filepath( false ),
	c_name( false ), c_email( false ), c_server( false ), c_port( false )
{
}

Settings::~Settings()
{
}

Settings& Settings::load()
{
	QSettings s;

	// Read bgcolor
	setBgColor( s.readEntry( PATH + "Appearance/bgcolor", def_bgcolor.name() ) );
	
	// Read language
	setLanguage( s.readEntry( PATH + "language", langFromLocale() ) );
	
	// Read path for different files (translations, help, ...)
	setFilePath( s.readEntry( PATH + "filepath", def_filepath ) );

	// Read name of the player
	QString name( s.readEntry( PATH + "User/name", getenv( "USER" ) ) );
	setName( name.isEmpty() ? def_name : name );

	// Read email adress of the player
	setEmail( s.readEntry( PATH + "User/email", def_email ) );

	// Read server for network games
	setServer( s.readEntry( PATH + "Network/server", def_server ) );

	// Read port for server
	setPort( (Q_UINT16) s.readNumEntry( PATH + "Network/port", def_port ) );
	
	return *this;
}

Settings& Settings::save()
{
	QSettings s;
	
	if( c_bgcolor )
		s.writeEntry( PATH + "Appearance/bgcolor", bgColorCode() );
	
	if( c_language )
		s.writeEntry( PATH + "language", languageCode() );
	
	if( c_filepath )
		s.writeEntry( PATH + "filepath", filePath() );

	if( c_name )
		s.writeEntry( PATH + "User/name", name() );

	if( c_email )
		s.writeEntry( PATH + "User/email", email() );

	if( c_server )
		s.writeEntry( PATH + "Network/server", server() );

	if( c_port )
		s.writeEntry( PATH + "Network/port", port() );
		
	return *this;
}

bool Settings::setBgColor( const QColor& bgcolor )
{
	if( bgcolor.isValid() )
	{
		c_bgcolor = bgcolor != _bgcolor || c_bgcolor;
		_bgcolor = bgcolor;
		return true;
	}
	else
		return false;
}

bool Settings::setBgColor( const QString& bgcolor )
{
	if( bgcolor.contains( QRegExp( "^\\#[0-9a-fA-F]{6}$" ) ) == 1 )
	{
		c_bgcolor = bgcolor.upper() != _bgcolor.name().upper() || c_bgcolor;
		_bgcolor.setNamedColor( bgcolor );
		return true;
	}
	else
		return false;
}

bool Settings::setLanguage( unsigned language )
{
	if( language < lang_codes.size() )
	{
		c_language = language != _language || c_language;
		_language = language;
		return true;
	}
	else
		return false;
}

bool Settings::setLanguage( const QString& language )
{
	return setLanguage( lang_codes.findIndex( language ) );
}

bool Settings::setFilePath( const QString& filepath )
{
	if( QFile::exists( filepath ) )
	{
		c_filepath = filepath != _filepath || c_filepath;
		_filepath = filepath;
		return true;
	}
	else
		return false;
}

bool Settings::setName( const QString& name )
{
	c_name = name != _name || c_name;
	_name = name;
	return true;
}

bool Settings::setEmail( const QString& email )
{
	c_email = email != _email || c_email;
	_email = email;
	return true;
}

bool Settings::setServer( const QString& server )
{
	c_server = server != _server || c_server;
	_server = server;
	return true;
}

bool Settings::setPort( Q_UINT16 port )
{
	c_port = port != _port || c_port;
	_port = port;
	return true;
}

QString Settings::langFromLocale()
{
	QString locale( QTextCodec::locale() );
#if defined (__GNUG__) && ! defined (__STRICT_ANSI__)
	int pos( locale.find( '@' ) <? locale.find( '_' ) );
#else
	int findat( locale.find( '@' ) ), findunderscore( locale.find( '_' ) );
	int pos( findat < findunderscore ? findat : findunderscore );
#endif
	return pos < 0 ? locale : locale.mid( pos - 1 );
}

