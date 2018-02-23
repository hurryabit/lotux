// identitytab.cpp
// 16.01.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#include <qlabel.h>
#include <qlayout.h>

#include "identitytab.h"

IdentityTab::IdentityTab( const QString& nickname, const QString& email,
		QWidget* parent, const char* name, WFlags f ):
	QWidget( parent, name, f )
{
	name_edt = new QLineEdit( nickname, this );
	QLabel* name_lbl = new QLabel( name_edt, tr( "&Name:" ), this );

	email_edt = new QLineEdit( email, this );
	QLabel* email_lbl = new QLabel( email_edt, tr( "&Email:" ), this );

	QVBoxLayout* main_vbl = new QVBoxLayout( this, 10, 10 );
	main_vbl->addStretch();
	main_vbl->addWidget( name_lbl );
	main_vbl->addWidget( name_edt );
	main_vbl->addStretch();
	main_vbl->addWidget( email_lbl );
	main_vbl->addWidget( email_edt );
	main_vbl->addStretch();
}

IdentityTab::~IdentityTab()
{
}

QString IdentityTab::name() const
{
	return name_edt->text();
}

QString IdentityTab::email() const
{
	return email_edt->text();
}

