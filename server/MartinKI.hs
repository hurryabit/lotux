-- Martin.hs
-- 10.01.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

---
-- This module provides the algorithm of Martins KI.
module MartinKI ( martinKI ) where

import Prelude hiding( Either( .. ) )
import Maybe( isJust, fromJust )
import Lotus ( Stone (..), Move, Lotus, Direction (..), Heap,
	other, move, nextMoves )
import Functions

---
-- Algorithm of Martins KI.
martinKI :: Lotus -> Stone -> Move
martinKI l c
		| canCatch l c = catchMove  l c
		| canEnter l c = enterMove  l c
		| canLeave l c = leaveMove  l c
		| otherwise    = normalMove l c


---
-- Checks whether a player caught a piece in a heap.
-- @param player - Player
-- @param heap - Heap
-- @return result - Result
-- @see bestCatch
-- @see betterCatch
-- @see canCatch
-- @see catchMove
caught :: Stone -> Heap -> Bool
caught c h = isLast ( other c ) h && contains h c

---
-- Evaluates the square nearest to the last square on which a player
-- has caught a piece.
-- @param situation - Situation
-- @param player - Player
-- @return number - Number of the square
-- @see caught
-- @see betterCatch
-- @see canCatch
-- @see catchMove
bestCatch :: Lotus -> Stone -> Maybe Int
bestCatch (m, _, _, _, _ ) c =
		let cs = [ n | ( h, n ) <- zip ( reverse m ) [ 0 .. ], caught c h ]
		in if null cs then Nothing else Just $ head cs

---
-- Checks whether a player can do a better catch (which is nearer to the last
-- square).
-- @param situation - Situation
-- @param player - Player
-- @return move - Slowest move that make a better catch (if any exists)
-- @see caught
-- @see bestCatch
-- @see canCatch
-- @see catchMove
betterCatch :: Lotus -> Stone -> Maybe Move
betterCatch l c =
	let
		ms = [ (a,b) | (Just a,b) <- [ (bestCatch (move l c m) c, m) |
			m <- nextMoves l c ] ]
		(mn, _) = if null ms then ( 25, (0, Left) ) else minimum ms
		new = if null ms then Nothing else Just $ slowestMove l ( search mn ms )
	in case bestCatch l c of
		Just b -> if mn < b then new else Nothing
		Nothing -> new

---
-- Normalizes a move (pieces on the right arm get a number as if they were on
-- the other arm and all others keep their number)
-- @param move - Move
-- @return number - Number
nmove :: Move -> Int
nmove ( i, _ )
	| ( 14 <= i ) && ( i <= 16 ) = i - 3
	| otherwise                  = i

---
-- Evaluates the slowest of the moves.
-- @param situation - Situation
-- @param moves - Moves
-- @return move - Slowest move
-- @see heightDiff
slowestMove :: Lotus -> [ Move ] -> Move
slowestMove l ms = mx where
		( _, _, _, mx ) = maximum
			[ (heightDiff l m, - heapHeight l i, nmove m, m ) | m@( i, _ ) <- ms ]

---
-- Checks whether a player has still a piece that can enter the game.
-- @param situation - Situation
-- @param player - Player
-- @return result - Result
-- @see enterMove
canEnter :: Lotus -> Stone -> Bool
canEnter ( _, _, _, b, _ ) S = sum b /= 0
canEnter ( _, _, _, _, w ) W = sum w /= 0

---
-- Evaluates the slowest move a player has to insert a piece.
-- @param situation - Situation
-- @param player - Player
-- @return move - Move
-- @see canEnter
-- @see slowestMove
enterMove :: Lotus -> Stone -> Move
enterMove l c = slowestMove l [ m | m@( i, _ ) <- nextMoves l c, i > 16 ]

