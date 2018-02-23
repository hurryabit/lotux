// lotus3d.cpp
// 22.11.2002
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#include <iostream>
#include <map>

#include <qaccel.h>
#include <qmessagebox.h>
#include <qstring.h>

#include "lotux256.xpm"
#include "blackstone.xpm"
#include "whitestone.xpm"

#include "lotus3d.h"


// class Lotus3D

Lotus3D::Lotus3D( const QColor& color, QWidget* parent, const char* name,
		WFlags f ):
  QFrame( parent, name, f )
{
	setFrameStyle( Sunken | Panel );
	setLineWidth( border );
	setMinimumSize( 400 + 2 * border, 300 + 2 * border );

	lotus3d = new Lotus3DGL( color, this );

	connect( lotus3d, SIGNAL( move( unsigned ) ), SIGNAL( move( unsigned ) ) );
}

Lotus3D::~Lotus3D()
{
}

void Lotus3D::drawLotus( Lotus l )
{
	lotus3d->drawLotus( l );
}

void Lotus3D::resizeEvent( QResizeEvent* e )
{
	lotus3d->setGeometry( border, border, e->size().width() - 2 * border,
		e->size().height() - 2 * border );
}


// class Lotus3dGL

const GLint Lotus3DGL::angles[17] =
	{ 306, 342, 18, 54, 90, 126, 162, 198, 234, 270,
	270, 234, 198, 162, 306, 342, 18 };

const GLuint Lotus3DGL::zVal[31] =
	{ 272, 277, 283, 288, 294, 299, 306, 312, 319, 326, 333, 340, 348, 357,
	365, 374, 384, 394, 405, 416, 428, 441, 454, 468, 483, 499, 517, 535,
	555, 576, 599 };
	
const GLuint Lotus3DGL::yVal[31] =
	{ 162, 165, 169, 172, 176, 179, 183, 187, 191, 195, 199, 203, 208, 213,
	218, 224, 230, 236, 242, 249, 256, 264, 272, 280, 289, 299, 310, 320,
	332, 345, 359 };

Lotus3DGL::Lotus3DGL( const QColor& color, QWidget* parent, const char* name,
	WFlags f ) :
		QGLWidget( parent, name, 0, f ), object(0), rotation(0), bgcolor( color ),
		mouseOn( false ), mouseMove( false ), lotus( false )
{
	// Load the needed textures
	board_img = QGLWidget::convertToGLFormat(
		QImage( (const char**) lotux256_xpm ) );
	black_img = QGLWidget::convertToGLFormat(
		QImage( (const char**) blackstone_xpm ) );
	white_img = QGLWidget::convertToGLFormat(
		QImage( (const char**) whitestone_xpm ) );

	// Create the hotkeys
	QAccel* a = new QAccel( this );
	a->insertItem( Key_Left, 101 );
	a->insertItem( Key_Right, 102 );
	a->connectItem( 101, this, SLOT( rotateLeft() ) );
	a->connectItem( 102, this, SLOT( rotateRight() ) );
}

Lotus3DGL::~Lotus3DGL()
{
	makeCurrent();
	glDeleteLists( object, 1 );
}

