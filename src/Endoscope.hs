module Endoscope where

import Data.Graph
import qualified Data.Graph as Graph

import Data.Set (Set)
import qualified Data.Set as Set

import qualified Data.Vector as Vector

import qualified Data.Array as Array

import qualified Data.List as List

import qualified Data.Map as Map

import System.Exit

import MatMul
import Control.Monad
import qualified System.Process as Process
import Data.List
import Unsafe.Coerce
--import System.Environment
-- getargs gets the command line args if we need them

type Leaves = Integer
type Treelike = Bool

powset = Control.Monad.filterM (const [True, False])

transMult a b =  Vector.toList $Vector.backpermute (Vector.fromList a) (Vector.fromList b)

trans x = replicateM (length x) x


-- Applies a polynomial transformation to the identiy function
polyToTrans f =  map getIndex [0..n-1]
            where
            rmod i j = mod j i
            getIndex i = rmod n $ sum $ map (cmult i) $ zip f (take n [0..])
            n = length f
            cmult i (coef, expon)  = mod (coef * (i^expon) ) n

polyTransPairs x = zip (trans x) ( map polyToTrans $ trans x)
forbTrans n =  Set.difference (Set.fromList (trans n))  $ Set.fromList $ map snd  $ polyTransPairs n

polySet n = Set.fromList $ map snd  $ polyTransPairs [0..n]
fullSet n = Set.fromList $ trans [0..n]
forbTransSet n = Set.difference (fullSet n) (polySet n)

-- Chad: I think this is a generalization of the AKS primality test.
--       If we can prove an endofunction doesn't exist, or two of the same exist,
--       then we have shown that $n$ is composite.
a058067 n = Set.size $ Set.fromList $ map snd  $ polyTransPairs [0..n]

perm x =  List.permutations [0..x-1]



hash thing = Map.fromList $ zip thing [0..(length thing)]
rhash thing = Map.fromList $ zip [0..(length thing)] thing 





--snippet

barehline = "\\hline\n"
hline = "\\\\ \\hline\n"

stripChars :: String -> String -> String
--stripChars x y = y
stripChars = filter . flip notElem

zipCat :: [a] -> [[a]] -> [[a]]
zipCat = zipWith (curry smush)
    where
      smush (a,b) = a : b

latexTable :: (Show a) => String -> [a] -> [[a]] -> String
latexTable op lab x = prefix ++ barehline ++ stripChars "\"" (op ++ "&" ++ tosArr lab) ++ stripChars "\"" (eachRow (zipCat lab x)) ++ suffix

     where
        prefix = "\\begin{tabular}{ |"++ cstring (length x)  ++ " }"
        elt = "c |"
        cstring x = concat $ replicate (x+1) elt
        suffix ="\\end{tabular}"


eachRow :: (Show a) => [[a]] -> String
eachRow [[]] = ""
eachRow [] = ""
eachRow [x] = tosArr x
eachRow (x:xs) = tosArr x ++ eachRow xs

tosArr :: (Show a) => [a] -> String
tosArr (x:xs) = show x ++ tosArr' xs ++ hline


tosArr' :: (Show a) => [a] -> String
tosArr' [] = []
tosArr' [x] = "&" ++ show x
tosArr' (x:xs) = "&" ++ show x ++  tosArr' xs

--endomult :: e -> e -> e
--endomult = undefined

--unrank :: Int -> e
--unrank = undefined

--enum :: Int -> Int
-- enum = undefined

--unranks :: Int -> String
--unranks = undefined

-- getIdempotents :: FunSet -> [a]

-- getTreelikes :: Set (a,a) -> [a] -- Have index >= 1
-- getLeaves :: Set (a,a) -> [a] -- nobody as a power goes to one of these guys
-- getGroupLikes :: Set (a,a) -> [a]  --- Have index == 0
-- Type Index = Integer
-- Type Period = Integer

-- classify :: a -> (Index, Period)


-- getLolipopHistogram :: FunSet -> [ (IntCount,IntInex, IntPeriod)]

-- getCompositionTable :: FunSet - > [ [IntFunID]]


-- gadgets :: (a -> a) -> [[a]]
-- Returns the list of connected components in the function graph

-- ordNarrowGadgets :: (a -> a) -> [[a]]
-- Returns the list of connected components in the function graph in order of size where size < lg^{1/3} n

-- wideGadgets :: (a -> a) -> [[a]]
-- Returns the list of connected components in the function graph where size > lg^{1/3} n

-- toSuccinct :: (a -> a) -> SuccinctFunction



-- Usage: mono mult (primal,primal) Set.empty
-- Returns the set of elments generated by iterating primal




--Type Index = Integer
--Type Period = Integer

-- classify :: mult a -> (Index,Period, FirstCycle, Idempotent)
--classify :: (a -> a -> a) -> a -> (Index, Period, a , a )

