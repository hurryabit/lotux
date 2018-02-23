// generaltab.cpp
// 15.01.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#include <qfiledialog.h>
#include <qlabel.h>
#include <qlayout.h>
#include <qpushbutton.h>

#include "settings.h"

#include "generaltab.h"

GeneralTab::GeneralTab( unsigned language, const QString& filepath,
		QWidget* parent, const char* name, WFlags f ):
	QWidget( parent, name, f )
{
	language_cbx = new QComboBox( this );
	for( unsigned i(0); i < Settings::languages; ++i )
		language_cbx->insertItem( Settings::lang_names[i] );
	language_cbx->setCurrentItem( language < Settings::languages ?
		language : Settings::def_language );

	QLabel* language_lbl = new QLabel( language_cbx, tr( "&Language:" ), this );

	filepath_edt = new QLineEdit( filepath, this );

	QLabel* filepath_lbl = new QLabel( filepath_edt, tr( "&File path:" ),
		this );

	QPushButton* filepath_btn = new QPushButton( tr( "&Browse..." ),
		this );

	QLabel* hint1_lbl = new QLabel( tr( "(You need to restart the application "
		"to apply the changes.)" ), this );
	QLabel* hint2_lbl = new QLabel( tr( "(This path should point to the "
		"directory,\nwhere the translation and the help files are located.)" ),
		this );

	QVBoxLayout* main_vbl = new QVBoxLayout( this, 10, 10 );
	main_vbl->addStretch();
	main_vbl->addWidget( language_lbl );
	main_vbl->addWidget( language_cbx );
	main_vbl->addWidget( hint1_lbl );
	main_vbl->addStretch();
	main_vbl->addWidget( filepath_lbl );

	QHBoxLayout* filepath_hbl = new QHBoxLayout( main_vbl );
	filepath_hbl->addWidget( filepath_edt );
	filepath_hbl->addWidget( filepath_btn );

	main_vbl->addWidget( hint2_lbl );
	main_vbl->addStretch();

	connect( filepath_btn, SIGNAL( clicked() ), SLOT( choosePath() ) );
}

GeneralTab::~GeneralTab()
{
}

QString GeneralTab::filePath() const
{
	return filepath_edt->text();
}

unsigned GeneralTab::language() const
{
	return (unsigned) language_cbx->currentItem();
}

void GeneralTab::choosePath()
{
	QString dir( QFileDialog::getExistingDirectory(
		filepath_edt->text(), this ) );
	if( !dir.isEmpty() )
		filepath_edt->setText( dir );
}

