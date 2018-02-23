// networktab.h
// 16.01.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#ifndef NETWOTKTAB_H
#define NETWORKTAB_H

#include <qlineedit.h>
#include <qspinbox.h>
#include <qstring.h>
#include <qwidget.h>

class NetworkTab: public QWidget
{
	Q_OBJECT

public:

	NetworkTab( const QString& server, Q_UINT16 port, QWidget* parent = 0,
		const char* name = 0, WFlags f = 0 );
	~NetworkTab();

	QString server() const;
	Q_UINT16 port() const;

private:

	QLineEdit* server_edt;
	QSpinBox*  port_edt;
};

#endif //NETWORKTAB_H

