module Endoscope where

import Data.Graph

import Data.Set (Set)
import qualified Data.Set as Set

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

-- getIdempotents :: FunSet -> [a]

-- getTreelikes :: FunSet -> [a]
-- getLeaves :: FunSet -> [a]
-- getGroupLikes :: Funset -> [a]


-- getLolipopHistogram :: FunSet -> [ (IntCount,IntInex, IntPeriod)]

-- getCompositionTable :: FunSet - > [ [IntFunID]] 


-- gadgets :: (a -> a) -> [[a]]
-- Returns the list of connected components in the function graph

-- ordNarrowGadgets :: (a -> a) -> [[a]]
-- Returns the list of connected components in the function graph in order of size where size < lg^{1/3} n

-- wideGadgets :: (a -> a) -> [[a]]
-- Returns the list of connected components in the function graph where size > lg^{1/3} n


-- toSuccinct :: (a -> a) -> SuccinctFunction

mono :: Ord a => (a -> a -> a) -> (a,a) -> Set a -> Set a
mono mult (primal,current) accum = if Set.member next accum then accum else mono mult (primal, next) (Set.insert next accum)
    where
      next = mult primal current

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


type Row = [Bool]
type BoolMatrix = [Row]

multBM :: BoolMatrix -> BoolMatrix -> BoolMatrix
multBM a b = undefined



mul7 :: Int -> Int -> Int
mul7 x y = mod (x*y) 7

mulX :: Int -> Int -> Int -> Int
mulX m x y = mod (x*y) m


-- cycle through print mult x x == x

idempotents :: Int -> (Int -> Int -> Int) -> [Int]
idempotents size mult = concat [ selectSame i  | i <- [0.. size] ]
    where
       selectSame x |  mult x x == x  = [x]
                    | otherwise  = []




-- Examples:
-- Z2 Matrices | domain 2^{n*n}
-- Z3 matrices | domain 3^{n*n}
-- Life  | domain 2^{n*k}
-- EndoFactors | domain 2^{n+k}
--  Z_(k) +, * | domain n


-- Two concepts: Succinct representation of a single function, monogenic graph over a set of functions





--transMult :: [a] -> [a] -> [a]
--transMult x:xs ys = 

main = do 
          print $ idempotents 7 mul7
          print $ mono mul7 (2,2) Set.empty
--mono :: Ord a => (a -> a -> a) -> (a,a) -> Set a -> Set a
--mono mult (primal,current) accum

   -- print $ components $ endoscope (3*3) mul7
    
