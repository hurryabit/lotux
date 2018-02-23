-- PerfectKI.hs
-- 18.10.2002
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.
--
-- Copyright (C) 2001-2002 by Carsten Moldenauer and Martin Huschenbett
module PerfectKI ( perfectKI ) where

import Prelude hiding ( Either(..) )
import Lotus
import MartinKI

perfectKI :: Lotus -> Stone -> Move
perfectKI ls W
	| length ms == 1 = head ms
	| starting ls    = insert ls
	| not (null ns)  = (head ns,Left)
		where
			ms = nextMoves ls W
			(m,l,r) = group ls
			ns = s m l r
perfectKI ls S      = martinKI ls S


type RLotus = ([Square],[Square],[Square])
type Pattern = [Square] -> [Square] -> [Square] -> [Int]

data Square =
	  E Int          -- Empty n: n leere felder
	| WS Int Int    -- WSTower h z: ws-turm mit h ws-einheiten und zielfeld z
	| T Heap Int     -- Tower h z: turm mit steinfolge h und zielfeld z
	| TW Int
	| TS Int
		deriving ( Show, Read, Eq )

#define NEL(x) x@(_:_)

#define DE (E _)
#define DE1 (E 1)
#define DE2 (E 2)
#define DE3 (E 3)
#define DE4 (E 4)
#define DE5 (E 5)
#define DEE (E e)
#define DWS (WS _ _)
#define DWS1 (WS 1 _)
#define DWS2 (WS 2 _)
#define DWS3 (WS 3 _)
#define DWS4 (WS 4 _)
#define DWS1N (WS 1 n)
#define DWS2N (WS 2 n)
#define DS (TS _)
#define DW (TW _)
#define DWN (TW n)
#define DSWS (T [S,W,S] _)
#define DSWSN (T [S,W,S] n)
#define DWWS (T [W,W,S] _)
#define DWWSN (T [W,W,S] n)
#define DSW (T [S,W] _)
#define DD1 (T [W,W,S] _)
#define DD2 (T [W,W,S,W,S] _)


starting :: Lotus -> Bool
starting (_,_,_,_,w) = any (/=0) w

insert :: Lotus -> Move
insert (_,l,r,b,w)
	| n < 3     = (m,Right)
	| otherwise = (m,Left)
			where
				n = length (fst (span isWsHeap (r++l)))
				m = 21 + length (fst (span (==0) (zipWith (-) w b)))

group1 :: [Heap] -> Int -> [Square]
group1 []      _ = []
group1 ([]:xs) n = (E (m+1)):group1 post (n-1-m)
			where
				(pre,post) = span null xs
				m          = length pre
group1 ([W]:xs) n = (TW (n-1)):group1 xs (n-1)
group1 ([S]:xs) n = (TS (n-1)):group1 xs (n-1)
group1 (x:xs) n
	| isWsHeap x = (WS (l `div` 2) (n-l)):group1 xs (n-1)
	| otherwise  = (T x (n-l)):group1 xs (n-1)
			where l = length x

group :: Lotus -> RLotus
group (m,l,r,_,_) =
		(reverse (group1 m 10),reverse (group1 l 13),reverse (group1 r 13))

isWsHeap :: Heap -> Bool
isWsHeap []       = True
isWsHeap (W:S:xs) = isWsHeap xs
isWsHeap _        = False

ws :: Int -> [Square] -> Bool
ws _ []         = True
ws n ((E _):xs) = ws n xs
ws n ((WS _ m):xs)
	| n <= m      = ws n xs
ws _ _          = False

isWS :: Int -> Square -> Bool
isWS m (WS n _) = n == m
isWS _ _        = False

isT :: Heap -> Square -> Bool
isT h (T t _) = t == h
isT _ _       = False


s :: Pattern

s xs ys zs
	| 11 == sum [ case u of
									DE   -> 0
									DW   -> 1
									DWS1 -> 10
									_    -> 12
								| u <- xs++ys++zs ] = [ case [ n | TW n <- xs++ys ] of
										(m:_) -> m+1
										[]    -> case head [ n | TW n <- zs ] of
												10 -> 14
												k  -> k+1 ]
	