monoStates' :: Ord a => Int -> (a -> a -> a) -> (a,a) -> [(a,a)]
monoStates' 0 mult (primal, current) = []
monoStates' 1 mult (primal, current) = [(current, mult primal current)]
monoStates' budget mult (primal, current) = (current, nextState) : monoStates' (budget -1) mult (primal, nextState)
      where
        nextState = mult primal current

monoStates :: Ord a =>  Int -> (a -> a -> a) -> a -> [(a,a)]
monoStates budget mult primal = List.nub $ monoStates' budget mult (primal, primal)


getMonoEdges :: Ord a => [a] -> (a -> a -> a) -> [(a,a)]
getMonoEdges elts mult = foldr ((++) . boundthing) [] elts
     where
       boundthing = monoStates (length elts) mult

leftMultEdges :: [a] -> (a -> a -> a) -> a -> [(a,a)]
leftMultEdgs [] _ _ = []
leftMultEdges (x:[]) mult elt = [(elt, mult elt x)]
leftMultEdges (x:xs) mult elt = (elt, mult elt x) : leftMultEdges xs mult elt


rightMultEdges :: [a] -> (a -> a -> a) -> a -> [(a,a)]
rightMultEdgs [] _  _ = []
rightMultEdges (x:[]) mult elt =  [(x, mult elt x)]
rightMultEdges (x:xs) mult elt =  (x, mult elt x) : rightMultEdges xs mult elt


getLeftMultEdges :: Ord a => [a] -> (a -> a -> a) -> [(a,a)]
getLeftMultEdges elts mult = List.nub $ foldr ((++) . boundthing) [] elts
      where
        boundthing = leftMultEdges elts mult

getRightMultEdges :: Ord a => [a] -> (a -> a -> a) -> [(a,a)]
getRightMultEdges elts mult = List.nub $ foldr ((++) . boundthing) [] elts
      where
        boundthing = rightMultEdges elts mult


mono' :: Ord a => (a -> a -> a) -> (a,a) -> Set (a,a) -> Set (a,a)
mono' mult (primal, current) accum = if Set.member (primal,next) accum then accum else mono' mult (primal, next) (Set.insert (primal,next) accum)
    where
      next = mult primal current

mono :: Ord a =>  (a -> a -> a) -> a -> Set (a,a)
mono mult primal = mono' mult (primal,primal) Set.empty

-- [(generator,[index elements], [cycle elements]) ]
indexAndCycle :: Ord a => a -> (a ->a ->a) -> (a, [a], [a] )
indexAndCycle elt mult = (elt, singles, cycles)
    where
        doubleSize = 2*2 *  Set.size  (mono' mult (elt,elt) Set.empty)
        boundMult = mult elt
        toCount elts = (head elts, length elts)
        histo =  map toCount $ List.group $ List.sort $ take doubleSize $ iterate boundMult elt
        isSingle (a,len) = len == 1
        singles = map fst $ filter isSingle histo
        cycles = map fst $ filter (not . isSingle) histo



indexAndCycleCounts elt mult =   compact $ indexAndCycle elt mult
          where
                  compact  (a, xs, ys) = (length xs, length ys)

--allCounts :: Ord a => [a] -> (a ->a ->a) -> [(b,b)]
allCounts [] mult = []
allCounts [x] mult = [indexAndCycleCounts x mult]
allCounts (x:xs) mult = indexAndCycleCounts x mult  : allCounts xs mult

allHistos :: Ord a => [a] -> (a ->a ->a) -> [(a, [a], [a] )]
allHistos [] mult = []
allHistos [x] mult = [indexAndCycle x mult]
allHistos (x:xs) mult = indexAndCycle x mult : allHistos xs mult


cartProd :: Ord a => [a] -> (a -> a -> a) -> [a]
cartProd elts mult = map multOnPair $ Control.Monad.liftM2 (,) elts elts --mapped
     where
      multOnPair (x,y) = mult x y


-- mTable :: [a] -> (a -> a -> a) -> [[a]]
-- mTable  elts mult =  chunkRows (length elts)  [ mult x y | x <- elts , y <- elts ]

-- rightmTable elts mult = List.transpose $ mTable elts mult

--mTrips :: [a] -> (a -> a -> a) -> [(a,a,a)]
--mTrips elts mult =  [ (mult x y, x, y) | x <- elts , y <- elts ]

filterLeft (a,b,_) = (a,b)
filterRight (a,_,c) = (a,c)

swap (a,b) = (b,a)

-- leftMultEdgeList elts mult = map filterLeft $ mTrips elts mult
-- invLeftMultEdgeList elts mult = map swap $ leftMultEdgeList elts mult

-- rightMultEdgeList elts mult = map filterRight $ mTrips elts mult
-- invRightMultEdgeList elts mult = map swap $ rightMultEdgeList elts mult


chunkRows :: Int -> [a] ->[[a]]
chunkRows n [] = []
chunkRows n xs = take n xs : chunkRows n (drop n xs)

-- endoscope :: generator -> endoFunc -> Set (a,a)
endoscope :: Ord a => [a] -> (a -> a -> a) -> Set (a,a)
endoscope elts mult = foldr (Set.union . mono mult) Set.empty elts
--endoscope' elts mult = foldr Set.union Set.empty (map (mono' mult) elts )
--foldr :: (a -> b -> b) -> b -> [a] -> b

