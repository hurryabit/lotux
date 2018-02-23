-- Settings.hs
-- 23.10.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

module Settings
	(
		Mode(..), Settings, mode, twice, port, logdir, name, getSettings,
		exitError
	)
where

-- std
import Prelude
import Char ( isDigit )
import IO
import Directory
import List
import System
import qualified Exception

-- util
import GetOpt

-- mine
import LotusKI

data Mode =
	  Computer
	| Human
	deriving ( Show, Read )

data Settings = Settings
	{ mode   :: Mode
--	, twice  :: Bool
	, port   :: Int
	, logdir :: FilePath
	, name   :: String
	}
	deriving ( Show, Read )

twice _ = True

defaultSettings :: Settings
defaultSettings = Settings
	{ mode   = Human
--	, twice  = False
	, port   = 5180
	, logdir = "."
	, name   = "martin"
	}

data Flag =
	  Mode String
--	| Twice String
	| Port String
	| LogDir String
	| Name String
	| Help
	| List
	| Ignore
	| Save
	| Dummy
			deriving ( Eq, Ord, Show )



checkMode :: String -> IO Mode
checkMode "Computer" = return Computer
checkMode "Human" = return Human
checkMode _ = exitError "MODE must be `Human' or `Computer'."

checkTwice :: String -> IO Bool
checkTwice "True" = return True
checkTwice "False" = return False
checkTwice _ = exitError "ENABLE must be `True' or `False'."

checkPort :: String -> IO Int
checkPort p = (Exception.evaluate (read p)) `Exception.catch`
	(\_ -> exitError "PORT must be an integer between 1024 and 65535.")

checkLogDir :: String -> IO FilePath
checkLogDir ld = do
	exists <- doesDirectoryExist ld
	if exists then return () else do
			putStrLn "LOGDIR doesn't exist."
			create <- readLine "Shall it be created?" ["yes", "no"]
			case create of
				"yes" -> createDirectory ld
					`Exception.catch` (\_ -> exitError "LOGDIR can't be created.")
				_ -> exitError "LOGDIR doesn't exist."
			putStrLn "LOGDIR has been created."
	perm <- getPermissions ld
	if writable perm then return () else do
			putStrLn "LOGDIR is write protected."
			unlock <- readLine "Shall it be made writable?" ["yes","no"]
			case unlock of
				"yes" -> setPermissions ld (perm { writable = True })
					`Exception.catch` (\_ -> exitError "LOGDIR can't be made writable.")
				_ -> exitError "LOGDIR is write protected."
			putStrLn "LOGDIR is writable now."
	return ld

checkName :: String -> IO String
checkName n = 
	case searchKI n tableKI of
		Just _ -> return n
		Nothing ->
			exitError "NAME is invalid. Try option `--list' for further information."


checkOption :: Settings -> Flag -> IO Settings
checkOption sets (Mode s) = do
	m <- checkMode s
	return (sets {mode = m})
--checkOption sets (Twice s) = do
--	t <- checkTwice s
--	return (sets {twice = t})
checkOption sets (Port s) = do
	p <- checkPort s
	return (sets {port = p})
checkOption sets (LogDir s) = do
	ld <- checkLogDir s
	return (sets {logdir = ld})
checkOption sets (Name s) = do
	n <- checkName s
	return (sets {name = n})
checkOption sets _ = return sets

checkOptions :: Settings -> [Flag] -> IO Settings
checkOptions sets [] = return sets
checkOptions sets (f:fs) = do
	sets' <- checkOption sets f
	checkOptions sets' fs

options :: [OptDescr Flag]
options =
	[ Option ['m'] ["mode"] (ReqArg Mode "MODE")
		"Server mode (`Computer' or `Human')"
	--, Option ['2'] ["twice"] (ReqArg Twice "ENABLE")
	--	"First move is double move (`True' or `False')"
	, Option ['p'] ["port"] (ReqArg Port "PORT") "Port to listen on"
	, Option ['l'] ["logdir"] (ReqArg LogDir "LOGDIR") "Directory for logfile"
	, Option ['n'] ["name"] (ReqArg Name "NAME")
		"Name of the computer player"
	, Option ['h','?'] ["help"] (NoArg Help) "Display help screen"
	, Option [] ["list"] (NoArg List)
		"List available names for the computer players"
	, Option [] ["ignore"] (NoArg Ignore) "Ignore lotusserverrc"
	, Option [] ["save"] (NoArg Save) "Save settings to lotusserverrc"
	, Option [] ["dummy"] (NoArg Dummy) "Don't start server"
	]

exitError :: String -> IO a
exitError str = do
	prog <- getProgName
	hPutStrLn stderr ("ERROR: " ++ str ++
		"\nTry `" ++ prog ++ " --help' for further information.")
	exitFailure


readLine :: String -> [String] -> IO String
readLine _ [] = return ""
readLine prompt set = do
	putStr (prompt ++ " (" ++ foldl1 (\x -> (x++).(:)'/') set ++ "): ")
	hFlush stdout
	line <- getLine
	if line `elem` set then return line else readLine prompt set
			
	

getSettings :: IO Settings
getSettings = do
	args <- getArgs
	prog <- getProgName
	opts <- case getOpt Permute options args of
		(opts,[],[]) -> return opts
		(_,s,e) -> exitError ('\n':
			concatMap (\x -> "unrecognized option `" ++ x ++ "'\n") s ++ concat e)
	if Help `elem` opts then do
			putStrLn (usageInfo ("Usage: " ++ prog ++ " [OPTIONS...]") options)
			exitWith ExitSuccess
		else if List `elem` opts then do
				putStrLn ("Available names for the computer player:\n" ++
					concatMap (\(x,y,_,_) -> x++replicate (12-length x) ' ' ++ " - " ++ 
						y ++ "\n") tableKI)
				exitWith ExitSuccess
			else do
				sets1 <- if Ignore `elem` opts then return defaultSettings else
					readSettings
				sets2 <- checkOptions sets1
					((Port (show (port sets1))):(LogDir (logdir sets1)):
						(Name (name sets1)):opts)
				if Save `elem` opts then do
						rcfile <- fmap (++"/.lotusserverrc") (getEnv "HOME")
						(writeFile rcfile (show sets2)) `Exception.catch`
							(\_ -> exitError "Cannot write `~/.lotusserverrc'.")
					else return ()
				if Dummy `elem` opts then exitWith ExitSuccess else return sets2

readSettings :: IO Settings
readSettings = do
	rcfile <- (fmap (++"/.lotusserverrc") (getEnv "HOME") >>= readFile)
		`Exception.catch` (\_ -> exitError "Cannot read `~/.lotusserverrc'.")
	(Exception.evaluate (read rcfile)) `Exception.catch`
		(\_ -> exitError "The configuration file`~/.lotusserverrc' is invalid.")

