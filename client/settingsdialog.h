// settingsdialog.h
// 16.01.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#ifndef SETTINGSDIALOG_H
#define SETTINGSDIALOG_H

#include <qtabdialog.h>

#include "generaltab.h"
#include "networktab.h"
#include "identitytab.h"
#include "settings.h"

class SettingsDialog: public QTabDialog
{
	Q_OBJECT

public:

	SettingsDialog( Settings* settings, QWidget* parent = 0,
		const char* name = 0, WFlags f = 0 );
	~SettingsDialog();

protected slots:

	void applied();

private:

	Settings* sets;

	GeneralTab* general_tab;
	NetworkTab* network_tab;
	IdentityTab* identity_tab;
};

#endif //SETTINGSTAB_H