monoGraph :: Bounds -> Set Edge -> Graph
monoGraph b edges = Graph.buildG b $ Set.toList edges

leaves =  Graph.indegree
-- Graph.indegree :: Graph -> Table Int


deTouple = map deTouple'
     where
      deTouple' a = [fst a, snd a]


--- Endofunctions where they are not a child of anyone else
-- (_,a)  matches [(a,a)] or []
-- (6,[]),(7,[7])
-- (a, []) = True
-- (a, [a] ) = True
-- _ false
--Array.elems
getLeaves elts mult =  filter isLeaf $ zip (Array.indices theInvertGraph) (Array.elems theInvertGraph)--thingIds
--getLeaves elts mult = Graph.indegree $ monoGraph bounds $ endoscope' elts mult
     where
        -- bounds = (length elts, length elts)
         thingIds = zip thing [0..(length thing)]
         thing = List.nub $ concat $ deTouple $ Set.toList $  endoscope elts mult
         thingToIDMap = Map.fromList thingIds
         mapPair (a,b) = ( (Map.!) thingToIDMap a, (Map.!) thingToIDMap b )
         forGraph = map mapPair  $ Set.toList $ endoscope elts mult

         theGraph = Graph.buildG (0, length thing - 1 ) forGraph
         theInvertGraph = Graph.transposeG theGraph
         isLeaf (i,[]) = True
         isLeaf (i, [x]) | i == x  = True
         isLeaf (_, _) = False


getGraph elts mult = theGraph
  where
         thing = List.nub $ concat $ deTouple $ Set.toList $  endoscope elts mult
         thingIds = zip thing [0..(length thing)]
         thingToIDMap = Map.fromList thingIds
         mapPair (a,b) = ( (Map.!) thingToIDMap a, (Map.!) thingToIDMap b )
         forGraph = map mapPair  $ Set.toList $ endoscope elts mult
         theGraph = Graph.buildG (0, length thing - 1 ) forGraph


getMonoReachabilityGraph :: Ord a => [a] -> (a -> a -> a) -> Graph
getMonoReachabilityGraph elts mult = g
  where
        -- First build a hashtable of (a, index) pairs so we can get a cannonical
        -- index of each element of elts
        thingIds = zip elts [0..(length elts)]
        thingToIDMap = Map.fromList thingIds
        -- need [(a,a)] -> [(Int,Int)]
        gEdges = Set.toList $ endoscope elts mult
        mapPair (a,b) = ( (Map.!) thingToIDMap a, (Map.!) thingToIDMap b )
      --  foo (a, b) = (thingToIDMap a, thingToIDMap b)
        gEdgesAsInts = map mapPair gEdges
        g = Graph.buildG (0, length elts - 1 )  gEdgesAsInts


getMonoDetectionGraph :: Ord a =>  [a] -> (a -> a -> a) -> Graph
getMonoDetectionGraph elts mult = Graph.buildG (0, length elts - 1 ) $ addLoops (length elts) $ Graph.edges $ Graph.transposeG $ getMonoReachabilityGraph elts mult


addLoops :: Int -> [(Int,Int)] -> [(Int,Int)]
--addLoops k []  = []
addLoops k xs =  List.nub $ getLoops k ++ xs

getLoop y = (y,y)
getLoops n = map getLoop [0..(n-1)]



getGraphWithEdgesFunc elts mults getEdgesFunc = g
   where 
        thingIds = zip elts [0..(length elts)]
        thingToIDMap = Map.fromList thingIds
        gEdges = getEdgesFunc elts mults
        mapPair (a,b) = ( (Map.!) thingToIDMap a, (Map.!) thingToIDMap b )
        gEdgesAsInts = map mapPair gEdges
        g = Graph.buildG (0, length elts - 1 ) gEdgesAsInts



-- f^i =  f,g,h,f  -> [(f,g), (g,h), (h,f)]

getMonoTransitionGraph elts mults = getGraphWithEdgesFunc elts mults getMonoEdges
  

-- f = (g,h) use (f,g) as edge
getLeftTransitionGraph elts mults =   getGraphWithEdgesFunc elts mults getLeftMultEdges



