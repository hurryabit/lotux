// lotus3d.h
// 22.11.2001
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#ifndef LOTUS3D_H
#define LOTUS3D_H

#include <cmath>

#include <qframe.h>
#include <qgl.h>
#include <qimage.h>
#include <qpoint.h>
#include <qtimer.h>

#include "lotus.h"

class Lotus3DGL;

class Lotus3D: public QFrame
{
	Q_OBJECT

public:

	Lotus3D( const QColor& color = white, QWidget* parent = 0,
		const char* name = 0, WFlags = 0 );
	~Lotus3D();

public slots:

	void drawLotus( Lotus l );

signals:

	void move( unsigned x );

protected:

	void resizeEvent( QResizeEvent* e );

private:

	Lotus3DGL* lotus3d;
	static const int border = 5;
};

class Lotus3DGL: public QGLWidget
{
	Q_OBJECT

public:
	
	Lotus3DGL( const QColor& color = white, QWidget* parent = 0,
		const char* name = 0, WFlags f = 0 );
	~Lotus3DGL();
	
public slots:
	
	void drawLotus( Lotus l );

signals:

	void move( unsigned x );
	
protected:

	void initializeGL();
	void paintGL();
	void resizeGL( int w, int h );
	
	void rotate( GLint angle );
	
	virtual void makeObject( const Lotus& l );
	
	void drawStone( unsigned num, unsigned height );
	void drawCap( unsigned num, unsigned height );
	
	virtual void mouseMoveEvent( QMouseEvent* e );
	virtual void mousePressEvent( QMouseEvent* e );
	virtual void mouseReleaseEvent( QMouseEvent* e );
	
	void mouseClick( const QPoint& p );

	GLfloat Sin( int x ) const;
	GLfloat Cos( int x ) const;
	GLfloat yFunc( GLfloat y, GLfloat z ) const;
	GLfloat zFunc( GLfloat z ) const;
	GLint ray( GLfloat w, GLint z ) const;
	GLint xCoord( GLfloat x, GLfloat z ) const;
	GLint yCoord( GLfloat y, GLfloat z ) const;
	QPoint coords( GLfloat x, GLfloat y, GLfloat z ) const;
	bool isInside( int x, int a, int b ) const; // Returns wether x is in [a, b]
	GLfloat centerX( unsigned num ) const;
	GLfloat centerY( unsigned num ) const;
	
	static const GLint angles[17];
	static const GLfloat inner = 2.54, outer = 4.10;
	static const GLfloat stoneh = 0.05, stoner = 0.5;
	static const GLuint degstep = 24;
	static const GLuint zVal[31], yVal[31];

protected slots:

	void rotateLeft();
	void rotateRight();

private:

	GLuint object;
	QImage board_img, black_img, white_img;
	GLint rotation;
	QColor bgcolor;
	int mouseX;
	bool mouseOn, mouseMove;
	Lotus lotus;
};

inline void Lotus3DGL::rotateLeft()
{
	rotate( 5 );
}

inline void Lotus3DGL::rotateRight()
{
	rotate( -5 );
}

inline GLint Lotus3DGL::ray( GLfloat w, GLint z ) const
{
	return ( GLint ) floor( w * z * 0.133868 * width() / 800.0 ); // 0.133868 = 668 / 10 / 499
}

inline GLint Lotus3DGL::xCoord( GLfloat x, GLfloat z ) const
{
	return ( GLint ) floor( ( 400.0 + 0.133868 * x * zFunc( z ) ) * width() / 800.0 ); // 0.133868 = 668 / 10 / 499
}

inline GLint Lotus3DGL::yCoord( GLfloat y, GLfloat z ) const
{
	return ( GLint ) floor( ( zFunc( z ) - yFunc( y, z ) ) * height() / 600.0 );
}

inline bool Lotus3DGL::isInside( int x, int a, int b ) const
{
	return a < b ? a <= x && x <= b : b <= x && x <= a;
}

inline GLfloat Lotus3DGL::centerX( unsigned num ) const
{
	GLfloat mx;
	if( num < 17 )
		mx = Cos( angles[num] ) * ( num < 10 ? outer : inner );
	else
		mx = ( stoner + 0.1 ) * ( num < 21 ? -1 : 1 );
	return mx;
}

inline GLfloat Lotus3DGL::centerY( unsigned num ) const
{
	GLfloat my;
	if( num < 17 )
		my = -Sin( angles[num] ) * ( num < 10 ? outer : inner );
	else
		my = inner - stoner - 1.0  - ( ( num - 1 ) % 4 ) * ( 2.0 * stoner +0.1 );
	return my;
}

inline GLfloat Lotus3DGL::Sin( int x ) const
{
	return sin( x / 180.0 * M_PI );
}
	
inline GLfloat Lotus3DGL::Cos( int x ) const
{
	return cos( x / 180.0 * M_PI );
}
	
#endif //LOTUS3D_H