---
-- Checks whether a player has a piece that can leave the board.
-- @param situation - Situation
-- @param player - Player
-- @return result - Result
-- @see leaveMove
canLeave :: Lotus -> Stone -> Bool
canLeave l c =
		let ms = [ targetNum l m | m <- nextMoves l c, notLoseCatch l c m ]
		in if null ms then False else minimum ms < 0

---
-- Evaluates the slowest move a player has to let a piece leave the board.
-- @param situation - Situation
-- @param player - Player
-- @return move - Move
-- @see canLeave
-- @see slowestMove
leaveMove :: Lotus -> Stone -> Move
leaveMove l c = slowestMove l [ m | m <- nextMoves l c,
	( targetNum l m < 0 ) && ( notLoseCatch l c m ) ]

---
-- Checks whether a player can do a better catch.
-- @param situation - Situation
-- @param player - Player
-- @return result - Result
-- @see caught
-- @see bestCatch
-- @see betterCatch
-- @see catchMove
canCatch :: Lotus -> Stone -> Bool
canCatch l c = isJust $ betterCatch l c

---
-- Evaluates the slowest move a player has to make a better catch.
-- @param sitaution - Situation
-- @param player - Player
-- @return move - Move
-- @see caught
-- @see bestCatch
-- @see betterCatch
-- @see canCatch
-- @see slowestMove
catchMove :: Lotus -> Stone -> Move
catchMove l c = fromJust $ betterCatch l c

---
-- Evaluates the slowest move a player can do that doesn't free the best catch.
-- @param situation - Situation
-- @param player - Player
-- @return move - Move
-- @see slowestMove
-- @see notLoseCatch
normalMove :: Lotus -> Stone -> Move
normalMove l c =
	let
		ms = nextMoves l c
		ms' = filter ( notLoseCatch l c ) ms
	in slowestMove l $ if null ms' then ms else ms'

---
-- Returns a heap.
-- @param siuation - Situation
-- @param number - Number of the heap
-- @return heap - Heap
-- @see heapHeight
heap :: Lotus -> Int -> Heap
heap ( m, l, r, b, w ) i
	| i < 0  = []
	| i < 11 = m !! ( 10 - i )
	| i < 14 = l !! ( 13 - i )
	| i < 17 = r !! ( 16 - i )
	| i < 21 = replicate ( b !! ( i - 17 ) ) S
	| i < 25 = replicate ( w !! ( i - 21 ) ) W
heap _  _ = []

---
-- Returns the height of a heap.
-- @param situation - Situation
-- @param number - Number of the heap
-- @return heap - Heap
-- @see heap
heapHeight :: Lotus -> Int -> Int
heapHeight l i = length $ heap l i

---
-- Evaluates the number of the target square of a move.
-- @param situation - Situation
-- @param move - Move
-- @return number - Number of the square
targetNum :: Lotus -> Move -> Int
targetNum l ( i, _ )
	| i < 14                = i - heapHeight l i
	| i < 17                = if n < 14 then n - 3 else n
			where n = i - heapHeight l i
targetNum l ( i, Left )  = 14 - heapHeight l i
targetNum l ( i, Right ) = if n > 3 then 14 - n else 17 - n
		where n = heapHeight l i

---
-- Evaulates the height a piece loses during a move (can be negative).
-- @param situation - Situation
-- @param move - Move
-- @return diff - Difference
-- @see slowestMove
-- @see heapHeight
heightDiff :: Lotus -> Move -> Int
heightDiff l m@( i, _ ) = heapHeight l i - heapHeight l ( targetNum l m ) - 1

---
-- Checks whether a move doesn't free the best catch.
-- @param situation - Sitaution
-- @param player - Player
-- @param move - Move
-- @return result - Result
-- @see normalMove
notLoseCatch :: Lotus -> Stone -> Move -> Bool
notLoseCatch l c (m, _) =
	case bestCatch l c of
		Just i  -> ( i /= m ) || ( count c ( heap l m ) > 1 )
		Nothing -> True