-- f = (g,h) use (f,h) as edge
getRightTransitionGraph elts mults =  getGraphWithEdgesFunc elts mults  getRightMultEdges 



--getTransitionTree = undefined
--getRightTransitionTree = undefined


--thing = List.nub $ concat $ deTouple $ Set.toList $ endoTransThing 3
--thingIds = zip thing [0..(length thing)]
--thingToIDMap = Map.fromList thingIds
--invert (a,b) = (b,a)
--idToThingMap = Map.fromList $ map invert thingIds



type Row = [Bool]
type BoolMatrix = [Row]

multBM :: BoolMatrix -> BoolMatrix -> BoolMatrix
multBM a b = undefined



mul7 :: Int -> Int -> Int
mul7 x y = mod (x*y) 7

mulX :: Int -> Int -> Int -> Int
mulX m x y = mod (x*y) m

addX :: Int -> Int -> Int -> Int
addX m x y = mod (x+y) m


--Speed this up using Borwein tables?
-- https://gist.github.com/chadbrewbaker/8445183
factorial 0 = 1
factorial 1 = 1
factorial n = n * factorial (n-1)

binomial n k = div (factorial n) ( factorial k * factorial (n-k) )

aksBinomial n k = mod (binomial n k) n
--https://rosettacode.org/wiki/AKS_test_for_primes#Haskell

-- cycle through print mult x x == x

idempotents :: Ord a => [a] -> (a -> a -> a) -> [a]
idempotents elts mult = filter isSame elts
       where
        isSame x = mult x x == x


-- Examples:
-- Z2 Matrices | domain 2^{n*n}
-- Z3 matrices | domain 3^{n*n}
-- Life  | domain 2^{n*k}
-- EndoFactors | domain 2^{n+k}
--  Z_(k) +, * | domain n


-- Two concepts: Succinct representation of a single function, monogenic graph over a set of functions



--transMult :: [a] -> [a] -> [a]
--transMult x:xs ys =

endoThing x = endoscope [0..(x-1)] (mulX x)
idempThing x = idempotents [0..(x-1)] (mulX x)
leavesThing x = getLeaves [0..(x-1)] (mulX x)

--NEW IN OEIS?? Sum of orders of elements from the integers modulo n under multiplication
--map length $ map endoThing [1..50]

endoPolyThing x = endoscope (trans [0..(x-1)]) transMult

endoPermThing x =  endoscope (perm x) transMult
idempPermThing x = idempotents (perm x) transMult
leavesPermThing x = getLeaves (perm x) transMult

endoTransThing x =  endoscope (trans [0..(x-1)]) transMult
idempTransThing x = idempotents (trans [0..(x-1)]) transMult
transLeaves x = getLeaves (trans [0..(x-1)]) transMult

endoAddThing x = endoscope [0..(x-1)] (addX x)
idempAddThing x = idempotents [0..(x-1)] (addX x)
leavesAddThing x = getLeaves [0..(x-1)] (addX x)
--A057660
--map length $ map endoAddThing [1..50]


endoMMThing x = endoscope (matsZ2 x) mmult
idempMM x = idempotents (matsZ2 x) mmult
leavesMM x = getLeaves (matsZ2 x) mmult

--map length $ map endoMMThing [1..4]
--[2,23,1297,275083] not found in OEIS

endoMAddThing x =  endoscope (matsZ2 x) madd
idempMAddThing x = idempotents (matsZ2 x) madd
leavesMAddThing x = getLeaves (matsZ2 x) madd
--map length $ map endoMAddThing [1..4]
--[3,26,966,120836]


endoSetThing x = endoscope (map Set.fromList $ powset [1..x]) Set.union
endoSetIntersectThing x = endoscope (map Set.fromList $ powset [1..x]) Set.intersection
-- union mult op for all subsets of n
-- intersect mult op for all subsets of n
-- lexicographic max op for all subsets of n ?
-- symmetric difference mult op for all subsets of n ?
-- xor on boolean vectors of length n?



--Run it for 2 * order, 2*order + 1 see who gets hit more than once, first top count is entrypoint item
--histogram of index, period
--Count of relunctant functions
--Count of reluctant function leaves
--Count of permutation like functions
--Min covering set, in parallel for each connected component
--Min dom detection set = sum of min dom set size for each connected component

-- All k tuples, does union of all k dom sets cover G


--pairToList :: [([a],[a])] -> [[a]]
--pairToList l = concat $ map deTuple l

--      where
--        deTuple x = concat((fst x) (snd x))


--TODO:
--Print histogram of (index,period)
--Print count of reluctant functions
--Print count of cyclic functions
--Print count of connected components in function iteration graph. Does this equal idempotent count? Proof?
--Print size of min dom set on detection graph
--Print iteration graph
--Print detection graph
--Experiment if you mutliply from different connected components A,B does the result always end up in component C?
--Transfer matrix method to get generating function footprint of the iteration graph?

