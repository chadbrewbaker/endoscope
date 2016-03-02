module MatMul where

import           BrewLib
import           Control.Monad
import           Data.List

--toZ2 :: Num a => a -> a
toZ2 a =  mod a 2

--mmult :: Num a => [[a]] -> [[a]] -> [[a]]
mmult a b = [ [ toZ2 $ sum $ zipWith (*) ar bc | bc <- transpose b ] | ar <- a ]

madd a b = [ [ toZ2 $ product $ zipWith (+) ar bc | bc <- transpose b ] | ar <- a ]


powerListz2 ::Num a =>[[a]] -> [[a]]
powerListz2 [] = []
powerListz2 (x:xs) = (1:x) : (0:x) : powerListz2 xs

-- Why not just pListz2 x = replicateM x [0,1]?  Does the order matter?
pListz2 :: Int -> [[Integer]]
pListz2 x = head.reverse $take x (iterate  powerListz2 [[]])

matsZ2 :: Int -> [[[Integer]]]
matsZ2 n =  replicateM n $ pListz2 (n+1)


