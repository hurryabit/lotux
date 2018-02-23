-- MoldieKI.hs
-- 10.01.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

module MoldieKI where

import Prelude hiding( Either( .. ) )
import Lotus


moldieKI :: Lotus -> Stone -> Move
moldieKI l s =
	if otherCannotMove ( moveNC l ( blockOtherStones l s ) ) s
		then blockOtherStones l s
		else
			if liegtZurueck l s
				then if nextOpponentsMove l s  == leftmost l s
							then if moveOnOwnHeap l ( blockOtherStones l s )
										then leftmost l s
										else blockOtherStones l s
							else leftmost l s
				else blockOtherStones l s

liegtZurueck :: Lotus -> Stone -> Bool
liegtZurueck l s =
					let
						i = getHeaps l ( other s )
						j = getHeaps l s
					in
					 ( addition i ) * ( length j ) < ( addition j ) * ( length i )

addition :: [ Int ] -> Int
addition [] = 0
addition ( a : as ) = a + ( addition as )

{-- returns wheter the last stone on a heap is of your
or the opponent's color --}
goodHeap :: Heap -> Stone -> Bool
goodHeap [] _ = True
goodHeap [ _ ] _ = False
goodHeap ( h : hs ) s = if h == other s
					then goodHeap hs s
					else
					  if head hs == other s
					   then not ( goodHeap hs ( other s ) )
					   else goodHeap hs s

{-- returns whether you want to move on a heap which
is single colored with the color of your stone or not--}
moveOnOwnHeap :: Lotus -> Move -> Bool
moveOnOwnHeap ( m, _, _, _, _ ) ( i, _ ) | i < 11 =
	let
		( _, x : post ) = splitAt ( 10 - i ) m
		p = head x
		h = length x
	in moveOnOwnHeap1 post p h
moveOnOwnHeap ( m, l, _, _, _ ) ( i, _ ) | i < 14 =
	let
		( _, x : post ) = splitAt ( 13 - i ) l
		p = head x
		h = length x
	in if i - h < 11
		then moveOnOwnHeap1 m p ( 11 + h - i )
		else moveOnOwnHeap1 post p h
moveOnOwnHeap ( m, _, r, _, _ ) ( i, _ ) | i < 17 =
    let
		( _, x : post ) = splitAt ( 16 - i ) r
		p = head x
		h = length x
	in if i - h < 14
		then moveOnOwnHeap1 m p ( 14 + h - i )
		else moveOnOwnHeap1 post p h
moveOnOwnHeap ( m, l, r, b, _ ) ( i, d ) | i < 21 =
	let ( _, x : _ ) = splitAt ( i - 17 ) b
	in if x < 4
		then
			if d == Left
				then moveOnOwnHeap1 l S x
				else moveOnOwnHeap1 r S x
			else
				moveOnOwnHeap1 m S ( x - 3 )
moveOnOwnHeap ( m, l, r, _, w ) ( i, d ) | i < 25 =
	let ( _, x : _ ) = splitAt ( i - 21 ) w
	in if x < 4
		then
			if d == Left
				then moveOnOwnHeap1 l W x
				else moveOnOwnHeap1 r W x
			else
				moveOnOwnHeap1 m W ( x - 3 )
moveOnOwnHeap _ _ = error "moveOnOwnHeap"

moveOnOwnHeap1 :: [ Heap ] -> Stone -> Int -> Bool
moveOnOwnHeap1 [] _ _ = False
moveOnOwnHeap1 ( l : _  ) s 1 = singleColored l s
moveOnOwnHeap1 ( _ : ls ) s n = moveOnOwnHeap1 ls s ( n - 1 )

singleColored :: Heap -> Stone -> Bool
singleColored [] _ = False
singleColored [ a ] s = if a == s then True else False
singleColored ( l : ls ) s = if l == s then singleColored ls s else False

leftmost :: Lotus -> Stone -> Move
leftmost lotus s =
	if leftmost1 lotus s
		then blockOtherStones lotus s
		else
			let list = [ i | i <- reverse [ 0 .. 16 ], goodHeap ( getHeap lotus i ) s == False, canMove lotus s i ]
			in
			 if list == []
			  then
				head ( nextMoves lotus s )
			  else
			  	if leftmost3 lotus s
					then ( leftmost4 lotus s )
					else ( head list, Left )

getHeap :: Lotus -> Int -> Heap
getHeap _ i | i < 0 = []
getHeap ( m, _, _, _, _ ) i | i < 11 = getHeap1 m ( 11 - i )
getHeap ( _, l, _, _, _ ) i | i < 14 = getHeap1 l ( 3 - ( i - 11 ) )
getHeap ( _, _, r, _, _ ) i | i < 17 = getHeap1 r ( 3 - ( i - 14 ) )
getHeap ( _, _, _, b, _ ) i | i < 21 = getHeap2 b ( 4 - ( i - 17 ) )
getHeap ( _, _, _, _, w ) i | i < 25 = getHeap3 w ( 4 - ( i - 21 ) )
getHeap _ _ = []

getHeap1 :: [ Heap ] -> Int -> Heap
getHeap1 ( a : _  ) 1 = a
getHeap1 ( _ : as ) i = getHeap1 as ( i - 1 )
getHeap1 _ _          = error "getHeap1"

getHeap2 :: [ Int ] -> Int -> Heap
getHeap2 ( a : _  ) 1 = take a ( repeat S )
getHeap2 ( _ : as ) i = getHeap2 as ( i - 1 )
getHeap2 _ _          = error "getHeap2"

getHeap3 :: [ Int ] -> Int -> Heap
getHeap3 ( a : _  ) 1 = take a ( repeat W )
getHeap3 ( _ : as ) i = getHeap3 as ( i - 1 )
getHeap3 _ _          = error "getHeap3"

{-- ueberprueft ob noch steine in den bereichen
17 bis 20 fuer S oder 21 bis 24 fuer W liegen --}
leftmost1 :: Lotus -> Stone -> Bool
leftmost1 ( _, _, _, b, w ) s = if s == S
		then
			or [ b !! ( i - 17 ) > 0 | i <- [ 17 .. 20 ] ]
		else
			or [ w !! ( i - 21 ) > 0 | i <- [ 21 .. 24 ] ]

{-- zieht einen Zug, der so viele Steine des Gegners wie moeglich
blockiert --}
blockOtherStones :: Lotus -> Stone -> Move
blockOtherStones l s =
	let
		( _, result ) = biggest [ ( valueBlockedOtherStones i s, j ) | ( i, j ) <- zip ( next l s ) ( nextMoves l s ) ]
	in result

valueBlockedOtherStones :: Lotus -> Stone -> Int
valueBlockedOtherStones ( m, l, r, _, _ ) s =
	length [ () | i <- m++l++r, j <- i, j == other s, isHead s i ]

biggest :: [ ( Int, Move ) ] -> ( Int, Move )
biggest [ ( x, y ) ] = ( x, y )
biggest ( ( x, y ) : rest ) =
	let ( q, p ) = biggest rest
	in if x >= q then ( x, y ) else ( q, p )
biggest _ = error "biggest"

otherCannotMove :: Lotus -> Stone -> Bool
otherCannotMove l s = not ( canMoveAny l ( other s ) )

{-- gibt an, ob es goodHeaps beim naechsten Zug gibt --}
leftmost3 :: Lotus -> Stone -> Bool
leftmost3 l s =
	or [ i | ( i, j ) <- ( getListLeftmost3 l s ) ]

getListLeftmost3 :: Lotus -> Stone -> [ ( Bool, Int ) ]
getListLeftmost3 l s =
	zip ( [ goodHeap ( getHeap ( moveNC l ( i, Left ) ) ( i - length ( getHeap l i ) ) ) s | i <- getHeaps l s ] ++ [ goodHeap ( getHeap ( moveNC l ( i, Right ) ) ( i - length ( getHeap l i ) ) ) s | i <- getHeaps l s, i > 16 ] ) ( getHeaps l s )

leftmost4 :: Lotus -> Stone -> Move
leftmost4 l s =
	( head [ i | ( j, i ) <- ( getListLeftmost3 l s ), j == True ], Left )

{-- gibt an, bei welchem von meinen Zuegen, der Gegner im Anschluss
meine meisten Steine blockieren kann --}
nextOpponentsMove :: Lotus -> Stone -> Move
nextOpponentsMove l s =
	let ( _, b ) = biggest [ ( valueBlockedOtherStones j ( other s ), i ) | i <- nextMoves l s, j <- next ( moveNC l i ) ( other s ) ]
	in b