gvizpre :: String -> String
gvizpre name = "digraph " ++ name ++"{"

gvizpost = "}"
 --digraph graphname {
 --    a -> b -> c;
 --    b -> d;
-- }

--edgesToDot :: (Show a) => [(a,a)] -> String
edgesToDot :: Show a => [(a,a)] -> String
edgesToDot = concatMap pairToDot
       where
          pairToDot (i,j) = "   " ++ show i ++ "->" ++ show j ++ "; \n"


 --a [label="Foo"];
getNodeLabel :: (Show a, Show b) => (a,b) -> String
getNodeLabel (index, elt) = "   " ++ show index ++ " [label=\"" ++ show elt ++ "\"];\n"

getNodeLabels :: (Show a, Show b) => [(a,b)] -> String
getNodeLabels [] = ""
getNodeLabels [(i,elt)] = getNodeLabel (i,elt)
getNodeLabels (x:xs) = getNodeLabel x ++ getNodeLabels xs

zipIndex :: [a] -> [(Int,a)]
zipIndex [] = []
zipIndex xs = zip [0..(length xs)] xs

groupLengths = map getLen
       where
         getLen a = (length a, head a)


-- Also pass directory
-- genGraphs :: String -> Mult -> [Elt] ->() IO
genGraphs desc mult elts = do
                           let eltToInt = hash elts
                           let intToElt = rhash elts
                           
                           Process.system "mkdir -p kitchensink"
                           let fname = "kitchensink/" ++ desc ++ "MonoReachabilityGraph.gv"
                           writeFile  fname $ gvizpre "MonoReachabilityGraph"
                           appendFile fname $ getNodeLabels $ zipIndex elts
                           appendFile fname $ edgesToDot $ edges $ getMonoReachabilityGraph elts mult
                           appendFile fname gvizpost
                           -- Process.system $ "dot -Tpng " ++ fname ++ "  > kitchensink/" ++ desc ++ "MR.png"
                           let s1 = "kitchensink/" ++ desc ++ "MR"
                           jabber1 <- Process.readProcess "python" ["src/min_dom_z3.py",fname, s1] ""


                           let dname = "kitchensink/" ++ desc ++ "MonoDetectionGraph.gv"
                           writeFile  dname $ gvizpre "MonoDetectionGraph"
                           appendFile dname $ getNodeLabels $ zipIndex elts
                           appendFile dname $ edgesToDot $ edges $ getMonoDetectionGraph elts mult
                           appendFile dname gvizpost
                           -- Process.system $ "dot -Tpng " ++ dname ++ "  > znMultData/z" ++ desc ++ "MD.png"

                           let s2 = "kitchensink/" ++ desc ++ "MD"
                           jabber2 <- Process.readProcess "python" ["src/min_dom_z3.py",dname, s2] ""
                           

                           let qname = "kitchensink/" ++ desc ++ "MonoTransitionGraph.gv"
                           writeFile  qname $ gvizpre "MonoTransitionGraph"
                           appendFile qname $ getNodeLabels $ zipIndex elts
                           appendFile qname $ edgesToDot $ edges $ getMonoTransitionGraph elts mult
                           appendFile qname gvizpost
                           -- Process.system $ "dot -Tpng " ++ qname ++ "  > kitchensink/" ++ desc ++ "MT.png"
                           let s3 = "kitchensink/" ++ desc ++ "MT"
                           jabber3 <- Process.readProcess "python" ["src/min_dom_z3.py",qname, s3] ""


                           let q2name = "kitchensink/" ++ desc ++ "LeftTransitionGraph.gv"
                           writeFile  q2name $ gvizpre "LeftTransitionGraph"
                           appendFile q2name $ getNodeLabels $ zipIndex elts
                           appendFile q2name $ edgesToDot $ edges $ getLeftTransitionGraph elts mult
                           appendFile q2name gvizpost
                           -- Process.system $ "dot -Tpng " ++ qname ++ "  > kitchensink/" ++ desc ++ "MT.png"
                           let s4 = "kitchensink/" ++ desc ++ "LEFT_MT"
                           jabber4 <- Process.readProcess "python" ["src/min_dom_z3.py",q2name, s4] ""

                           let q3name = "kitchensink/" ++ desc ++ "RightTransitionGraph.gv"
                           writeFile  q3name $ gvizpre "RightTransitionGraph"
                           appendFile q3name $ getNodeLabels $ zipIndex elts
                           appendFile q3name $ edgesToDot $ edges $ getRightTransitionGraph elts mult
                           appendFile q3name gvizpost
                           -- Process.system $ "dot -Tpng " ++ qname ++ "  > kitchensink/" ++ desc ++ "MT.png"
                           let s5 = "kitchensink/" ++ desc ++ "Right_MT"
                           jabber5 <- Process.readProcess "python" ["src/min_dom_z3.py",q3name, s5] ""
                           

                           Process.system $ "echo " ++ desc ++ "," ++ jabber1 ++ "," ++ jabber2 ++ "," ++ jabber3 ++  "," 
                                ++ jabber4 ++  "," ++ jabber5 ++ " >> "++ "kitchensink/" ++ "min_doms.csv"
          


