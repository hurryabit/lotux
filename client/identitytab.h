// identitytab.h
// 16.01.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#ifndef IDENTITYTAB_H
#define IDENTITYTAB_H

#include <qlineedit.h>
#include <qwidget.h>

class IdentityTab: public QWidget
{
	Q_OBJECT

public:

	IdentityTab( const QString& nickname, const QString& email,
		QWidget* parent = 0, const char* name = 0, WFlags f = 0 );
	~IdentityTab();

	QString name() const;
	QString email() const;

private:

	QLineEdit* name_edt;
	QLineEdit* email_edt;
};

#endif //IDENTITYTAB_H