void Lotus3DGL::initializeGL()
{
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
	glTexParameterf( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
	glEnable( GL_TEXTURE_2D );

	qglClearColor( bgcolor );
	glEnable( GL_DEPTH_TEST );
	glHint( GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST );

	object = glGenLists(1);

	makeObject( lotus );
}

void Lotus3DGL::paintGL()
{
	GLfloat scale = 1.0;
	
	glClear( GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT );
	
	glPushMatrix();
	glRotatef( (GLfloat) rotation, 0.0, 1.0, 0.0 );
	glScalef( scale, scale, scale );
	glCallList( object );
	glPopMatrix();
	
}

void Lotus3DGL::resizeGL( int w, int h )
{
	glViewport( 0, 0, (GLint) w, (GLint) h );
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	glFrustum( -4.0, 4.0, -0.8, 0.0, 10.0, 50.0 );
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
	glTranslatef( 0.0, 0.0, -20.0 );
}

void Lotus3DGL::makeObject( const Lotus& l )
{
	glNewList( object, GL_COMPILE );

	glTranslatef( 0.0, -1.0, 0.0 );

	// Load the texture for the board
	glTexImage2D( GL_TEXTURE_2D, 0, 3, board_img.width(), board_img.height(),
		0, GL_RGBA, GL_UNSIGNED_BYTE, board_img.bits() );

	// Draw the board
	glBegin( GL_QUADS );
		glTexCoord2f( 0.0, 1.0 ); glVertex3f( -5.0,  0.0, -5.0 );
		glTexCoord2f( 0.0, 0.0 ); glVertex3f( -5.0,  0.0,  5.0 );
		glTexCoord2f( 1.0, 0.0 ); glVertex3f(  5.0,  0.0,  5.0 );
		glTexCoord2f( 1.0, 1.0 ); glVertex3f(  5.0,  0.0, -5.0 );
	glEnd();
	
	// Load the texture for the black stones
	glTexImage2D( GL_TEXTURE_2D, 0, 3, black_img.width(), black_img.height(),
		0, GL_RGBA, GL_UNSIGNED_BYTE, black_img.bits() );

	// Draw the black stones
	for( unsigned short int i(0); i < 25; ++i )
	{
		Heap h( l.heap(i) );
		for( unsigned short int j(0); j < h.height(); ++j )
			if( h.stone(j).isS() )
				drawStone( i, j );
		// If last stone is black then draw cap
		if( h.top().isS() )
			drawCap( i, h.height() - 1 );
	}
	
	// Load the texture for the white stones
	glTexImage2D( GL_TEXTURE_2D, 0, 3, white_img.width(), white_img.height(),
		0, GL_RGBA, GL_UNSIGNED_BYTE, white_img.bits() );

	// Draw the white stones
	for( unsigned short int i(0); i < 25; ++i )
	{
		Heap h( l.heap(i) );
		for( unsigned short int j(0); j < h.height(); ++j )
			if( h.stone(j).isW() )
				drawStone( i, j );
		// If last stone is black then draw cap
		if( h.top().isW() )
			drawCap( i, h.height() - 1 );
	}

	glEndList();
}

void Lotus3DGL::drawStone( unsigned num, unsigned height )
{
	if( num >= 25 )
		return;
	GLfloat bottom( height * stoneh ), top( bottom + stoneh ),
		mx( centerX( num ) ), my( centerY( num ) );
	GLfloat x( stoner + mx ), y( my );
	glBegin( GL_QUADS );
	GLuint i(0);
	while( i < 360)
	{
		glTexCoord2f( 0.0, 0.0 ); glVertex3f( x, bottom, y );
		glTexCoord2f( 0.0, 1.0 ); glVertex3f( x, top,    y );
		i += degstep;
		x = Cos( i ) * stoner + mx;
		y = Sin( i ) * stoner + my;
		glTexCoord2f( 1.0, 1.0 ); glVertex3f( x, top,    y );
		glTexCoord2f( 1.0, 0.0 ); glVertex3f( x, bottom, y );
	}
	glEnd();
}

void Lotus3DGL::drawCap( unsigned num, unsigned height )
{
	if( num >= 25 )
		return;
	GLfloat h( ( height + 1 ) * stoneh ), mx( centerX( num ) ),
		my( centerY( num ) );
	glBegin( GL_POLYGON );
	for( GLuint i(0); i < 360; i += degstep )
	{
		glTexCoord2f( 0.5 * Cos( i ) + 0.5, 0.5 * Sin( i ) + 0.5 );
		glVertex3f( Cos( i ) * stoner + mx, h, Sin( i ) * stoner + my );
	}
	glEnd();
}

void Lotus3DGL::drawLotus( Lotus l )
{
	lotus = l;
	makeObject( lotus );
	updateGL();
}

void Lotus3DGL::rotate( GLint angle )
{
	rotation += angle;
	while( rotation < 0 )
		rotation += 360;
	rotation %= 360;
	updateGL();
}

void Lotus3DGL::mousePressEvent( QMouseEvent* e )
{
	if( e->button() & Qt::LeftButton != 0 )
	{
		mouseX = e->x();
		mouseOn = true;
		mouseMove = false;
		e->accept();
	}
	else
		e->ignore();
}

void Lotus3DGL::mouseMoveEvent( QMouseEvent* e )
{
	if( mouseOn )
	{
		int x( e->x() );
		rotate( floor( 180.0 * ( mouseX - x ) / width() ) *
			( e->y() < 0.625 * height() ? 1 : -1 ) );
		mouseX = x;
		mouseMove = true;
		e->accept();
	}
	else
		e->ignore();
}

void Lotus3DGL::mouseReleaseEvent( QMouseEvent* e )
{
	if( e->button() & Qt::LeftButton != 0 )
	{
		mouseOn = false;
		if( !mouseMove )
			mouseClick( e->pos() );
		e->accept();
	}
	else
		e->ignore();
}

void Lotus3DGL::mouseClick( const QPoint& p )
{
	multimap<int, unsigned> centers;
	for( unsigned i(0); i < 25; ++i )
	{
		QPoint q( coords( centerX( i ), 0, centerY( i ) ) );
		centers.insert( make_pair( q.y(), i ) );
	}
	
	bool ok( false );
	unsigned num( 0 );
	
	for( multimap<int, unsigned>::reverse_iterator i( centers.rbegin() );
		i != centers.rend() && !ok; ++i )
	{
		num = i->second;
		QPoint q1( coords( centerX( num ), 0, centerY( num ) ) ),
			q2( coords( centerX( num ),
			lotus.heap(num).height() * stoneh, centerY( num ) ) );
		GLint w( ray( stoner, q1.y() ) );
		ok = isInside( p.x(), q1.x() - w, q1.x() + w ) && isInside( p.y(),
			q1.y(), q2.y() );
	}
	if( ok )
		emit move( num );
}

GLfloat Lotus3DGL::yFunc( GLfloat y, GLfloat z ) const
{
	if( z < -7.5 )
		return zVal[0];
	if( z > 7.5 )
		return zVal[30];
	z += 7.5;
	GLint idx( ( GLint ) floor( 2.0 * z ) );
	GLfloat diff( 2.0 * z - idx );
	return ( ( 1 - diff ) * yVal[idx] + diff * yVal[ idx + 1 ] ) * y / 0.6;
}

GLfloat Lotus3DGL::zFunc( GLfloat z ) const
{
	if( z < -7.5 )
		return zVal[0];
	if( z > 7.5 )
		return zVal[30];
	z += 7.5;
	GLint idx( ( GLint ) floor( 2.0 * z ) );
	GLfloat diff( 2.0 * z - idx );
	return ( 1 - diff ) * zVal[idx] + diff * zVal[ idx + 1 ];
}

QPoint Lotus3DGL::coords( GLfloat x, GLfloat y, GLfloat z ) const
{
	GLfloat r( sqrt( x * x + z * z ) );
	GLuint phi;
	if( z == 0.0 )
		phi = x < 0.0 ? 180 : 0;
  else
		phi = ( GLint ) floor( acos( x / r ) * ( z < 0.0 ? -1.0 : 1.0 ) *
			180.0 / M_PI );

	GLfloat xn(  Cos( phi - rotation ) * r ), zn( Sin( phi - rotation ) * r );
	return QPoint( xCoord( xn, zn ), yCoord( y, zn ) );
}
