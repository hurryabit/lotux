-- RandomKI.hs
-- 20.10.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett

module RandomKI ( randomKI ) where

import Prelude hiding ( Either(..) )
import Lotus
import Random

randomKI :: Lotus -> Stone -> IO Move
randomKI l c = do
	let ms = nextMoves l c
	m <- randomRIO (0,length ms - 1)
	return (ms !! m)