--Side effects
-- MR, MD, MT graphs
-- All of their stats
-- [(GraphData, GraphData, GraphData)]
-- ([Edges], [Edges], [Edges])
-- ([MinDomSize], [MinDomSize], [MinDomSize])
-- ([ConnectedComponents], [ConnectedComponents], [ConnectedComponents])
-- ([Girth], [Girth], [Girth])
-- ([MinColor], [MinColor], [MinColor]) ???

--labelznmult :: (Vertex,Vertex) -> (String, String)
--labelznmult (i,j) = (show i, show (i+777))

genZnMultGraphs n = do
                     Process.system "mkdir -p znMultData"
                     let fname = "znMultData/z" ++ show n ++ "MonoReachabilityGraph.gv"
                     writeFile  fname $ gvizpre "MonoReachabilityGraph"
                     appendFile fname $ getNodeLabels $ zipIndex [0..(n-1)]
                     appendFile fname $ edgesToDot $ edges $ getMonoReachabilityGraph [0..(n-1)] (mulX n)
                     appendFile fname gvizpost
                     Process.system $ "dot -Tpng " ++ fname ++ "  > znMultData/z" ++ show n ++ "MR.png"
                     let f = "znMultData/z" ++ show n ++ "MR"
                     jabber <- Process.readProcess "python" ["src/min_dom_z3.py",fname, f] ""
                     appendFile "znMultData/zMR.seq" jabber
                     --print jabber

                     let dname = "znMultData/z" ++ show n ++ "MonoDetectionGraph.gv"
                     writeFile  dname $ gvizpre "MonoDetectionGraph"
                     appendFile dname $ getNodeLabels $ zipIndex [0..(n-1)]
                     appendFile dname $ edgesToDot $ edges $ getMonoDetectionGraph [0..(n-1)] (mulX n)
                     appendFile dname gvizpost
                     Process.system $ "dot -Tpng " ++ dname ++ "  > znMultData/z" ++ show n ++ "MD.png"
                     let s = "znMultData/z" ++ show n ++ "MD"
                     jabber <- Process.readProcess "python" ["src/min_dom_z3.py",dname, s] ""
                     print jabber

                     let qname = "znMultData/z" ++ show n ++ "MonoTransitionGraph.gv"
                     writeFile  qname $ gvizpre "MonoTransitionGraph"
                     appendFile qname $ getNodeLabels $ zipIndex [0..(n-1)]
                     appendFile qname $ edgesToDot $ edges $ getMonoTransitionGraph [0..(n-1)] (mulX n)
                     appendFile qname gvizpost
                     Process.system $ "dot -Tpng " ++ qname ++ "  > znMultData/z" ++ show n ++ "MT.png"
                     let q = "znMultData/z" ++ show n ++ "MT"
                     jabber <- Process.readProcess "python" ["src/min_dom_z3.py",qname, q] ""
                     print jabber
--directory = BMMData

baz n = getNodeLabels $ zipIndex $ matsZ2 n
genBMMGraphs  n = do
                   let dname = "BMMData/" ++ show n ++ "MonoDetectionGraph.gv"
                   writeFile  dname $ gvizpre "MonoDetectionGraph"
                --  print $show $getNodeLabels $ zipIndex $ matsZ2 n
                   appendFile dname $ baz n
                   --Pass in a hashtable alias for the mult function?
                   appendFile dname $ edgesToDot $ edges $ getMonoDetectionGraph (matsZ2 n) mmult
                   appendFile dname gvizpost
                   Process.system $ "neato -Tpdf " ++ dname ++ "  > BMMData/" ++ show n ++ "MD.pdf"
                   let s = "BMMData/" ++ show n ++ "MD"
                   jabber <- Process.readProcess "python" ["src/min_dom_z3.py",dname, s] ""
                   print jabber
                   -- print "gen bmm graphs"


-- baz n = getNodeLabels $ zipIndex $ matsZ2 n
genBCloseGraphs  n = do
                   let dname = "BCloseData/" ++ show n ++ "MonoDetectionGraph.gv"
                   writeFile  dname $ gvizpre "MonoDetectionGraph"
                --  print $show $getNodeLabels $ zipIndex $ matsZ2 n
                   appendFile dname $ baz n
                   --Pass in a hashtable alias for the mult function?
                   appendFile dname $ edgesToDot $ edges $ getMonoDetectionGraph (matsZ2 n) mmultClose
                   appendFile dname gvizpost
                   Process.system $ "neato -Tpdf " ++ dname ++ "  > BCloseData/" ++ show n ++ "MD.pdf"
                   let s = "BCloseData/" ++ show n ++ "MD"
                   jabber <- Process.readProcess "python" ["src/min_dom_z3.py",dname, s] ""
                   print jabber
                   -- print "gen bclose graphs"                   


