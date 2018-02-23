-- LotusServer.hs
-- 23.10.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

---
-- This module provides a server for Lotus matches against others and
-- against the computer.
-- @author Copyright (C) 2001-2002 by Carsten Moldenhauer and Martin Huschenbett
module Main ( main ) where

-- std
import IO ( Handle )
import Char ( isDigit )
import System ( getArgs, getProgName, exitFailure, exitWith,
	ExitCode ( ExitSuccess ) )
import Locale ( defaultTimeLocale )
import Time ( getClockTime, toCalendarTime, CalendarTime, ctPicosec,
	formatCalendarTime, ctSec )
import Directory ( doesDirectoryExist, writable, getPermissions,
	createDirectory	)
import Maybe ( fromJust )

-- concurrent
import Concurrent ( forkIO )

-- net
import qualified Socket ( Socket, listenOn, accept,	PortID ( PortNumber ) )

-- posix
import qualified Posix ( installHandler, sigPIPE, Handler(Ignore) )

-- mine
import Lotus ( Stone(..), Move, Lotus, canMove, canMoveAny, move, eog,
	other, newGame )
import Protocol ( Message(..) )
import qualified Talk ( talk, close )
import Settings ( Settings, mode, port, logdir, name, Mode(..), getSettings,
	exitError, twice )
import LotusKI


---
-- Main function. Takes the settings and starts the server.
main :: IO ()
main = do
	sets <- getSettings
	
	Posix.installHandler Posix.sigPIPE Posix.Ignore Nothing
	socket <- Socket.listenOn (Socket.PortNumber (fromIntegral (port sets)))
		`catch` \_ -> exitError ("Couldn't bind on port "++show (port sets)++".")
	case mode sets of
		Human -> sequence_ $ repeat $ reception socket sets
		Computer -> sequence_ $ repeat $ reception1 socket sets
	`catch` \e -> exitError ("Unknown error:\n" ++ show e)

reception1 :: Socket.Socket -> Settings -> IO ()
reception1 s sets = do
	(h,_,_) <- Socket.accept s
	forkIO (startGame1 h sets)
	return ()

startGame1 :: Handle -> Settings -> IO ()
startGame1 h sets = do
	time <- getClockTime >>= toCalendarTime
	player <- welcome h
	case player of
		"" -> return ()
		_ -> do
			let (n,k) = fromJust (searchKI (name sets) tableKI)
			m1 <- Talk.talk h ("Dein_Gegner_ist \"" ++ n ++ "\"")
			case m1 of
				ClOk -> do
					let start = odd (ctSec time) -- || (twice sets)
					m2 <- Talk.talk h
						(if start then "Du_beginnst" else "Der_andere_beginnt")
					case m2 of
						ClOk -> do
							ms <- playGame1 (if start then W else S,k) h S newGame []
							if start then logGame sets ms player n time
								else logGame sets ms n player time
							Talk.talk h "Ende" >> Talk.close h
						_ -> return ()
				_ -> return ()
						

playGame1 :: (Stone,LotusKI) -> Handle -> Stone -> Lotus -> [(Stone,Move)] ->
	IO [(Stone,Move)]
playGame1 _ _ _ l ms | eog l = return ms
playGame1 k h c l ms | not (canMoveAny l c) = playGame1 k h (other c) l ms
playGame1 ki@(s,k) h c l ms
	| s == c = do
			m <- k l s
			case canMove l c m of
				True -> do
					msg <- Talk.talk h ("Der_andere_zieht " ++ show m)
					let ms' = (c,m):ms in case msg of
						ClOk -> playGame1 ki h (other c) (move l c m) ms'
						_ -> return ms'
				False -> return ms
	| otherwise = do
			msg <- Talk.talk h "Wo_ziehst_du"
			case msg of
				ClMove m -> case canMove l c m of
					True -> playGame1 ki h (other c) (move l c m) ((c,m):ms)
					False -> return ms
				_ -> return ms

---
-- Reception for clients.
reception :: Socket.Socket -> Settings -> IO ()
reception s sets = do
	(h,_,_) <- Socket.accept s
	name <- welcome h
	case name of
		"" -> return ()
		_ -> waitForSecond s (h,name) sets

