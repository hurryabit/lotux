-- Client.hs
-- 01.05.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

---
-- This module provides a generic main function for artificial intelligences
-- for Lotus. You just need to specify an AI. It also exports all available
-- functions for writing an AI.
module Main ( main )  where

import Prelude hiding ( Either(..) )
import System
import qualified Socket
import IO
import Char

import qualified Talk
import Protocol

import LotusKI
import Lotus

main :: IO ()
main = do
	args <- getArgs
	prog <- getProgName
	case args of
		(ki:p:_) -> case searchKI ki tableKI of
			Nothing    -> usage
			Just (k,f) -> main2 f k p
		_ -> usage
main2 :: LotusKI -> String -> String -> IO ()
main2 kifunc name prt
	| all isDigit prt = Socket.withSocketsDo $ do
	h <- Socket.connectTo  "localhost"
		(Socket.PortNumber (fromIntegral (read prt)))
	runinit h kifunc name
	Talk.close h

	`catch` \_ -> putStrLn ("Cannot connect to port " ++ prt ++ ".") >> exitFailure
	| otherwise = usage

usage :: IO ()
usage = do
	prog <- getProgName
	putStrLn ( unlines ( ("usage: " ++ prog ++ " <name> <port>"):
		"Available AIs:":"name        - description":
		map (\(x,y,_,_) -> x++(replicate (12-length x) ' ')++"- "++y) tableKI) )
	exitFailure

runinit :: Handle -> LotusKI -> String -> IO ()
runinit h kifunc name = do
	q1 <- Talk.read h
	case q1 of
		SrvName -> do
			Talk.write h ( "Ich_bin \"" ++ name ++ "\"")
			q2 <- Talk.read h
			case q2 of
				SrvBoard -> do
					Talk.write h "OK"
					q3 <- Talk.read h
					case q3 of
						SrvOpponent _ -> do
							Talk.write h "OK"
							q4 <- Talk.read h
							case q4 of
								SrvColor c -> do
									Talk.write h "OK"
									rungame h newGame c kifunc
								_ -> fakingServer q4
						_ -> fakingServer q3
				_ -> fakingServer q2
		_ -> fakingServer q1

rungame :: Handle -> Lotus -> Stone -> LotusKI -> IO ()
rungame h l s kifunc = do
	q <- Talk.read h
	case q of
		SrvMove -> if canMoveAny l s
								then do
									mo <- kifunc l s
									Talk.write h ( "Ich_ziehe " ++ show mo )
									rungame h (moveNC l mo ) s kifunc
								else fakingServer q
		SrvOther m@(a,_) -> do
					Talk.write h "OK"
					if canMove l ( other s ) a
							then rungame h ( moveNC l m ) s kifunc
							else fakingServer q
		SrvEnd -> Talk.write h "OK"
		_ -> fakingServer q

fakingServer :: a -> IO ()
fakingServer _ = return ()