bazn n k = getNodeLabels $ zipIndex $ matsZn n k
genBMMGraphsn  n  k = do
                   let dname = "BMMData/" ++ show n ++ "_" ++ show k ++ "MonoDetectionGraph.gv"
                   writeFile  dname $ gvizpre "MonoDetectionGraph"
                --  print $show $getNodeLabels $ zipIndex $ matsZ2 n
                   appendFile dname (bazn n k)
                   --Pass in a hashtable alias for the mult function?
                   appendFile dname $ edgesToDot $ edges $ getMonoDetectionGraph (matsZn n k) $ mmultnc (toInteger k)
                   appendFile dname gvizpost
                   Process.system $ "neato -Tpdf " ++ dname ++ "  > BMMData/" ++ show n ++ "_" ++ show k ++ "MD.pdf"
                   let s = "BMMData/" ++ show n ++ "_" ++ show k ++ "MD"
                   jabber <- Process.readProcess "python" ["src/min_dom_z3.py",dname, s] ""
                   putStrLn jabber
                   -- print "gen bmmn graphs"


--Get (gengraphs n mult elts) working
--Get gengraphs to dump some data to in memory data structures like the min dom set sizes
--Make a printgraphinfo that prints the cached graph info for OEIS seqs.

-- vSomething :: (a -> b -> a) -> (Vertex -> Vertex -> Vertex)
-- vSomething z = unsafeCoerce z

