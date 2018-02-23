// lotus.h
// 24.11.2001
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett



#ifndef LOTUS_H
#define LOTUS_H

#include <cstdlib>
#include <cstring>
#include <ctime>


/**
* This is a class for pieces in a game with two different types of pieces.
* In this case there are black (S) and white (W) pieces. There are also
* invalid ones (X).
*
* This class also provides functions for conversion between characters and
* pieces.
* @short A class for pieces in a game with two different types of pieces.
* @author Copyright (C) 2001-2002 by Carsten Moldenhauer and Martin Huschenbett
*/
class Stone
{
public:
	/**
	* Static constant for a black piece
	*/
	static const Stone S;
	/**
	* Static constant for a white piece
	*/
	static const Stone W;
	/**
	* Static Constant for an invalid piece
	*/
	static const Stone X;

	/**
	* Constructs an invalid piece
	*/
	Stone();
	/**
	* Constructs a piece from c.
	* @param c Determines the kind of the piece (from 'S' a black, from
	* 'W' a white and from all others an invalid piece is constructed)
	*/
	explicit Stone( char c );

	/**
	* Sets the piece according to c.
	* @param c Determines the kind og the piece in the same way as the similar
	* constructor
	* @return Whether the pieces was set to a valid one
	*/
	bool setStone( char c );

	/**
	* Checks whether the piece is black.
	* @return Whether the piece is black
	*/
	bool isS() const;
	/**
	* Checks whether the piece is white.
	* @return Whether the piece is white
	*/
	bool isW() const;
	/**
	* Checks whether the piece is valid.
	* @return Whether the piece is valid
	*/
	bool isValid() const;

	/**
	* Detects the color of the pieces of the opponent. Black is the opponent
	* of white and vice versa and the opponent of an invalid player is also an
	* in invalid player.
	* @return The color of the pieces of the opponent
	*/
	Stone operator!() const;
	/**
	* Converts the piece into a character. For a black one a 'S', for a white
	* one a 'W' and for an invalid a 'X'.
	* @return The character of for the piece.
	*/
	operator char() const;

private:
	char _stone;
};


/**
* This is a class for moves in a Lotus game.
* A move consists of the number of the start square (an integer between 0 and
* 24, incl.) and a direction (either left or right) which is only is important
* if a piece is moved from a start square.
*
* This class also provides functions for conversion between strings and moves.
* A description string must have the form
* &quot;(<em>num</em>, <em>dir</em>)&quot; where <em>num</em> has to be an
* integer between 0 and 24 (incl.) without any leading zero. <em>dir</em> must
* be 'L' (for left) or 'R' (for right). Strings which are not of this form
* will result invalid moves.
*
* @short A class for moves in a Lotus game.
* @author Copyright (C) 2001-2002 by Carsten Moldenhauer and Martin Huschenbett
*/
class Move
{
public:
	/**
	* A static constant for an invalid move
	*/
	static const Move Invalid;

	/**
	* A enumerator for the directions left and right
	*/
	enum Direction { Left, Right };

	/**
	* Constructs an invalid move
	*/
	Move();
	/**
	* Constructs a move according to the parameters.
	* @param number Number of the square the move starts on, is directly passed to
	* setNum()
	* @param direction Direction of the move
	* @see setNum()
	* @see setDir()
	*/
	explicit Move( short unsigned int number, Direction direction = Left );
	/**
	* Constructs a move according to the description string.
	* @param s Description string, is dirctly passed to read()
	* @see read(), setMove()
	*/
	explicit Move( const char* s );

	/**
	* Sets the number of the square the move starts on.
	* @param number Number of the square the move starts on
	* @return Whether the resulting move is valid
	*/
	bool setNum( short unsigned int number );
	/**
	* Sets the direction of the move
	* @param direction Direction of the move
	*/
	void setDir( Direction direction );
	/**
	* Sets the move according to the description string.
	* @param s Description string, is directly passed to read()
	* @return Whether the resulting move is valid
	* @see read()
	*/
	bool setMove( const char* s );

	/**
	* Returns the number of the square the move starts on.
	* @return Number of the square the move starts on
	* @see setNum()
	* @see dir()
	*/
	short unsigned int num() const;
	/**
	* Returns the direction of the move.
	* @return Direction of the move
	* @see setDir()
	* @see num()
	*/
	Direction dir() const;

	/**
	* Checks whether the move is valid.
	* @return Whether the move is valid.
	*/
	bool isValid() const;
	/**
	* Checks whether the direction is of the move left.
	* @return Whether the direction of the move is left
	* @see right()
	*/
	bool left() const;
	/**
	* Checks whether the direction is of the move right.
	* @return Whether the direction of the move is right
	* @see left()
	*/
	bool right() const;

