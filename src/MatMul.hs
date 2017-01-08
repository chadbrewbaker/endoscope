module MatMul where

import           BrewLib
import           Control.Monad
import           Data.List

--toZ2 :: Num a => a -> a
toZ2 a =  mod a 2
toZ2_close a | a > 1 = 1
             | otherwise = a  
toZn n a = mod a n

--mmult :: Num a => [[a]] -> [[a]] -> [[a]]
mmult a b = [ [ toZ2 $ sum $ zipWith (*) ar bc | bc <- transpose b ] | ar <- a ]
mmult_close a b = [ [ toZ2_close $ sum $ zipWith (*) ar bc | bc <- transpose b ] | ar <- a ]
mmultn a b n = [ [ toZn n $ sum $ zipWith (*) ar bc | bc <- transpose b ] | ar <- a ]

madd a b = [ [ toZ2 $ product $ zipWith (+) ar bc | bc <- transpose b ] | ar <- a ]
madd_close a b = [ [ toZ2_close $ product $ zipWith (+) ar bc | bc <- transpose b ] | ar <- a ]
maddn a b n = [ [ toZn n $ product $ zipWith (+) ar bc | bc <- transpose b ] | ar <- a ]

pListz2 :: Int -> [[Integer]]
pListz2 x = replicateM x [0,1] 

matsZ2 :: Int -> [[[Integer]]]
matsZ2 n =  replicateM n $ pListz2 n

pListz :: Int -> Int -> [[Integer]]
pListz n x = replicateM n $ take x [0..] 

matsZn :: Int -> Int -> [[[Integer]]]
matsZn n k =  replicateM n $ pListz n k




