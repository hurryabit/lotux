// mainwindow.cpp
// 22.11.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#include <cstdlib>

#include <qfile.h>
#include <qmenubar.h>
#include <qmessagebox.h>
#include <qpainter.h>
#include <qstatusbar.h>

#include "mainwindow.h"



const QString MainWindow::CAPTION = MainWindow::tr( "Lotux for Linux" );

MainWindow::MainWindow( Settings* settings, Q_UINT16 pcp, QWidget* parent,
	const char* name, WFlags f ):
		QMainWindow( parent, name, f ), pcport( pcp ), local( Stone::S ),
		state( GsNoGame ), menu_game( pcport ? Computer : Network ),
		wantmove( false )
{
	sets = settings != 0 ? settings : new Settings;	

	// 3d-widget
	lotus_3dw = new Lotus3D( sets->bgColor(), this );

	setCaption( CAPTION );
	setCentralWidget( lotus_3dw );

	settings_dlg = new SettingsDialog( sets, this );
	settings_dlg->setCaption( CAPTION + " - " + tr( "Settings" ) );

	help_wgt = new QTextBrowser(0);
	help_wgt->setMinimumSize( 400, 300 );

	// Game menu
	QPopupMenu* game_mnu = new QPopupMenu( this );
	game_mnu->insertItem( tr( "&New match" ), this, SLOT( newGame() ) );
	game_mnu->insertItem( tr( "&Resign" ), this, SLOT( resignGame() ) );
	game_mnu->insertSeparator();
	game_mnu->insertItem( tr( "&Quit" ), this, SLOT( close() ) );
	game_mnu->setCheckable( false );
	
	// Settings menu
	options_mnu = new QPopupMenu( this );
	options_mnu->setCheckable( true );
	options_mnu->insertItem( tr( "&Local match" ), Local );
	if( pcport )
		options_mnu->insertItem( tr( "&Computer match" ), Computer );
	options_mnu->insertItem( tr( "&Network match" ), Network );
  options_mnu->setItemChecked( menu_game, true );
	options_mnu->insertSeparator();
	options_mnu->insertItem( tr( "&Settings" ), settings_dlg,
		SLOT( exec() ), 0, 128 );
	
	// Help menu
	QPopupMenu* help_mnu = new QPopupMenu( this );
	help_mnu->insertItem( tr( "How to use Lotu&x" ), this, SLOT( helpLotux() ) );
	help_mnu->insertItem( tr( "How to play &Lotus" ), this, SLOT( helpLotus() ) );
	help_mnu->insertSeparator();
	help_mnu->insertItem( tr( "&About" ), this, SLOT( about() ) );
	help_mnu->insertItem( tr( "About &Qt" ), this, SLOT( aboutQt() ) );
	help_mnu->setCheckable( false );
	// Menubar
	menuBar()->insertItem( tr( "&Game" ), game_mnu );
	menuBar()->insertItem( tr( "&Options" ), options_mnu );
	menuBar()->insertSeparator();
	menuBar()->insertItem( tr( "&Help" ), help_mnu );

	statusBar()->message( tr( "Currently, there is no running game" ) );

	client = new Client( this );

	connect( lotus_3dw, SIGNAL( move( unsigned ) ),
		SLOT( wantMove( unsigned ) ) );
	connect( options_mnu, SIGNAL( activated( int ) ),
		SLOT( gameTypeChanged( int ) ) );
	connect( client, SIGNAL( connectionError( ClientError ) ),
		SLOT( connectionError( ClientError ) ) );
	connect( client, SIGNAL( connected() ), SLOT( connected() ) );
	connect( client, SIGNAL( message( QString ) ),
		SLOT( gotMessage( QString ) ) );
}

MainWindow::~MainWindow()
{
}

void MainWindow::newGame()
{
	if( state != GsNoGame )
		if( QMessageBox::warning( this, CAPTION, tr( "There is another unfinished "
			"game.\nDo you really want to start a new one?" ),
				QMessageBox::Yes, QMessageBox::No ) != QMessageBox::Yes )
			return;
		else
			quitGame();

	game = menu_game;
	player = Stone::S;
	lotus = Lotus( true );
	first = false;

	switch( menu_game )
	{
		case Computer:
			client->connectToHost( "localhost", pcport );
			state = GsName;
			statusBar()->message( tr( "Starting game" ) );
			break;
		case Network:
			client->connectToHost( sets->server(), sets->port() );
			state = GsName;
			statusBar()->message( tr( "Connecting to server" ) );
			break;
		case Local:
			wantmove = true;
			state = GsGame;
			turnMsg();
			break;
	}
	lotus_3dw->drawLotus( lotus );
}