	/**
	* Sets the move according to the description string.
	* The expected format is explained in the detailed description.
	* @param s Description string
	* @return Whether a valid move resulted
	* @see show()
	* @see setNum()
	*/
	bool read( const char* s );
	/**
	* Converts the move in a string of the form which read() expects.
	* The string is stored in an internal buffer.
	* @return Pointer to the buffer
	* @see read()
	*/
	const char* show() const;

private:
	short unsigned int _num;
	Direction _dir;
	bool _valid;
	mutable char _str[7];
};


/**
* This is a class for heaps of pieces in a Lotus game.
* A heap just consists of black and white stones. It's height is limited to 20
* pieces as there are only 10 black and 10 white pieces in a usual Lotus game.
* @short A class for heaps of pieces in a Lotus game.
* @author Copyright (C) 2001-2002 by Carsten Moldenhauer and Martin Huschenbett
*/

class Heap
{
public:
	/**
	* Constructs an empty heap with no pieces.
	*/
	Heap();
	/**
	* Constructs a heap of height #h# which consists of pieces of the kind of #c#.
	* The parameters are directly passed to setHeap().
	* @param h Height of the resulting heap
	* @param c Color of the pieces
	* @see setHeap()
	*/
	Heap( short unsigned int h, const Stone& c );

	/**
	* Sets the heap to a certain height consisting of just one kind of pieces.
	* The resulting cannot have a height greater than 20 or consist of
	* invalid pieces. If one wants to create such a heap an empty one is created
	* instead.
	* @param h Heigth of the heap
	* @param c Color of the pieces
	* @return Whether the heap could be created
	*/
	bool setHeap( short unsigned int h, const Stone& c );

	/**
	* Takes the piece from the top of the heap.
	* @return A copy of this piece or an invalid one if the heap is empty.
	* @see top()
	* @see pushTop()
	* @see isEmpty()
	*/
	Stone popTop();
	/**
	* Pushes a piece on the top of the heap, if the piece is valid and there are
	* less then 10 pieces of this kind in the heap.
	* @param c Color of the piece
	* @return Whether the piece could be pushed
	* @see popTop()
	* @see black()
	* @see white()
	*/
	bool pushTop( const Stone& c );
	/**
	* Removes all pieces from the heap.
	*/
	void clear();

	/**
	* Checks whether the heap is empty.
	* @return Whether the heao is empty
	* @see height()
	*/
	bool isEmpty() const;
	/**
	* Checks whether the heap contains at least one black piece.
	* @return Whether the heap has a black piece
	* @see hasWhite()
	* @see isEmpty()
	*/
	bool hasBlack() const;
	/**
	* Checks whether the heap contains at least one white piece.
	* @return Whether the heap has a white piece
	* @see hasBlack()
	* @see isEmpty()
	*/
	bool hasWhite() const;

	/**
	* Detects the height of a heap.
	* @return Number of pieces in the heap
	* @see isEmpty()
	* @see black()
	* @see white()
	*/
	short unsigned int height() const;
	/**
	* Detects the number of black pieces in the heap.
	* @return Number of black pieces in the heap
	* @see hasBlack()
	* @see white()
	* @see height()
	*/
	short unsigned int black() const;
	/**
	* Detects the number of white pieces in the heap.
	* @return Nnumber of white pieces in the heap
	* @see hasWhite()
	* @see black()
	* @see height()
	*/
	short unsigned int white() const;

	/**
	* Dectects a pieces at a certain position in the heap.
	* @param h Position of the piece, where zero is the bottom
	* @return A copy of the piece at the position or an invalid piece,
	* if this position does not exist in this heap
	* @see top()
	* @see bottom()
	*/
	Stone stone( short unsigned int h ) const;
	/**
	* Detects the piece at the top of the heap.
	* @return A copy of the highest piece or an invalid piece if the heap is
	* empty
	* @see bottom()
	* @see stone()
	* @see popTop()
	* @see pushTop()
	*/
	Stone top() const;
	/**
	* Detects the piece at the bottom of the piece.
	* @return A copy of the lowest piece or an invalid piece if the heap is empty
	* @see top()
	* @see stone()
	*/
	Stone bottom() const;

private:
	Stone _heap[20];
	short unsigned int _h, _s, _w;
};


/**
* This is a class for complete situations of a usual Lotus game.
* There is no direct access to the pieces, you just can get information about
* the situation or move single pieces.
* @short A class for complete situations of a usual Lotus game.
* @author Copyright (C) 2001-2002 by Carsten Moldenhauer & Martin Huschenbett
*/

