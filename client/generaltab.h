// generaltab.h
// 15.01.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#ifndef GENERALTAB_H
#define GENERALTAB_H

#include <qcombobox.h>
#include <qlineedit.h>
#include <qstring.h>
#include <qwidget.h>

class GeneralTab: public QWidget
{
	Q_OBJECT

public:

	GeneralTab( unsigned language, const QString& filepath, QWidget* parent = 0,
		const char* name = 0, WFlags f = 0 );
	~GeneralTab();

	QString filePath() const;
	unsigned language() const;

protected slots:

	void choosePath();

private:

	QComboBox* language_cbx;
	QLineEdit* filepath_edt;
};

#endif //GENERALTAB_H