void MainWindow::quitGame()
{
	if( state == GsNoGame )
		return;
	state = GsNoGame;
	wantmove = false;

	if( game == Network || game == Computer )
		client->close();
	statusBar()->message( tr( "Currently, there is no running game" ) );
}

void MainWindow::wantMove( unsigned x )
{
	if( !wantmove )
		return;
	
	if( !lotus.canMove( player, x ) )
		return;

	Move m( x );
	if( lotus.needDir(x) )
	{
		int mb( QMessageBox::information( this, CAPTION, tr( "Where do you wish "
			"to insert your piece?" ), tr( "&Left" ), tr( "&Right" ) ) );
		if( 0 > mb  || mb > 1 )
			return;
		m.setDir( mb == 0 ? Move::Left : Move::Right );
	}

	doMove(m);
	if( game == Network || game == Computer )
	{
		wantmove = false;
		client->sendMessage( MessageGenerator( ClMove, m ) );
	}
}

void MainWindow::doMove( Move m )
{
	lotus.move( player, m );
	lotus_3dw->drawLotus( lotus );
	if( game == Local && lotus.eog() )
	{
		QMessageBox::information( this, CAPTION, player.isS() ?
			tr( "The black player won!" ) : tr( "The white player won!" ),
			QMessageBox::Ok, QMessageBox::NoButton );
		quitGame();
		return;
	}
	if( lotus.canMoveAny( !player ) && !first)
		player = !player;
	if( first )
		first = false;
	turnMsg();
}
void MainWindow::turnMsg()
{
	if( lotus.eog() )
		return;
	QString msg;
	switch( game )
	{
		case Network:
		case Computer:
			if( isHuman( player ) )
				msg = tr( "It's your turn" );
			else
				msg = tr( "It's your opponent's turn" );
			break;
		case Local:
			msg = player.isS() ? tr( "It's black's turn" ): tr( "It's white's turn" );
			break;
	}
	statusBar()->message( msg );
}

void MainWindow::about()
{
	QMessageBox::about( this, tr( "About Lotux for Linux" ),
		tr( "<h1>Lotux - Playing Lotus under Linux</h1>"
			"Copyright (C) 2001-2002 by Carsten Moldenhauer & Martin Huschenbett<br>"
			"This program is distributed under the terms of the"
			"<center><b>GNU GENERAL PUBLIC LICENSE</b></center>"
			"See file <em>LICENSE</em> for more information.<br><br>"
			"<u>Contact:</u><br>"
			"Email: <a href=\"mailto:spieltheorie@gmx.de\">spieltheorie@gmx.de</a>"
			"<br>Website: <a href=\"http://lotux.homelinux.org/\">"
			"http://lotux.homelinux.org/</a>" ) );
}

void MainWindow::aboutQt()
{
	QMessageBox::aboutQt( this, CAPTION + " - " + tr ("About Qt" ) );
}

void MainWindow::resignGame()
{
	if( state == GsNoGame )
		return;
	if( QMessageBox::warning( this, CAPTION, tr( "Are you sure that you want to "
		"resign?" ), QMessageBox::Yes, QMessageBox::No ) == QMessageBox::Yes )
		quitGame();
}

bool MainWindow::isHuman( Stone pl ) const
{
	return game == Local ? true : pl == local;
}

void MainWindow::gameTypeChanged( int id )
{
	if( id < 128 )
	{
		options_mnu->setItemChecked( menu_game, false );
		menu_game = GameType( id );
		options_mnu->setItemChecked( menu_game, true );
	}
}

