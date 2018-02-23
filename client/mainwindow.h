// mainwindow.h
// 22.11.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <qmainwindow.h>
#include <qpopupmenu.h>
#include <qtextbrowser.h>

#include "lotus.h"
#include "protocol.h"

#include "client.h"
#include "lotus3d.h"
#include "settings.h"
#include "settingsdialog.h"


class MainWindow : public QMainWindow
{
	Q_OBJECT

public:

	MainWindow( Settings* settings, Q_UINT16 pcp, QWidget* parent = 0,
		const char* name = 0, WFlags f = WType_TopLevel );
	~MainWindow();

protected:

	bool isHuman( Stone pl ) const;
	void doMove( Move m );
	void closeEvent( QCloseEvent* e );
	void drawSignal( const QColor& c );

protected slots:

	void newGame();
	void resignGame();
	void quitGame();
	void turnMsg();
	void wantMove( unsigned x );
	void gameTypeChanged( int id );
	void gotMessage( QString msg );
	void connectionError( ClientError error );
	void connected();
	void fakingServer( const QString& msg );

	void helpLotus();
	void helpLotux();
	void about();
	void aboutQt();

private:

	static const QString CAPTION;

	enum GameType { Local = 0, Computer = 1, Network = 2 };

	Lotus3D* lotus_3dw;
	QPopupMenu* options_mnu;
	QTextBrowser* help_wgt;
	Client* client;
	SettingsDialog* settings_dlg;
	Settings* sets;
	Q_UINT16 pcport;

	Lotus lotus;
	Stone player, local;
	GameState state;
	GameType game, menu_game;
	bool wantmove, first;
};

#endif //MAINWINDOW_H

