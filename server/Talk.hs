-- Talk.hs
-- 01.05.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

---
-- This modules funtions for talking in sockets.
-- @author Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett
module Talk (
	read, write, talk, close
) where

import Prelude hiding ( read )
import IO

import Protocol


read :: Handle -> IO Message
read h = do
	msg <- fmap message (hGetLine h)
	hFlush h
	return msg
	`catch` \_ -> return MsgError

write :: Handle -> String -> IO ()
write h s = do
	hPutStrLn h s
	hFlush h
	`catch` \_ -> return ()

talk :: Handle -> String -> IO Message
talk h s = write h s >> read h

close :: Handle -> IO ()
close h = hClose h `catch` \_ -> return ()
