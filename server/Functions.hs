-- Functions.hs
-- 09.02.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

---
-- This module provides some necessary functions used in the other modules.
-- @author Copyright (C) 2001-2002 by Carsten Moldenhauer and Martin Huschenbett
module Functions
(
	contains, count, search, isHead, isLast
)
where

---
-- Checks whether a list contains a certain value.
-- @param list - List
-- @param value - Value the list shall be checked for
-- @return result - Whether the list contains the value
-- @see count
contains :: Eq a => [a] -> a -> Bool
contains [] _ = False
contains (x:xs) y
	| x == y    = True
	| otherwise = contains xs y

---
-- Checks whether a value is the first element of a list.
-- @param value - Value that shall be checked if it is the first one
-- @param list - List
-- @return result - Whether the value is the first element of the list
-- @see isLast
isHead :: Eq a => a -> [a] -> Bool
isHead _ []     = False
isHead x (y:_) = x == y

---
-- Checks whether a value is the last element of a list.
-- @param value - Value that shall be checked if it is the last one
-- @param list - List
-- @return result - Whether the value is the last element of the list
-- @see isHead
isLast :: Eq a => a -> [a] -> Bool
isLast _ []     = False
isLast x [y]    = x == y
isLast x (_:ys) = isLast x ys

---
-- Counts the number of occurences of a value in a list.
-- @param value - Value that shall be counted
-- @param list - List
-- @return number - Number of occurences in the list
-- @see contains
count :: Eq a => a -> [a] -> Int
count _ [] = 0
count x (y:ys) = ( if x == y then 1 else 0 ) + count x ys

---
-- Searches in a pair list for all pairs whose first element has a special
-- value.
-- @param value - Value to search
-- @param pairlist - List of pairs
-- @return list - List of the second values of the concerning pairs
search :: Eq a => a -> [ (a, b) ] -> [b]
search _ [] = []
search x ( (a, b):ys )
	| x == a    = b:(search x ys)
	| otherwise = search x ys


