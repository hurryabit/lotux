// lotus.cpp
// 24.11.2001
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

#include <cctype>
#include <cstring>

#include "lotus.h"

////////////////////////////////////////////////////////////////////////////////
// Stone

const Stone Stone::S('S'), Stone::W('W'), Stone::X('X');

bool Stone::setStone( char c )
{
	switch( c )
	{
		case 'S':
		case 'W':
			_stone = c;
			return true;
		default:
			_stone = 'X';
			return false;
	}
}

Stone Stone::operator!() const
{
	switch( _stone )
	{
		case 'S': return Stone( 'W' );
		case 'W': return Stone( 'S' );
		default: return Stone( 'X' );
	}
}

////////////////////////////////////////////////////////////////////////////////
// Move

const Move Move::Invalid( 25 );

bool Move::read( const char* s )
{
	_num = 25;
	_valid = false;
	size_t l( strlen( s ) );

	// s must have length 5 or 6, the first char must be '(', the last ')' and
	// the one 2 before the last ','
	if( l != 5 && l != 6 || s[0] != '(' || s[l - 3] != ',' || s[l - 1] != ')' )
		return false;

	// 2nd char must be a digit
	if( !isdigit( s[1] ) )
		return false;

	short unsigned int num( s[1] - '0' );

	if( l == 6 )
	{
		// first digit of number must be 1 or 2
		if( num != 1 && num != 2 )
			return false;
		// 3rd char also must be a digit if length is 6
		if( !isdigit( s[2] ) )
			return false;

		num *= 10;
		num += s[2] - '0';
	}

	switch( s[l - 2] )
	{
		case 'L':
			_dir = Left;
			break;
		case 'R':
			_dir = Right;
			break;
		default:
			return false;
	}

	_num = num;
	return ( _valid = true );
}

const char* Move::show() const
{
	_str[0] = '(';
	int i(1);
	if( _num >= 10 )
		_str[i++] = '0' + _num / 10;
	_str[i] = '0' + _num % 10;
	_str[i + 1] = ',';
	_str[i + 2] = _dir == Left ? 'L' : 'R';
	_str[i + 3] = ')';
	_str[i + 4] = '\0';
	return _str;
}


////////////////////////////////////////////////////////////////////////////////
// Heap

bool Heap::setHeap( short unsigned int h, const Stone& c )
{
	if( c == Stone::X )
	{
		clear();
		return false;
	}
	if( h > 20 )
		h = 20;

	for( short unsigned int i(0); i < h; ++i )
		_heap[i] = c;
	_h = h;

	if( c.isS() )
	{
		_s = h;
		_w = 0;
	}
	else
	{
		_s = 0;
		_w = h;
	}
	return true;
}

Stone Heap::popTop()
{
	if( _h == 0 )
		return Stone::X;

	--_h;
	Stone c( _heap[_h] );
	if( c.isS() )
		--_s;
	else
		--_w;
	return c;
}

bool Heap::pushTop( const Stone& c )
{
	if( !c.isValid() || c.isS() && _s >= 10 || c.isW() && _w >= 10 )
		return false;

	_heap[_h] = c;
	++_h;
	if( c.isS() )
		++_s;
	else
		++_w;
	return true;
}


////////////////////////////////////////////////////////////////////////////////
// Lotus

void Lotus::init( bool start )
{
	for( int i(0); i < 17; ++i )
		field[i] = Heap();
	for( int i(0); i < 4; ++i)
		black[i] = white[i] = start ? i + 1 : 0;
}

bool Lotus::canMove( const Stone& c, short unsigned int num ) const
{
	if( num < 17 )
		return field[num].isEmpty() ? false : field[num].top() == c;
	if( num < 21 )
		return c.isS() && black[ num - 17 ] > 0;
	if( num < 25 )
		return c.isW() && white[ num - 21 ] > 0;
	return false;
}

bool Lotus::canMoveAny( const Stone& c ) const
{
	for( short unsigned int i(0); i < 25; ++i )
		if( canMove( c, i ) )
			return true;
	return false;
}

bool Lotus::eog() const
{
	// counting black and white stones
	short unsigned int s(0), w(0);
	for( int i(0); i < 17; ++i )
	{
		s += field[i].black();
		w += field[i].white();
	}
	for( int i(0); i < 4; ++i )
	{
		s += black[i];
		w += white[i];
	}
	// one of the numbers is 0?
	return s * w == 0;
}

bool Lotus::move( const Stone& c, const Move& m )
{
	short unsigned int num( m.num() );
	// player must be allowed to move
	if( !canMove( c, num ) )
		return false;
	if( num < 17 )
	{
		short unsigned int h( field[num].height() );
		field[num].popTop();
		// number of target square
		short int t( (short int) num - (short int) h );
		// stone moves down from right arm?
		if( num >= 14 && t < 14 )
			t -= 3;
		if( t >= 0 )
		 field[t].pushTop( c );
		return true;
	}
	else
		if( num < 21 )
		{
			short unsigned int f( num - 17 );
			if( black[f] == 4 )
				field[10].pushTop( c );
			else
				field[ ( m.dir() == Move::Left ? 14 : 17)  - black[f] ].pushTop( c );
			--black[f];
		}
		else
		{
			short unsigned int f( num - 21 );
			if( white[f] == 4 )
				field[10].pushTop( c );
			else
				field[ ( m.dir() == Move::Left ? 14 : 17 ) - white[f] ].pushTop( c );
			--white[f];
		}
	return true;
}

bool Lotus::needDir( short unsigned int num ) const
{
	// move starts on start square an heap is lower than 4 stones
	if( 16 < num && num < 21 )
		return black[ num - 17 ] < 4;
	if( 20 < num && num < 25 )
		return white [ num - 21 ] < 4;
	return false;
}

Heap Lotus::heap( short unsigned int num ) const
{
	if( num < 17 )
		return field[num];
	else if( num < 21 )
		return Heap( black[num - 17], Stone::S );
	else if( num < 25 )
		return Heap( white[num - 21], Stone::W );
	else
		return Heap();
}