endoMain = do
          --print $ allHistos [0..(12-1)] (mulX 12)

          --putStrLn $ latexTable "$Z_6^\\times$" [0..(6-1)] $ chunkRows 6 (mTable [0..(6-1)] (mulX 6))
          forM_ [1..11] $ \n -> genZnMultGraphs  n

          Process.system "mkdir -p BMMData"
          --writeFile "bmmData/bork.cork" "baz bar"

          Process.system "mkdir -p znMultData"
          Process.system "mkdir -p BCloseData"

          let fname = "znMultData/z12MonoReachabilityGraph.gv"
          writeFile  fname $ gvizpre "MonoReachabilityGraph"
          appendFile fname $ getNodeLabels $ zipIndex [0..(12-1)]
          appendFile fname $ edgesToDot $ edges $ getMonoReachabilityGraph [0..(12-1)] (mulX 12)
          appendFile fname gvizpost
          Process.system $ "dot -Tpng " ++ fname ++ "  > znMultData/z12MR.png"

          let dname = "znMultData/z12MonoDetectionGraph.gv"
          writeFile  dname $ gvizpre "MonoDetectionGraph"
          appendFile dname $ getNodeLabels $ zipIndex [0..(12-1)]
          appendFile dname $ edgesToDot $ edges $ getMonoDetectionGraph [0..(12-1)] (mulX 12)
          appendFile dname gvizpost
          Process.system $ "dot -Tpng " ++ dname ++ "  > znMultData/z12MD.png"
          --jabber <- Process.system $ "python min_dom_z3.py " ++ dname ++ " znMultData/z12MD"
          jabber <- Process.readProcess "python" ["src/min_dom_z3.py",dname,"znMultData/z12MD"] ""
          putStrLn "Min dom size"
          print jabber


          putStrLn "------"
          --




          -- s <- Process.readProcess "echo" ["6"] ""
          -- print s

          --Need to get feedback from python how big the min dom set is
          --Need to iterate this on all graphs up to a certain size

          -- putStrLn $ edgesToDot $ edges $ getMonoDetectionGraph [0..(12-1)] (mulX 12)


          --putStrLn $ edgesToDot $ edges $ getMonoTransitionGraph [0..(12-1)] (mulX 12)
          -- Graph from left mult edges
          -- Graph from right mult edges


          --System.Exit.exitSuccess
          print $  List.sortBy (flip compare)  $ groupLengths $ List.group $List.sort $ allCounts [0..(12-1)] (mulX 12)
          putStrLn ""

         --BMM SECTION---
          putStrLn "Edges in monogenic inclusion graph of MatMul on Z2, new sequence"
          print $ map (length . endoMMThing) [1..3]
          putStrLn "Idempotents in BMM, OEIS A086907 and OEIS A132186"
          print $ map (length . idempMM) [1..3]
          putStrLn "Leaves in BMM, ??"
          print $ map (length . leavesMM) [1..3]
          putStrLn ""

          --forM_ [1..3] $ \n -> genBMMGraphs  n
          putStrLn "Min Dom BMMn 1 *; https://oeis.org/A034444"
          genBMMGraphsn  1  1
          genBMMGraphsn  1  2
          genBMMGraphsn  1  3
          genBMMGraphsn  1  4
          genBMMGraphsn  1  5
          genBMMGraphsn  1  6
          genBMMGraphsn  1  7
          genBMMGraphsn  1  8
          genBMMGraphsn  1  9
          genBMMGraphsn  1  10
          genBMMGraphsn  1  11
          genBMMGraphsn  1  12
          genBMMGraphsn  1  13
          genBMMGraphsn  1  14
          genBMMGraphsn  1  15
          putStrLn "Min Dom BMMn 2 *; https://oeis.org/A226756"
          genBMMGraphsn  2  1 
          genBMMGraphsn  2  2 
          genBMMGraphsn  2  3 
          genBMMGraphsn  2  4
          --genBMMGraphsn  2  5
          --genBMMGraphsn  2  6
          putStrLn "Min Dom BMMn 3 *"
          genBMMGraphsn  3  1
          genBMMGraphsn  3  2 
          -- genBMMGraphsn  4  2 "802" (1258.67 secs, 6,541,096,536 bytes)
          
          putStrLn "Min Dom BClose" 
          genBCloseGraphs 2
          genBCloseGraphs 3
          -- genBCloseGraphs 4  "2360" (403.40 secs, 4,036,249,704 bytes)


          putStrLn "Edges in monogenic inclusion graph of co-MatMul on Z2, new sequence"
          print $ map (length . endoMAddThing) [1..3]
          putStrLn "Idempotents in coBMM, need the sixth term to narrow down candidates"
          print $ map (length . idempMAddThing) [1..3] -- 1,4,10,22,46...
          putStrLn "Leaves in coBMM, ?"
          print $ map (length . leavesMAddThing) [1..3]
          putStrLn ""

          putStrLn "Edges in monogenic inclusion graph of multiply on Zn, new sequence"
          print $ map (length . endoThing) [1..50]
          writeFile  "monoZnEdges.seq" $ show $ map (length . endoThing) [1..20]
          putStrLn "Idempotents in Zn under multiply, OEIS A034444"
          print $ map (length . idempThing) [1..50]
          putStrLn "Leaves of Zn under multiply, new sequence"
          print $ map (length . leavesThing ) [1..50]
          putStrLn ""

          putStrLn "Edges in Tn, new sequence"
          print $ map (length . endoTransThing) [1..6]
          writeFile  "tnEdges.seq" $ show $ map (length . endoTransThing) [1..6]
          putStrLn "Idempotents in Tn, OEIS A000248"
          print $ map (length . idempTransThing) [1..6]
          writeFile  "tnIdempotents.seq" $ show $ map (length . idempTransThing) [1..6]
          putStrLn "Leaves of Tn, new seqence"
          print $ map (length.transLeaves) [1..5] -- [1,3,15,138,1720,27180]
          writeFile  "tnLeaves.seq" $ show $ map (length.transLeaves) [1..5]

          print $ map transLeaves [1..3]
          print $ trans [0..(1-1)]
          print $ trans [0..(2-1)]
          print $ trans [0..(3-1)]
          putStrLn ""
          
          --giterdone a = unsafeCoerce a :: [Vertex]
          genGraphs "bork"  transMult  (trans [0..(3-1)])
         -- genGraphs "desc" transMult  (perm 2)
          --(perm x) transMult


          putStrLn "Edges in Sn, OEIS A060014"
          print $ map (length . endoPermThing) [1..6]
          putStrLn "Idempotents in Sn, only the identity function"
          print $ map (length . idempPermThing) [1..6]
          putStrLn "Leaves in Sn, ???"
          print $ map (length . leavesPermThing) [1..6]
          putStrLn ""

          putStrLn "Edges in monogenic inclusion graph of add on Zn, OEIS A057660"
          print $ map (length . endoAddThing) [1..50]
          putStrLn "Idempotents of add on Zn, just zero"
          print $ map (length . idempAddThing) [1..50]
          putStrLn "Leaves of add on Zn, ???"
          print $ map (length . idempAddThing) [1..50]
          writeFile  "transpoly.seq" $ show (map a058067  [0..5])
          --print "Edges in monogenic inclusion graph of Powerset under union"
          --print $ map length $ map endoSetThing [1..5]
          --print "Edges in monogenic inclusion graph of Powerset under intersection"
          --print $ map length $ map endoSetIntersectThing [1..5]
--mono :: Ord a => (a -> a -> a) -> (a,a) -> Set a -> Set a
--mono mult (primal,current) accum

   -- print $ components $ endoscope (3*3) mul7
