-- LotusKI.hs
-- 23.10.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

---
-- This module provides access to all implemented computer players.
-- They are also call artificial intelligences (German: KI).
-- @author Copyright (C) 2001-2002 by Carsten Moldenhauer and Martin Huschenbett
module LotusKI ( searchKI, tableKI, LotusKI ) where

import Lotus ( Lotus, Stone, Move )
import Random( randomRIO )

import MoldieKI ( moldieKI )
import MartinKI ( martinKI )
import PerfectKI ( perfectKI )
import RandomKI ( randomKI )

---
-- Searches a certain KI in a table of KIs.
-- @param name - Name of the KI to search
-- @param table - Table to search in
-- @return result - Real name and algorithm of the KI (if it exists)
searchKI :: String -> [(String,String,String,LotusKI)] -> Maybe (String,LotusKI)
searchKI _ [] = Nothing
searchKI s ((k,_,n,f):ks)
	| s == k    = Just (n,f)
	| otherwise = searchKI s ks

---
-- Typesynonym for the type of an algorithm of a KI.
type LotusKI = Lotus -> Stone -> IO Move

---
-- Makes a function with two parameters IO.
-- @param f - Function
-- @return iof - IO monad with the function
io2 :: (a -> b -> c) -> (a -> b -> IO c)
io2 f x y = return (f x y)

---
-- Table of the available KIs.
tableKI :: [(String, String, String, LotusKI)]
tableKI =
	[ ("moldie"  , "A fast AI from Carsten", "MoldieKI", io2 moldieKI)
	, ("martin"  , "A lame AI from Martin" , "MartinKI", io2 martinKI)
	, ("perfect" , "An AI that can beat anyone who begins", "PerfectKI",
		io2 perfectKI)
	, ("random"  , "An AI that moves randomly", "RandomKI", randomKI )
	]

