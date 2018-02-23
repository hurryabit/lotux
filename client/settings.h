// settings.h
// 09.12.2001
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#ifndef SETTINGS_H
#define SETTINGS_H

#include <qcolor.h>
#include <qstring.h>
#include <qstringlist.h>

class Settings
{
public:
	Settings();
	~Settings();
	
	Settings& load();
	Settings& save();
	
	// Get methods
	QColor bgColor() const;
	QString bgColorCode() const;
	unsigned language() const;
	QString languageCode() const;
	QString filePath() const;
	QString name() const;
	QString email() const;
	QString server() const;
	Q_UINT16 port() const;
	
	// Set methods
	bool setBgColor( const QColor& bgcolor );
	bool setBgColor( const QString& bgcolor );
	bool setLanguage( unsigned language );
	bool setLanguage( const QString& language );
	bool setFilePath( const QString& filepath );
	bool setName( const QString& name );
	bool setEmail( const QString& email );
	bool setServer( const QString& server );
	bool setPort( Q_UINT16 port );

	// Maximum values
	static const unsigned languages = 2;
	
	// Data tables
	static const QStringList lang_codes;
	static const QStringList lang_names;
	
	// Default values
	static const QColor def_bgcolor;
	static const unsigned def_language;
	static const QString def_filepath;
	static const QString def_name;
	static const QString def_email;
	static const QString def_server;
	static const Q_UINT16 def_port;

protected:

	QString langFromLocale();

private:
	QColor _bgcolor;
	unsigned _language;
	QString _filepath, _name, _email, _server;
	Q_UINT16 _port;
	bool c_bgcolor, c_language, c_filepath, c_name, c_email, c_server, c_port;
	
	static const QString PATH;
};


inline QColor Settings::bgColor() const
{
	return _bgcolor;
}

inline QString Settings::bgColorCode() const
{
	return _bgcolor.name();
}

inline unsigned Settings::language() const
{
	return _language;
}

inline QString Settings::languageCode() const
{
	return lang_codes[_language];
}

inline QString Settings::filePath() const
{
	return _filepath;
}

inline QString Settings::name() const
{
	return _name;
}

inline QString Settings::email() const
{
	return _email;
}

inline QString Settings::server() const
{
	return _server;
}

inline Q_UINT16 Settings::port() const
{
	return _port;
}

#endif //SETTINGS_H

