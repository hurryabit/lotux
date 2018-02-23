// settingsdialog.cpp
// 16.01.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#include "settingsdialog.h"

SettingsDialog::SettingsDialog( Settings* settings, QWidget* parent,
		const char* name, WFlags f ):
	QTabDialog( parent, name, true, f )
{
	sets = settings != 0 ? settings : new Settings;

	general_tab = new GeneralTab( sets->language(), sets->filePath(), this );
	addTab( general_tab, tr( "&General" ) );

	identity_tab = new IdentityTab( sets->name(), sets->email(), this );
	addTab( identity_tab, tr( "&Identity" ) );

	network_tab = new NetworkTab( sets->server(), sets->port(), this );
	addTab( network_tab, tr( "&Network" ) );

	setCancelButton();
	setApplyButton();

	connect( this, SIGNAL( applyButtonPressed() ), SLOT( applied() ) );
}

SettingsDialog::~SettingsDialog()
{
}

void SettingsDialog::applied()
{
	sets->setLanguage( general_tab->language() );
	sets->setFilePath( general_tab->filePath() );
	sets->setName( identity_tab->name() );
	sets->setEmail( identity_tab->email() );
	sets->setServer( network_tab->server() );
	sets->setPort( network_tab->port() );
}