s (DE1:DW:xs) ys zs | ws 2 (xs++ys++zs) = [ case [ (h,n) | WS h n <- xs++ys ] of
		((h,n):_) -> n+2*h
		[]        -> case head [ (h,n) | WS h n <- zs ] of
				(1,14) -> 16
				(h,n)  -> n+2*h+3 ]
--main
#define RESULT | ws 2 (xs++ys++zs) = [1]
s (DE1:DW:   DW:DS:xs) ys zs RESULT
s (DE1:DW:DE:DW:DS:xs) ys zs RESULT
#undef RESULT
--main
#define RESULT | ws 2 (ys++zs) = [1]
s [DE1,DW,DE,DW] (DS:ys)        zs             RESULT
s [DE1,DW,DE,DW] ys             (DS:zs)        RESULT
s [DE1,DW,DE]    (DW:DS:ys)     zs             RESULT
s [DE1,DW,DE]    ys             (DW:DS:zs)     RESULT
s [DE1,DW,DE]    (DE1:DW:DS:ys) zs             RESULT
s [DE1,DW,DE]    ys             (DE1:DW:DS:zs) RESULT
#undef RESULT
--main
#define RESULT | ws 2 (xs++ys++zs) = [0]
s (DW:   DSW:xs) ys zs RESULT
s (DW:DE:DSW:xs) ys zs RESULT
#undef RESULT
--main
#define RESULT | ws 2 (ys++zs) = [0]
s [DW,DE] (DSW:ys)    zs          RESULT
s [DW,DE] ys          (DSW:zs)    RESULT
s [DW,DE] (DE:DSW:ys) zs          RESULT
s [DW,DE] ys          (DE:DSW:zs) RESULT
#undef RESULT
--main
#define RESULT | ws 2 (xs++ys++zs) = [n+1]
s (DE:DS:DW :DE:DS:DWN:xs) ys zs RESULT
s (   DS:DW :DE:DS:DWN:xs) ys zs RESULT
s (DE:DS:DW :   DS:DWN:xs) ys zs RESULT
s (   DS:DW :   DS:DWN:xs) ys zs RESULT
s (      DWN:DE:DS:DW :xs) ys zs RESULT
s (      DWN:   DS:DW :xs) ys zs RESULT
#undef RESULT
--main
#define RESULT | ws 2 (xs++ys++zs) = [n+1]
s (DE:DS:DE:DWN:xs) ys zs RESULT
s(    DS:DE:DWN:xs) ys zs RESULT
#undef RESULT

s (DEE:DWN:xs) ys zs | ws 2 (xs++ys++zs) && e > 1 = [n+1]
--main
#define RESULT(r) | ws 2 (ys++zs) = [r]
s [DE,DS,DE1] (DW:ys)        zs             RESULT(11)
s [DE,DS,DE1] ys             (DW:zs)        RESULT(14)
s [DE,DS]     (DE1:DW:ys)    zs             RESULT(12)
s [DE,DS]     ys             (DE1:DW:zs)    RESULT(15)
s [DE]        (DS:DE1:DW:ys) zs             RESULT(13)
s [DE]        ys             (DS:DE1:DW:zs) RESULT(16)
#undef RESULT


-- one on three {
#define RESULT(r) | ws 2 (ys++zs) = [r]
s [DE,DWS1]          (DWS1:ys) (DWS1:zs) RESULT(11)
s [DE,DW,DSWS]       ys       (DWS1:zs) RESULT(9)
s [DE,DS,DW,DE,DWS1] ys       (DWS1:zs) RESULT(14)
#undef RESULT

#define RESULT | ws 2 (ys++zs) = [n+1]
s [DE,DS,DE1,DWN,   DW ,DWS1] ys (DS:zs) RESULT
s [DE,DS,DE1,DWN,DE,DW ,DWS1] ys (DS:zs) RESULT
s [   DS,DE1,DWN,DE,DW ,DWS1] ys (DS:zs) RESULT
s [      DE1,DW, DE,DWN,DWS1] ys (DS:zs) RESULT
#undef RESULT
--one on three }

