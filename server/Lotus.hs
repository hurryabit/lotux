-- Lotus.hs
-- 16.10.2001
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

---
-- This module provides data types for complete lotus game situations and
-- functions to use them.
-- @author Copyright (C) 2001-2002 by Carsten Moldenhauer and Martin Huschenbett
module Lotus
(
	Direction( .. ), Move, Stone( .. ), Heap, Lotus,
	newGame, next, move, moveNC,
	canMove, canMoveAny, eog,
	nextMoves, getHeaps,
	isLotus, isHead,
	countS, other
) where

import Prelude hiding( Either( .. ) )
import Functions( count, isHead )

---
-- Type for the directions left and right of a move in a Lotus game.
-- @cons Left - Constructor for left
-- @cons Right - Constructor for right
data Direction = Left | Right
	deriving ( Eq, Ord, Read )

instance Show Direction where
---
-- Functions to show a direction in the usual manner. For LLeft a 'L' and for
-- LRight a 'R' is shown.
	show Left = "L"
	show Right = "R"

---
-- Type for moves in a Lotus game.
-- A move consists of the number of the start square (an integer between 0 and
-- 24, incl.) and a direction (either left or right) which is only is important
-- if a piece is moved from a start square.
type Move = ( Int, Direction )

--- 
-- Type for black and white pieces in a Lotus game.
-- This type is also used for colors of the two players.
-- @cons S - Constructor for a black piece
-- @cons W - Constructor for a white piece
data Stone = S | W
	deriving ( Eq, Ord, Show, Read )

---
-- Type for heaps in a Lotus game.
-- A heap is just a list of pieces.
type Heap = [ Stone ]

---
-- Type for complete situations in a Lotus game.
-- They consists of the main part of the map, the left and the right arm and
-- the start squares for black and white, respectively.
type Lotus = ( [ Heap ], [ Heap ], [ Heap ], [ Int ], [ Int ] )

---
-- Constant function for the situation at the beginning of a game.
newGame :: Lotus
newGame =
	([[],[],[],[],[],[],[],[],[],[],[]],[[],[],[]],[[],[],[]],[1,2,3,4],[1,2,3,4])

---
-- Options of a player in a certain situation.
-- @param situation - Situation the player shall move in
-- @param player - Player that shall move
-- @return options - Ooptions of the player in the situation
-- @see nextMoves
-- @see move
next :: Lotus -> Stone -> [ Lotus ]
next l c = if canMoveAny l c
	then [ moveNC l m | m <- nextMoves l c ]
	else [ l ]

---
-- Lets a player do a move.
-- If he cannot move no move is done.
-- @param situation - Situation the player shall move in
-- @param player - Player that shall move
-- @param move - Move the player shall do
-- @return newsituation - Situation after the move
-- @see moveNC
-- @see nextMoves
move :: Lotus -> Stone -> Move -> Lotus
move l c ( i , d ) = if not $ canMove l c i then l else moveNC l ( i, d )

class Mover a where
	canMove :: Lotus -> Stone -> a -> Bool

---
-- Checks whether a player can move on a square.
-- @param situation - Situation the player shall move in
-- @param player - Player that shall move
-- @param square - Number of the square
-- @return result - Whether the player can move
-- @see canMoveAny
instance Mover Int where
	canMove l c i
		| i < 0 || i > 24 = False
		| otherwise       = canMove1 l c i

instance Mover a => Mover (a,b) where
	canMove l c m = canMove l c (fst m)

---
-- Checks whether a player can move any piece.
-- @param situation - Situation the player shall move in
-- @param player - Player that shall move
-- @return result - Whether the player can do any move
-- @see canMove
canMoveAny :: Lotus -> Stone -> Bool
canMoveAny l c = or [ canMove l c i | i <- [ 0 :: Int .. 24 ] ]

---
-- Checks whether the end of the game has bee reached.
-- @param situation - Situation to be checked
-- @return result - Whether the end of game has been reached
eog :: Lotus -> Bool
eog l = ( countS l S ) * ( countS l W ) == 0

---
-- Moves a player can do in a certain situation
-- @param situation - Situation the player shall move in
-- @param player - Player that shall move
-- @return move - List of the moves the player can do
-- @see next
-- @see move
nextMoves :: Lotus -> Stone -> [ Move ]
nextMoves l s = [ ( i , Left) | i <- hs, i <= 16 ] ++
	concat [ [(i, Left), (i, Right)] | i <- hs, i > 16 ] where hs = getHeaps l s

