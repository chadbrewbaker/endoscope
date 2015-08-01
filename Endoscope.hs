module Endoscope where

import Data.Graph

type Leaves = Integer
type Treelike = Bool

--endomult :: e -> e -> e
--endomult = undefined

--unrank :: Int -> e
--unrank = undefined

--enum :: Int -> Int
-- enum = undefined

--unranks :: Int -> String
--unranks = undefined


monogenic :: Int -> Int -> (Int -> Int -> Int) -> [Int]
monogenic size seed mult = take size $ iterate f seed
   where
      f = mult seed

endoscope :: Int -> (Int -> Int -> Int) -> Graph
endoscope size mult = buildG (0,size) $ concat [ g i | i <- [0..size]] 

  where 
      g blar =  zip (replicate size  blar) (f blar)  
        where
          f x = monogenic size x mult

mul7 :: Int -> Int -> Int
mul7 x y = mod (x*y) 7

mulX :: Int -> Int -> Int -> Int
mulX m x y = mod (x*y) m


-- cycle through print mult x x == x

idempotents :: Int -> (Int -> Int -> Int) -> [Int]
idempotents size mult = concat [ (selectSame i)  | i <- [0.. size] ]
    where
       selectSame x |  (mult x x) == x  = [x]
                    | otherwise  = []

main = do 
          print $ idempotents 7 mul7
   -- print $ components $ endoscope (3*3) mul7
    
