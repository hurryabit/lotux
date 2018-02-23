// networktab.cpp
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

#include "networktab.h"

NetworkTab::NetworkTab( const QString& server, Q_UINT16 port, QWidget* parent,
		const char* name, WFlags f ):
	QWidget( parent, name, f )
{
	server_edt = new QLineEdit( server, this );
	QLabel* server_lbl = new QLabel( server_edt, tr( "&Server:" ), this );

	port_edt = new QSpinBox( 0x0001, 0xffff, 1, this );
	port_edt->setValue( port );
	port_edt->setButtonSymbols( QSpinBox::PlusMinus );
	QLabel* port_lbl = new QLabel( port_edt, tr( "&Port:" ), this );

	QVBoxLayout* main_vbl = new QVBoxLayout( this, 10, 10 );
	main_vbl->addStretch();
	main_vbl->addWidget( server_lbl );
	main_vbl->addWidget( server_edt );
	main_vbl->addStretch();
	main_vbl->addWidget( port_lbl );
	main_vbl->addWidget( port_edt );
	main_vbl->addStretch();
}

NetworkTab::~NetworkTab()
{
}

QString NetworkTab::server() const
{
	return server_edt->text();
}

Q_UINT16 NetworkTab::port() const
{
	return (Q_UINT16) port_edt->value();
}