void MainWindow::gotMessage( QString msg )
{
	MessageParser mp( msg );
	if( !mp.forState( state ) )
	{
		fakingServer( msg );
		return;
	}
	QString str;
	switch( state )
	{
	case GsName:
		client->sendMessage( MessageGenerator( ClName, 
			( MessageParser::isName( sets->name() ) ? sets->name() :
			QString( "Player" ) ) +
			( !sets->email().isEmpty() && MessageParser::isName( sets->email() ) ?
			" (" + sets->email() + ")" : QString::null ) ) );
		state = GsBoard;
		return;

	case GsBoard:
		client->sendMessage( MessageGenerator( ClOk ) );
		state = GsOpponent;
		return;

	case GsOpponent:
		statusBar()->message( tr( "Initialzing game" ) );
		QMessageBox::information( this, CAPTION, tr( "You are playing against "
			"%1." ).arg( mp.name() ), QMessageBox::Ok, QMessageBox::NoButton );
		client->sendMessage( MessageGenerator( ClOk ) );
		state = GsColor;
		return;

	case GsColor:
		local = mp.color();
		QMessageBox::information( this, CAPTION,
			local.isS() ? tr( "You have to play with the black stones." ) :
			tr( "You have to play with the white stones." ),
			QMessageBox::Ok, QMessageBox::NoButton );
		client->sendMessage( MessageGenerator( ClOk ) );
		state = GsGame;
		turnMsg();
		return;

	case GsGame:
		switch( mp.type() )
		{
		case SrvMove:
			if( player != local )
				fakingServer( msg );
			else
				wantmove = true;
			return;
		case SrvOther:
			if( player == local )
				fakingServer( msg );
			else
			{
				Move m( mp.move() );
				if( !lotus.canMove( player, m.num() ) )
					fakingServer( msg );
				else
				{
					doMove( m );
					client->sendMessage( MessageGenerator( ClOk ) );
				}
			}
			return;
		case SrvEnd:
			client->sendMessage( MessageGenerator( ClOk ) );
			quitGame();
			if( lotus.eog() )
				str = local != player ?
					tr( "Congratulations, you are the winner!" ) :
					tr( "Sorry, but you lost!" );
			else
			{
				str = tr( "Sorry, but the server send an unexpected end of the "
					"game.\nMaybe your opponent gave up or your time is over." ) + '\n';
				if( !mp.comment().isEmpty() )
					str += tr( "The comment was:" ) + "\n\n" + mp.comment();
			}
			QMessageBox::information( this, CAPTION, str, QMessageBox::Ok,
				QMessageBox::NoButton );
			return;
		default:
			fakingServer( msg );
			return;
		}

	default:
		return;
	}
}

void MainWindow::connectionError( ClientError error )
{
	if( state != GsNoGame )
	{
		QString msg;
		switch( error )
		{
		case UnknownHost:
			msg = tr( "Unknown server host!" );
			break;
		case Refused:
			msg = tr( "Server refused connection!" );
			break;
		case Failed:
			msg = tr( "A read action from the socket failed!" );
			break;
		case Closed:
			msg = tr( "The server closed the connection!" );
			break;
		}

		QMessageBox::critical( this, CAPTION, tr( "Error on connection to server:" )
			+ " " + msg, QMessageBox::Ok, QMessageBox::NoButton );
		quitGame();
	}
}

void MainWindow::fakingServer( const QString& msg )
{
	quitGame();
	QMessageBox::information( this, CAPTION, tr( "The server wrote something "
		"that isn't speciefied in the protocol!\nThe message was:" ) + " " + msg,
		QMessageBox::Ok, QMessageBox::NoButton );
}

void MainWindow::closeEvent( QCloseEvent* e )
{
	quitGame();
	e->accept();
}

void MainWindow::connected()
{
	if( game == Network )
		statusBar()->message( tr( "Waiting for an opponent" ) );
}

void MainWindow::helpLotus()
{
	QString basename( sets->filePath() + "/lotus_" ),
		filename( basename + sets->languageCode() + ".html" );
	if( !QFile::exists( filename ) )
	{
		filename = basename + "en.html";
		if( !QFile::exists( filename ) )
		{
			QMessageBox::critical( this, CAPTION, tr( "Neither the helpfile in your "
				"language nor the English version exists.\nMaybe your file path isn't "
				"set correct." ), QMessageBox::Ok, QMessageBox::NoButton );
			return;
		}
	}
	help_wgt->hide();
	help_wgt->setSource( filename );
	help_wgt->setCaption( tr( "Lotus help" ) );
	help_wgt->show();
	help_wgt->update();
}

void MainWindow::helpLotux()
{
	QString basename( sets->filePath() + "/lotux_" ),
		filename( basename + sets->languageCode() + ".html" );
	if( !QFile::exists( filename ) )
	{
		filename = basename + "en.html";
		if( !QFile::exists( filename ) )
		{
			QMessageBox::critical( this, CAPTION, tr( "Neither the helpfile in your "
				"language nor the English version exists.\nMaybe your file path isn't "
				"set correct." ), QMessageBox::Ok, QMessageBox::NoButton );
			return;
		}
	}
	help_wgt->hide();
	help_wgt->setSource( filename );
	help_wgt->setCaption( tr( "Lotux help" ) );
	help_wgt->show();
	help_wgt->update();
}