-- two on one {
s [DE,DWS1] NEL(xs) NEL(ys) | ws 2 (xs'++ys') && isWS 2 x && isWS 2 y = [13]
	where
		(x:xs') = reverse xs
		(y:ys') = reverse ys

#define RESULT(x) | ws 2 (xs++ys') && isWS 2 y = [x] where (y:ys') = reverse ys
s [DE,DW,DSWS]        xs NEL(ys) RESULT(9)
s [DE,DS,DW,DE1,DWS1] xs NEL(ys) RESULT(16)
#undef RESULT

#define RESULT | ws 2 (xs++ys') && isT [S,W,S] y = [n+1] where (y:ys') = reverse ys
s [DE,DS,DE1,DWN,   DW ,DWS1] xs NEL(ys) RESULT
s [DE,DS,DE1,DWN,DE,DW ,DWS1] xs NEL(ys) RESULT
s [   DS,DE1,DWN,DE,DW ,DWS1] xs NEL(ys) RESULT
s [      DE1,DW, DE,DWN,DWS1] xs NEL(ys) RESULT
#undef RESULT
--two on one }

--one on three & two on one {
#define RESULT | ws 2 (xs++ys++zs) && e >= 3 = [n+1]
s (DEE:DS:DWN:    DW:DSWS:xs) ys zs RESULT
s (DEE:DS:DWN:DE1:DW:DSWS:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) && e >= 2 = [n+1]
s (DE :DS:DW:DEE:DWN:DSWS:xs) ys zs RESULT
s (    DS:DW:DEE:DWN:DSWS:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) = [n+1]
s (DE:DS:DE1:DWN:DE:DW:DE1:DSWS:xs) ys zs RESULT
s (   DS:DE1:DWN:DE:DW:DE1:DSWS:xs) ys zs RESULT
s (      DE1:DWN:DE:DW:DE1:DSWS:xs) ys zs RESULT
#undef RESULT


-- kommt nochmal
#define RESULT | ws 2 (xs++ys++zs) = [n+1]
s (DE:DWS1:DS:DE1:DWN:xs) ys zs RESULT
s (DE:DSWS:   DE1:DWN:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) = [n+1]
s (DE:DS:DE2:DWS1:DWN:xs) ys zs RESULT
s (   DS:DE2:DWS1:DWN:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) = [n+3]
s (DE:DS:DE3:DWWSN:xs) ys zs RESULT
s (   DS:DE3:DWWSN:xs) ys zs RESULT
#undef RESULT
--one on three & two on one }

s [DE,DWS1] [DWS2,y,WS h _] zs | ws 2 (y:zs) && h >= 3 = [11]
s [DE,DWS1] (DWS2:xs) NEL(zs)
	| ws 2 (xs++zs') && (isWS 3 z || isWS 4 z) = [11]
		where (z:zs') = reverse zs
s [DE,DWS1] ys [DWS2,z,WS h _] | ws 2 (z:ys) && h >= 3 = [14]
s [DE,DWS1] NEL(ys) (DWS2:zs)
	| ws 2 (ys'++zs) && (isWS 3 y || isWS 4 y) = [14]
		where (y:ys') = reverse ys

s [DE,DW,DS,DE2,DWS1] [DWS1,y,DWS3] zs | ws 2 (y:zs) = [13]
s [DE,DW,DS,DE2,DWS1] (DWS1:ys) NEL(zs) | ws 2 (ys++zs') && isWS 3 z = [16]
	where (z:zs') = reverse zs
s [DE,DW,DS,DE2,DWS1] ys [DWS1,z,DWS3] | ws 2 (z:ys) = [16]
s [DE,DW,DS,DE2,DWS1] NEL(ys) (DWS1:zs) | ws 2 (ys'++zs) && isWS 3 y = [13]
	where (y:ys') = reverse ys

s [DE,DW,DS,DE4,DWS1] [DWS1,y,DWS4] zs | ws 2 (y:zs) = [13]
s [DE,DW,DS,DE4,DWS1] (DWS1:ys) NEL(zs) | ws 2 (ys++zs') && isWS 4 z = [16]
	where (z:zs') = reverse zs
s [DE,DW,DS,DE4,DWS1] ys [DWS1,z,DWS4] | ws 2 (z:ys) = [16]
s [DE,DW,DS,DE4,DWS1] NEL(ys) (DWS1:zs) | ws 2 (ys'++zs) && isWS 4 y = [13]
	where (y:ys') = reverse ys

s [DE,DWN,DS,DE,DWS1] [DWS1,y,WS h _] zs | ws 2 (y:zs) && h >= 3 = [n+1]
s [DE,DWN,DS,DE,DWS1] (DWS1:ys) NEL(zs)
	| ws 2 (ys++zs') && (isWS 3 z || isWS 4 z) = [n+1]
		where (z:zs') = reverse zs
s [DE,DWN,DS,DE,DWS1] ys [DWS1,z,WS h _] | ws 2 (z:ys) && h >= 3 = [n+1]
s [DE,DWN,DS,DE,DWS1] NEL(ys) (DWS1:zs)
	| ws 2 (ys'++zs) && (isWS 3 y || isWS 4 y) = [n+1]
		where (y:ys') = reverse ys

#define RESULT(x) | ws 2 (ys++zs) && (e == 1 || e == 3) = [x]
s [DE,DW,DWS1,DS,DEE,DWS1] (DWS1:ys) zs RESULT(11)
s [DE,DW,DWS1,DS,DEE,DWS1] ys (DWS1:zs) RESULT(14)
s [DE,DWN,DSWS,DEE,DW,DWS1] (DS:ys) zs RESULT(n+1)
s [DE,DWN,DSWS,DEE,DW,DWS1] ys (DS:zs) RESULT(n+1)
s [DE,DS,DW,DE1,DWS1,DEE,DWN,DWS1] (DS:ys) zs RESULT(n+1)
s [DE,DS,DW,DE1,DWS1,DEE,DWN,DWS1] ys (DS:zs) RESULT(n+1)
#undef RESULT

#define RESULT | ws 2 (ys++zs) = [n+1]
s [DE,DS,DE1,DWN,DE,DWS1,DW,DE1,DWS1] (DS:ys) zs RESULT
s [DE,DS,DE1,DWN,DE,DWS1,DW,DE1,DWS1] ys (DS:zs) RESULT
s [DE,DS,DE1,DWN,DE,DWS1,DE2,DW,DE1,DWS1] (DS:ys) zs RESULT
s [DE,DS,DE1,DWN,DE,DWS1,DE2,DW,DE1,DWS1] ys (DS:zs) RESULT
#undef RESULT

#define RESULT | ws 2 (ys++zs) = [2]
s [DS,DE1,DWN,DE,DWS1,DW,DE1,DWS1] (DS:ys) zs RESULT
s [DS,DE1,DWN,DE,DWS1,DW,DE1,DWS1] ys (DS:zs) RESULT
s [DS,DE1,DWN,DE,DWS1,DE2,DW,DE1,DWS1] (DS:ys) zs RESULT
s [DS,DE1,DWN,DE,DWS1,DE2,DW,DE1,DWS1] ys (DS:zs) RESULT
#undef RESULT

#define RESULT | ws 2 (ys++zs) = [8]
s [DE1,DW,DE5,DWS1,DW,DE1,DWS1] (DS:ys) zs RESULT
s [DE1,DW,DE5,DWS1,DW,DE1,DWS1] ys (DS:zs) RESULT
s [DE1,DW,DE3,DWS1,DE2,DW,DE1,DWS1] (DS:ys) zs RESULT
s [DE1,DW,DE3,DWS1,DE2,DW,DE1,DWS1] ys (DS:zs) RESULT
#undef RESULT

#define RESULT | ws 2 (ys++zs) = [1]
s [DE1,DW,DE5,DWWS,DE2,DSWS] ys zs RESULT
s [DE1,DW,DE3,DWS1,DE1,DW,DE2,DSWS] ys zs RESULT
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) && e >= 2 = [0]
s (DW:DEE:(T [S,W,W,S] _):xs) ys zs RESULT
s (DW:DEE:DWS1:DE1:DSW:xs) ys zs RESULT
#undef RESULT

#define RESULT(r) | ws 2 (xs++ys++zs) = [r]
s (DE:DS:DE3:DWWSN:xs) ys zs RESULT(n+3)
s (   DS:DE3:DWWSN:xs) ys zs RESULT(4)
#undef RESULT

s [DE,DS,DW,DE ,DWS1,DWN,DE,DSWS] ys zs | ws 2 (ys++zs) = [n+1]
s [   DS,DW,DE5,DWS1,DW ,DE,DSWS] ys zs | ws 2 (ys++zs) = [8]

s [DE,DS,DE1,DWN,DEE,DWWS,DE2,DSWS] ys zs | ws 2 (ys++zs) && e >= 2 = [n+1]
s [   DS,DE1,DW ,DE4,DWWS,DE2,DSWS] ys zs | ws 2 (ys++zs) = [2]

#define RESULT(r) | ws 2 (xs++ys++zs) = [r]
s (DE:DS:DWN:DE:T [S,W,W,S] _:xs) ys zs RESULT(n+1)
s (   DS:DW :DE:T [S,W,W,S] _:xs) ys zs RESULT(1)
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) = [n+3]
s (DE:DWS1:DE:DS:DE3:DWWSN:xs) ys zs RESULT
s (   DWS1:DE:DS:DE3:DWWSN:xs) ys zs RESULT
s (DE:DWS1   :DS:DE3:DWWSN:xs) ys zs RESULT
s (   DWS1   :DS:DE3:DWWSN:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) = [n+1]
s (DE:DWS1:DE:DS  :DE1:DWN:xs) ys zs RESULT
s (   DWS1:DE:DS  :DE1:DWN:xs) ys zs RESULT
--s (DE:DWS1   :DS  :DE1:DWN:xs) ys zs RESULT
s (   DWS1   :DS  :DE1:DWN:xs) ys zs RESULT
--s (DE        :DSWS:DE1:DWN:xs) ys zs RESULT
s (           DSWS:DE1:DWN:xs) ys zs RESULT
#undef RESULT
-- auskommentierte oben schon mal

s (DEE:DWS1N:DW:xs) ys zs | ws 2 (xs++ys++zs) && e <= 2 = [n+2]
s (    DWS1 :DW:xs) ys zs | ws 2 (xs++ys++zs) = [0]
s (DW:DS:DE:DW:xs) ys zs | ws 2 (xs++ys++zs) = [0]

#define RESULT(r) | ws 2 (xs++ys++zs) = [r]
s (DE:DSWS:DE3:DWWSN:xs) ys zs RESULT(n+3)
s (   DSWS:DE3:DWWS :xs) ys zs RESULT(4)
#undef RESULT

s (DEE:DS:DWS1N:DE2       :DWWS :xs) ys zs | ws 2 (xs++ys++zs) && e >= 2 = [n+2]

#define RESULT | ws 2 (xs++ys++zs) = [n+3]
s (DE:DSW:DE1:DS     :DE2:DWWSN:xs) ys zs RESULT
s (DE:DW  :(T [S,S] _):DE3:DWWSN:xs) ys zs RESULT
#undef RESULT

#define RESULT(r) | ws 2 (xs++ys++zs) = [r]
s (DE:DS:DWN:DS:DW:xs) ys zs RESULT(n+1)
s (   DS:DWN:DS:DW:xs) ys zs RESULT(1)
#undef RESULT

#define RESULT(r) | ws 2 (ys++zs) = [r]
s [DE5,DW,DE1,DSWS,DE1,DW,DSWS] ys zs RESULT(9)
s [DE5,DW,DE1,T [S,S,W,S] _,DW,DE1,DWS1] ys zs RESULT(5)
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) = [n+1]
s (DE:DS:DW:DE:DSWS:DWN:xs) ys zs RESULT
s (   DS:DW:DE:DSWS:DWN:xs) ys zs RESULT
s (DE:DS:DW   :DSWS:DWN:xs) ys zs RESULT
s (   DS:DW   :DSWS:DWN:xs) ys zs RESULT
#undef RESULT

#define RESULT(r) | ws 2 (ys++zs) = [r]
s [DE,DW,DWS1,DS,DW,DSWS] ys zs RESULT(6)
--s [DE5,DW,DE1,DSWS,DE1,DW,DSWS] ys zs RESULT(9)
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) = [n+1]
s (DE:DWN:DE1:DSWS:DS:DW:xs) ys zs RESULT
s (DE:DSW:DE:DWS1:DS:DWN:xs) ys zs RESULT
s (DE:DW:DE2:(T [S,S,W,S] _):DE1:DWN:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 2 (ys++zs) = [8]
s [DE,DS,DW,DE,DWS1,DE2,DW,DE1,DSWS] ys zs RESULT
s [   DS,DW,DE,DWS1,DE2,DW,DE1,DSWS] ys zs RESULT
#undef RESULT

#define RESULT(r) | ws 2 (ys++zs) = [r]
s [DE,DS,DE1,DWN,DE ,DWS1,DE1,DW,DE2,DSWS] ys zs RESULT(n+1)
s [   DS,DE1,DW ,DE ,DWS1,DE1,DW,DE2,DSWS] ys zs RESULT(2)
s [      DE1,DW ,DE3,DWS1,DE1,DW,DE2,DSWS] ys zs RESULT(1)
#undef RESULT

#define RESULT(r) | ws 2 (xs++ys++zs) = [r]
s (DE:DS:DWN:DE:DWS1:DE1:DSW:xs) ys zs RESULT(n+1)
s (   DS:DW :DE:DWS1:DE1:DSW:xs) ys zs RESULT(1)
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) && e >= 2 = [n+1]
s (DE:DWS1:DEE:DSWS:DE1:DWN:xs) ys zs RESULT
s (   DWS1:DEE:DSWS:DE1:DWN:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 2 (xs++ys++zs) = [6]
s (DE2:DSWS   :DE2:DWS1:DW:xs) ys zs RESULT
s (DE1:DWS1:DS:DE2:DWS1:DW:xs) ys zs RESULT
s (DWS1:DE1:DS:DE2:DWS1:DW:xs) ys zs RESULT
#undef RESULT

#define RESULT(r) | ws 2 (xs++ys++zs) = [r]
s (DE:DWS1N:DE2:DWWS:xs) ys zs RESULT(n+2)
s (DW:DS:DE3:DWWS:xs) ys zs RESULT(0)
s (DS:DE4:DWWS:xs) ys zs RESULT(5)
#undef RESULT


#define RESULT | ws 2 (xs++ys++zs) = [5]
s (DE1:DSWS:DE3:DWWS:xs) ys zs RESULT
s (DWS1:DS: DE3:DWWS:xs) ys zs RESULT
#undef RESULT

s [DE3,DW,DE1,DSWS,DE3,DW,DSWS] ys zs | ws 2 (ys++zs) = [9]

#define RESULT(r) | ws 2 (xs++ys++zs) = [r]
s (DE3:DW: DE1:DSWS:DE1:DS:DW:xs) ys zs RESULT(3)
s (DE2:DSW:DE2:DWS1:DE1:DS:DW:xs) ys zs RESULT(8)
s (DE2:DSW:DE2:DWS1    :DS:DW:xs) ys zs RESULT(7)
s (DE2:DW :DE2:DSWS:DS:DE1:DW:xs) ys zs RESULT(8)
#undef RESULT

#define RESULT(r) | ws 2 (ys++zs) = [r]
s [DE4,DW,DWS1,DS,DE2,DW    ,DSWS] ys zs RESULT(9)
s [DE4,DW,DSWS   ,DE2,DW,DE1,DSWS] ys zs RESULT(4)
#undef RESULT

#define RESULT(r) | ws 2 (xs++ys++zs) = [r]
s (DE4:DW:DWS1:DS:DS:DW:xs) ys zs RESULT(8)
s (DE4:DW:DSWS:DE1:DWS1:xs) ys zs RESULT(7)
s (DE4:DW:DWS2:DS:xs)       ys zs RESULT(4)
s (DE3:DW:DE1:(T [S,W,S,W,S] _):xs) ys zs RESULT(3)
s (DS:DE1:DW:DE2:DWS2:xs)           ys zs RESULT(2)
#undef RESULT

#define RESULT(r) | ws 7 (xs++[y1,y2]++zs) = [r]
s (DE1:DW:DE3:DWS2:xs) [y1,DWS3,y2] zs RESULT(12)
s (DE1:DW:DE3:DWS2:xs) zs [y1,DWS3,y2] RESULT(15)
#undef RESULT

#define RESULT(r) | ws 7 (xs++ys++zs) = [r]
s (DE1:DW:DE3:DWS2:DW:DS:xs) ys zs RESULT(6)
s (DE1:DW:DE3:DD2:DS:xs) ys zs RESULT(1)
s (    DW:DE4:(T [S,W,W,S,W,S] _):xs) ys zs RESULT(0)
#undef RESULT


s [DE1,DW,DE3,DWS2,DE4,DWS1] ys zs | ws 7 (ys++zs) = [10]
s (DE1:DW:DE3:DWS2:DE:DWN:DS:xs) ys zs | ws 7 (xs++ys++zs) = [n+1]


s (DE5:DD2:xs) ys zs | ws 7 (xs++ys++zs)
	= [ case [ (h,n) | WS h n <- xs++ys ] of
			((h,n):_) -> n+2*h
			[]        -> case head [ (h,n) | WS h n <- zs ] of
					(1,14) -> 16
					(h,n)  -> n+2*h+3 ]

#define RESULT | ws 7 (xs++ys++zs) = [5]
s (DE5:DD2:DE:DW:DS:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 7 (ys++zs) = [5]
s [DE5,DD2,DE4,DW] (DS:ys)        zs             RESULT
s [DE5,DD2,DE4,DW] ys            (DS:zs)        RESULT
s [DE5,DD2,DE5]    (DW:DS:ys)     zs             RESULT
s [DE5,DD2,DE5]    ys             (DW:DS:zs)     RESULT
s [DE5,DD2,DE5]    (DE1:DW:DS:ys) zs             RESULT
s [DE5,DD2,DE5]    ys             (DE1:DW:DS:zs) RESULT
#undef RESULT

#define RESULT | ws 7 (xs++ys++zs) = [0]
s (DW:DE4:DWS2:DE:DSW:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 7 (ys++zs) = [0]
s [DW,DE4,DWS2,DE5] (DSW:ys)    zs          RESULT
s [DW,DE4,DWS2,DE5] ys          (DSW:zs)    RESULT
s [DW,DE4,DWS2,DE5] (DE:DSW:ys) zs          RESULT
s [DW,DE4,DWS2,DE5] ys          (DE:DSW:zs) RESULT
#undef RESULT

#define RESULT(r) | ws 7 (xs++ys++zs) = [r]
s (DE5:(T [S,W,S,W,S] _):DE1:DW:xs) ys zs RESULT(7)
s (DS:DE4:DWS2:DW:xs) ys zs RESULT(6)
s (DE5:DWS2   :DS:DE1:DW :xs) ys zs RESULT(8)
s (DE5:DWS2:DE:DS:DE1:DWN:xs) ys zs RESULT(n+1)
#undef RESULT

#define RESULT(r) | ws 7 (ys++zs) = [r]
s [DE5,DWS2,DE3,DS,DE1] (DW:ys) zs RESULT(11)
s [DE5,DWS2,DE3,DS,DE1] ys (DW:zs) RESULT(14)
#undef RESULT


s [DE5,DD2,DE5] [DE3] [DE3] = [5]
s [DW,DE4,DWS2,DE5] [DE3] [DE3] = [0]
s [DE5,DWS2,DE5] [DE3] [DE3] = [5]
s [DE1,DW,DS,DE2,DWS1,DE5] [DE3] [DE3] = [1]
s [    DW,DS,DE3,DWS1,DE5] [DE3] [DE3] = [0]
s [DS,DE4,DWS1,DE5] [DE3] [DE3] = [5]
s [DS,DE,DWN,DS,DE] [DE3] [DE3] = [n+1]
s [DS,DW,DS,DE] [DE3] [DE3] = [1]
s [DWS1,DS,DE] [DE3] [DE3] = [0]
-- voila

#define RESULT(r) | ws 5 (xs++ys++zs) = [r]
s (DS:DE1:DW:DWS1:xs) ys zs RESULT(2)
s (DE1:DW:DE1:DWS1:DE3:DWS1:xs) ys zs RESULT(7)
s (DE1:DW:DE1:DWS1:DE:DWN:DS:xs) ys zs RESULT(n+1)
s (DE1:DW:DE1:DWS1:DW:DS:xs) ys zs RESULT(4)
s (DE1:DW:DE1:DWWS:DS:xs) ys zs RESULT(1)
s (DW:DE2:(T [S,W,W,S] _):xs) ys zs RESULT(0)
#undef RESULT


s (DE3:DD1:xs) ys zs | ws 5 (xs++ys++zs)
	= [ case [ (h,n) | WS h n <- xs++ys ] of
			((h,n):_) -> n+2*h
			[]        -> case head [ (h,n) | WS h n <- zs ] of
					(1,14) -> 16
					(h,n)  -> n+2*h+3 ]

#define RESULT | ws 5 (xs++ys++zs) = [3]
s (DE3:DD1:DE:DW:DS:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 5 (ys++zs) = [3]
s [DE3,DD1,DE,DW] (DS:ys)        zs             RESULT
s [DE3,DD1,DE,DW] ys            (DS:zs)        RESULT
s [DE3,DD1,DE]    (DW:DS:ys)     zs             RESULT
s [DE3,DD1,DE]    ys             (DW:DS:zs)     RESULT
s [DE3,DD1,DE]    (DE1:DW:DS:ys) zs             RESULT
s [DE3,DD1,DE]    ys             (DE1:DW:DS:zs) RESULT
#undef RESULT

#define RESULT | ws 5 (xs++ys++zs) = [0]
s (DW:DE2:DWS1:DE:DSW:xs) ys zs RESULT
#undef RESULT

#define RESULT | ws 5 (ys++zs) = [0]
s [DW,DE2,DWS1,DE] (DSW:ys)    zs          RESULT
s [DW,DE2,DWS1,DE] ys          (DSW:zs)    RESULT
s [DW,DE2,DWS1,DE] (DE:DSW:ys) zs          RESULT
s [DW,DE2,DWS1,DE] ys          (DE:DSW:zs) RESULT
#undef RESULT

#define RESULT(r) | ws 5 (xs++ys++zs) = [r]
s (DE3:DSWS:DE1:DW:xs) ys zs RESULT(5)
s (DS:DE2:DWS1:DW:xs) ys zs RESULT(4)
s (DE3:DWS1   :DS:DE1:DW :xs) ys zs RESULT(6)
s (DE3:DWS1:DE:DS:DE1:DWN:xs) ys zs RESULT(n+1)
#undef RESULT

#define RESULT(r) | ws 5 (ys++zs) = [r]
s [DE3,DWS1,DE5,DS,DE1] (DW:ys) zs RESULT(11)
s [DE3,DWS1,DE5,DS,DE1] ys (DW:zs) RESULT(14)
#undef RESULT


s [DE3,DD1,DE] [DE3] [DE3] = [3]
s [DW,DE2,DWS1,DE] [DE3] [DE3] = [0]
-- voila




s _ _ _ = []