---
-- Welcomes a client.
welcome :: Handle -> IO String
welcome h = do
	msg1 <- Talk.talk h "Wer_bist_du"
	case msg1 of
		ClName name -> do
			msg2 <- Talk.talk h "Das_Spielfeld_ist www.lotux.de.vu"
			case msg2 of
				ClOk -> return $ if null name then "Unknown" else name
				_ -> return ""
		_ -> return ""

---
-- Waits for a second client who shall play against a connected one.
waitForSecond :: Socket.Socket -> (Handle,String) -> Settings -> IO ()
waitForSecond s (h,n) sets = do
	(g,_,_) <- Socket.accept s
	name <- welcome g
	case name of
		"" -> Talk.close g >> waitForSecond s (h,n) sets
		_ -> do
			msgh <- Talk.talk h ("Dein_Gegner_ist \"" ++ name ++ "\"")
			case msgh of
				ClOk -> do
					msgg <- Talk.talk g ("Dein_Gegner_ist \"" ++ n ++ "\"")
					case msgg of
						ClOk -> forkIO (startGame (h,n) (g,name) sets) >> return ()
						_ -> Talk.close h >> Talk.close g
				_ -> Talk.close h >> waitForSecond s (g,name) sets

---
-- Formats a time. The output format is "YYYYMMDDhhmmsszzzuuu"
formatTime :: CalendarTime -> String
formatTime ct = formatCalendarTime defaultTimeLocale "%Y%m%d%H%M%S" ct ++ micsec
	where
		micsec  = replicate (6-length micsec') ' ' ++ micsec'
		micsec' = show (ctPicosec ct `quot` 1000000)

---
-- Starts a match between two players. After the match, everything is written
-- to logfile and the connections to the clients are closed.
startGame :: (Handle,String) -> (Handle,String) -> Settings -> IO ()
startGame (h,n) (g,m) sets = do
	time <- getClockTime >>= toCalendarTime
	init <- initGame h g
	case init of
		True -> do
			ms <- playGame h g S newGame []
			logGame sets ms n m time
			Talk.talk h "Ende" >> Talk.close h
			Talk.talk g "Ende" >> Talk.close g
		False -> Talk.close h >> Talk.close g

---
-- Initializes a match. Tells each player whether he begins or not.
initGame :: Handle -> Handle -> IO Bool
initGame h g = do
	msgh <- Talk.talk h "Du_beginnst"
	case msgh of
		ClOk -> do
			msgg <- Talk.talk g "Der_andere_beginnt"
			case msgg of
				ClOk -> return True
				_ -> return False
		_ -> return False

---
-- Does the main part of a match between two players: the 'real match'
playGame :: Handle -> Handle -> Stone -> Lotus -> [(Stone,Move)] ->
		IO [(Stone,Move)]
playGame _ _ _ l ms | eog l = return ms
playGame h g c l ms | not (canMoveAny l c) = playGame h g (other c) l ms
playGame h g S l ms = do
	msgh <- Talk.talk h "Wo_ziehst_du"
	case msgh of
		ClMove m -> do
			case canMove l S m of
				True -> do
					msgg <- Talk.talk g ("Der_andere_zieht " ++ show m)
					let ms' = (S,m):ms in case msgg of
						ClOk -> playGame h g W (move l S m) ms'
						_ -> return ms'
				False -> return ms
		_ -> return ms
playGame h g W l ms = do
	msgg <- Talk.talk g "Wo_ziehst_du"
	case msgg of
		ClMove m -> do
			case canMove l W m of
				True -> do
					msgh <- Talk.talk h ("Der_andere_zieht " ++ show m)
					let ms' = (W,m):ms in case msgh of
						ClOk -> playGame h g S (move l W m) ms'
						_ -> return ms'
				False -> return ms
		_ -> return ms

logGame ::
	Settings -> [(Stone,Move)] -> String -> String -> CalendarTime -> IO ()
logGame _ [] _ _ _ = return ()
logGame sets ms@((w,_):_) n m t = do
	let time = formatTime t
	appendFile (logdir sets ++ "/gametable.log")
		(time ++ "|" ++ n ++ "|" ++ m ++ "|" ++ show w ++ "\n")
		`catch` \_ -> putStrLn "Couldn't append game to gametable."
	writeFile (logdir sets ++ "/" ++ time ++ ".log")
		(unlines $ ('S':n):('W':m):reverse
			(map (\(x,y) -> show x++show y) ms) ++
			if w == S then ["SWinner","WLoser"] else ["SLoser","WWinner"] )
		`catch` \_ -> putStrLn "Couldn't write logfile."
