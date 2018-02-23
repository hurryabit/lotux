-- Protocol.hs
-- 10.02.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

---
-- This module provides a type and function for messages of the protocol.
-- @author Copyright (C) 2001-2002 by Carsten Moldenhauer and Martin Huschenbett
module Protocol
(
	Message( .. ), message
) where

import Prelude hiding( Either( .. ) )
import Functions ( isLast )
import Lotus ( Move, Stone(..), Direction(..) )

import Char ( isDigit )
import Maybe ( isJust, fromJust )

---
-- Type for the different messages. The different constructors are assigned to
-- different strings of the protocol. <em>name</em> has to be a valid name and
-- <em>move</em> a valid string for a move. Each message may also contain a
-- comment that starts with a '#'. All comments are stripped before parsing.
-- Message starting with 'Srv' are sent by the server and those beginning with
-- 'Cl' by the client.
-- @cons SrvName - 'Wer_bist_du'
-- @cons SrvBoard - 'Das_Spielfeld_ist <em>name</em>'
-- @cons SrvOpponent - 'Dein_Gegner_ist "<em>name</em>"'
-- @cons SrvColor - SrvColor S for 'Du_beginnst' and SrvColor W for
-- 'Der_andere_beginnt'
-- @cons SrvMove - 'Wo_ziehst_du'
-- @cons SrvOther - 'Der_andere_zieht <em>move</em>'
-- @cons SrvEnd - 'Ende'
-- @cons ClName - 'Ich_bin "<em>name</em>"'
-- @cons ClOk - 'OK'
-- @cons ClMove - 'Ich_ziehe <em>move</em>'
-- @cons MsgError - All others ...
data Message =
	SrvName |
	SrvBoard |
	SrvOpponent String |
	SrvColor Stone |
	SrvMove |
	SrvOther Move |
	SrvEnd |
	ClName String |
	ClOk |
	ClMove Move |
	MsgError
	deriving ( Show, Read, Eq )


---
-- Generates a message according to a string.
-- @param string - String to get the message from
-- @return message - Message of the string or MsgError if the string is invalid.
-- @see move
message :: String -> Message
message str = let s = stripComment str in case take 3 s of
	"OK"  -> ClOk
	"Wo_" -> if s == "Wo_ziehst_du" then SrvMove else MsgError
	"Der" -> if s == "Der_andere_beginnt" then SrvColor W else
		let
			(pre,post) = splitAt 17 s
			m = move post
		in if pre == "Der_andere_zieht " && isJust m then SrvOther (fromJust m) else MsgError
	"Ich" -> let (pre,post) = splitAt 9 s in case pre of
		"Ich_bin \"" -> case reverse post of
			'\"':_ -> ClName (init post)
			_ -> MsgError
		"Ich_ziehe" -> case post of
			' ':rest -> case move rest of
				Just m -> ClMove m
				Nothing -> MsgError
			_ -> MsgError
		_ -> MsgError
	"End" -> if s == "Ende" then SrvEnd else MsgError
	"Wer" -> if s == "Wer_bist_du" then SrvName else MsgError
	"Du_" -> if s == "Du_beginnst" then SrvColor S else MsgError
	"Das" -> if take 18 s == "Das_Spielfeld_ist " then SrvBoard else MsgError
	"Dei" -> let (pre,post) = splitAt 17 s in if pre == "Dein_Gegner_ist \"" then
			case reverse post of
				'\"':_ -> SrvOpponent (init post)
				_ -> MsgError
		else MsgError
	_ -> MsgError


---
-- Converts a string to a move, if the string represents a valid move.
-- @param string - String to convert
-- @return move - Read move or <em>Nothing</em> if the string was no valid
-- move.
move :: String -> Maybe Move
move ('(':s)
	| l == 0 && l > 2 = Nothing
	| n < 0 || 24 < n = Nothing
	| post == ",L)"   = Just (n,Left)
	| post == ",R)"   = Just (n,Right)
	where
		(pre,post)    = span isDigit s
		l             = length pre
		n             = read pre
move _            = Nothing

---
-- Strips the comment from a string.
-- @param string - String to strip the comment from
-- @return newstring - String without the comment
stripComment :: String -> String
stripComment []          = []
stripComment (' ':'#':_) = []
stripComment ('#':_)     = []
stripComment (x:xs)      = x:stripComment xs