class Lotus
{
public:
	/**
	* Constructs a start situation.
	* @param start Determines whether pieces shall be placed on the start squares,
	* is directly passed to init()
	* @see init()
	*/
	Lotus( bool start = true );

	/**
	* Sets the situation to the start situation.
	* @param start Determines whether pieces shall be placed on the start squares
	*/
	void init( bool start );

	/**
	* Checks whether a player can do a move on a certain square.
	* @param c Color of the player
	* @param num Number of the square
	* @return Whether the player can do a move on the square
	*/
	bool canMove( const Stone& c, short unsigned int num ) const;
	/**
	* Checks whether a player can do any move.
	* @param c Color of the player
	* @return Whether the player can do any move
	* @see canMoveAny()
	* @see move()
	*/
	bool canMoveAny( const Stone& c ) const;
	/**
	* Checks whether in this situation the end of the game has been reached.
	* @return Whether the end of game has been reached
	* @see canMoveAny()
	*/
	bool eog() const;
	/**
	* Returns the heap on a certain square of the situation.
	* @param num Number of the square
	* @return A copy of the heap or an empty one if the square does not exist
	*/
	Heap heap( short unsigned int num ) const;
	/**
	* Checks whether a move on a certain square also needs a direction to be
	* unique.
	* @param num Number of the square.
	* @return Whether a direction is necessary
	*/
	bool needDir( short unsigned int num ) const;
	/**
	* Lets a certain play do a move in the situation.
	* @param c Color of the player.
	* @param m Move the player wants to do
	* @return Whether the player could do this move
	* @see canMove()
	*/
	bool move( const Stone& c, const Move& m );

	friend class PackedLotus;

private:
	Heap field[17];
	short unsigned int black[4], white[4];
};


////////////////////////////////////////////////////////////////////////////////
// Stone

inline Stone::Stone():
	_stone( 'X' )
{
}

inline Stone::Stone( char c )
{
	setStone( c );
}

inline bool Stone::isValid() const
{
	return _stone == 'S' || _stone == 'W';
}

inline bool Stone::isS() const
{
	return _stone == 'S';
}

inline bool Stone::isW() const
{
	return _stone == 'W';
}

inline Stone::operator char() const
{
	return _stone;
}


////////////////////////////////////////////////////////////////////////////////
// Move

inline Move::Move():
	_num( 25 ), _dir( Left ), _valid( false )
{
}

inline Move::Move( short unsigned int num, Direction dir = Left ):
	_dir( dir )
{
	setNum( num );
}

inline Move::Move( const char* s )
{
	setMove( s );
}

inline bool Move::setNum( short unsigned int num )
{
	return _valid = ( _num = num ) < 25;
}

inline void Move::setDir( Direction dir )
{
	_dir = dir;
}

inline bool Move::setMove( const char* s )
{
	return read( s );
}

inline short unsigned int Move::num() const
{
	return _valid ? _num : 25;
}

inline Move::Direction Move::dir() const
{
	return _dir;
}

inline bool Move::isValid() const
{
	return _valid;
}

inline bool Move::left() const
{
	return _dir == Left;
}

inline bool Move::right() const
{
	return _dir == Right;
}


////////////////////////////////////////////////////////////////////////////////
// Heap

inline Heap::Heap():
	_h( 0 ), _s( 0 ), _w( 0 )
{
}

inline Heap::Heap( short unsigned int h, const Stone& c )
{
	setHeap( h, c );
}

inline void Heap::clear()
{
	_h = _s = _w = 0;
}

inline bool Heap::isEmpty() const
{
	return _h == 0;
}

inline bool Heap::hasBlack() const
{
	return _s != 0;
}

inline bool Heap::hasWhite() const
{
	return _w != 0;
}

inline short unsigned int Heap::height() const
{
	return _h;
}

inline short unsigned int Heap::black() const
{
	return _s;
}

inline short unsigned int Heap::white() const
{
	return _w;
}

inline Stone Heap::stone( short unsigned int h ) const
{
	return h < _h ? _heap[h] : Stone::X;
}

inline Stone Heap::top() const
{
	return _h != 0 ? _heap[_h - 1] : Stone::X;
}

inline Stone Heap::bottom() const
{
	return _h != 0 ? _heap[0] : Stone::X;
}


////////////////////////////////////////////////////////////////////////////////
// Lotus

inline Lotus::Lotus( bool start )
{
	init( start );
}


#endif //LOTUS_H