---
-- List of the squares the player can move on.
-- @param situation - Situation the player shall move in
-- @param player - Player that shall move
-- @return squares - Squares the player can move on
-- @see nextMoves
getHeaps :: Lotus -> Stone -> [ Int ]
getHeaps l c = [ i | i <- [ 0 .. 24 ] , canMove l c i ]

---
-- Checks whether a situation is valid.
-- In a valid situation the main part consisits of 11 squares, the left and the
-- right arm of 3 and the start squares of black and white of 4 stacks.
-- @param situation - Situation to be checked
-- @return result - Whether the situation is valid
isLotus :: Lotus -> Bool
isLotus ( m, l, r, b, w ) = length m == 11 && length l == 3 &&
	length r == 3 && length b == 4 && length w == 4

---
-- A version of canMove that does not check if the situation is valid.
-- @param situation - Situation the player shall move in
-- @param player - Player that shall move
-- @param square - Number of the square
-- @return result - Whether the player can move
-- @see canMove
canMove1 :: Lotus -> Stone -> Int -> Bool
canMove1 ( m, l, r, b, w ) c i
	| i < 11 = isHead c ( m !! ( 10 - i ) )
	| i < 14 = isHead c ( l !! ( 13 - i ) )
	| i < 17 = isHead c ( r !! ( 16 - i ) )
	| i < 21 = if c == S then b !! ( i - 17 ) > 0 else False
	| i < 25 = if c == W then w !! ( i - 21 ) > 0 else False
canMove1 _ _ _ = False

---
-- Jump with a square in a list of heaps.
-- @param heaplist - List of the heaps to jump in
-- @param piece - Piece that shall jump in the list
-- @param distance - Number of squares to jump
-- @return newheaplist - List of the heaps after the jump
jump :: [ Heap ] -> Stone -> Int -> [ Heap ]
jump [] _ _ = []
jump ( l : ls ) s 1 = ( s : l ) : ls
jump ( l : ls ) s n = l : jump ls s ( n - 1 )

---
-- A version of move that just does a move.
-- @param situation - Situation the move shall be done in
-- @param move - Move that shall be done
-- @return newsituation - Situation after the move
-- @see move
moveNC :: Lotus -> Move -> Lotus
moveNC ( m, l, r, b, w ) ( i, d )
	| i < 11 = let
				( pre, (p:t):post ) = splitAt ( 10 - i ) m
				result = pre ++ [t] ++ jump post p (length t + 1)
			in ( result, l, r, b, w )
	| i < 14 = let
				( pre, (p:t):post ) = splitAt ( 13 - i ) l
				h = length t + 1
			in if i - h < 11
					then ( jump m p ( 11 + h - i ), pre ++ [t] ++ post, r, b, w )
					else ( m, pre ++ [t] ++ jump post p h, r, b, w )
	| i < 17 = let
				( pre, (p:t):post ) = splitAt ( 16 - i ) r
				h = length t + 1
			in if i - h < 14
					then ( jump m p ( 14 + h - i ), l, pre ++ [t] ++ post, b, w )
					else ( m, l, pre ++ [t] ++ jump post p h, b, w )
	| i < 21 = let ( pre, x:post ) = splitAt ( i - 17 ) b
			in if x < 4
					then if d == Left
							then ( m, jump l S x, r, pre ++ [ x - 1 ] ++ post, w )
							else ( m, l, jump r S x, pre ++ [ x - 1 ] ++ post, w )
					else ( jump m S ( x - 3 ), l, r, pre ++ [ x - 1 ] ++ post, w )
	| i < 25 = let ( pre, x:post ) = splitAt ( i - 21 ) w
			in if x < 4
					then if d == Left
							then ( m, jump l W x, r, b, pre ++ [ x - 1 ] ++ post )
							else ( m, l, jump r W x, b, pre ++ [ x - 1 ] ++ post )
					else ( jump m W ( x - 3 ), l, r, b, pre ++ [ x - 1 ] ++ post )


---
-- Counts the number of pieces of a player in a situation
-- @param situation - Situation to count the pieces in
-- @param player - Player whose pieces shall be counted
-- @return number - Number of pieces the player has
countS :: Lotus -> Stone -> Int
countS (m,l,r,b,w) s = sum [ count s xs | xs <- ( m++l++r ) ] +
	sum ( if s == S then b else w )

---
-- Detects the color of the pieces of the opponent of a player.
-- The opponent of black is white an vice-versa.
-- @param player - Player to get the opponent of
-- @return opponent - Color of the pieces of the opponent
other :: Stone -> Stone
other S = W
other W = S

