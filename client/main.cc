// main.cpp
// 22.11.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#include <cstdlib>

#include <qapplication.h>
#include <qgl.h>
#include <qstring.h>
#include <qstrlist.h>
#include <qtranslator.h>

#include "mainwindow.h"
#include "settings.h"

int main( int argc, char** argv )
{
	QApplication app( argc, argv );
	
	if( !QGLFormat::hasOpenGL () )
	{
		qWarning( QObject::tr( "System doesn't support OpenGL. Exiting." ) );
		return -1;
	}
	
	Settings* settings( new Settings );
	settings->load();	

	QTranslator* t( new QTranslator(0) );
	QString lc( settings->languageCode() );

	// load translation it from the data directory
	bool ok = t->load( "lotux_" + lc, settings->filePath() );
	// if this succeeded, load program translation
	if( ok )
		app.installTranslator( t );

	QStrList strl;
	for( int i(0); i < app.argc(); ++i )
		strl.append( app.argv()[i] );

	Q_UINT16 pcport(0);
	int idx;
	if( (idx = strl.find( "--pcport" )) >= 0 && idx + 1 < strl.count() )
	{
		int p( QString(strl.at(idx+1)).toInt() );
		pcport = p < 0 || p > 65535 ? 0 : (Q_UINT16) p;
	}

	MainWindow* main_wnd = new MainWindow( settings, pcport );
	app.setMainWidget( main_wnd );
	main_wnd->show();
	
	int ret = app.exec() ;
	
	delete main_wnd;
	settings->save();
	delete settings;
	delete t;
	return ret;
}

