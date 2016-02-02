--With @gbgames during GDRC2015
import Data.List

add :: Integer -> Integer -> Integer
add a b = a+b

alive = True
dead = False
type IsAlive = Bool
type Long = Integer
type Lat = Integer
type Cell = (Lat, Long, IsAlive)
type World = [Cell]
type Neighbors = Integer


isAlive :: Neighbors -> IsAlive -> IsAlive
isAlive n a | n==2 && not a = dead
            | n ==2 && a  = alive
            | n < 2 = dead
            | n==3 = alive
            | n>3 = dead
            |otherwise = dead


getNeighbors :: (Integer,Integer) -> Cell -> [Cell]
getNeighbors (w,h) (x,y,a) = [ (mod (x+1) w , mod (y+1) h, True),
                         (mod (x+1) w, mod (y-1) h, True),
                          (mod (x-1) w, mod (y+1) h, True),
                          (mod (x+1) w, y, True),
                          (mod (x-1) w, mod (y-1) h, True),
                          (x, mod (y-1) h, True),
                          (x, mod (y+1) h, True),
                          (mod (x-1) w, y, True)]
type AliveNeighbors = [Cell]
type AliveCells = [Cell]

getAllStillAlive :: AliveNeighbors -> AliveCells -> AliveCells
getAllStillAlive [] [] = []
getAllStillAlive (a:as) [] = []
--getAllStillAlive  x (y:ys) = []
--getAllStilAlive (a:as) (y:ys) = []
getAllStillAlive (a:as) (y:ys) = if isAlive (count (a:as) y) True 
                              then y : getAllStillAlive (a:as) ys 
                              else getAllStillAlive (a:as) ys 


getNewAlive :: AliveNeighbors -> AliveNeighbors -> AliveCells
getNewAlive [] _ = []
getNewAlive (x:xs) y = if isAlive (count y x) False then x : getNewAlive xs y else getNewAlive xs y


cellMatch :: Cell -> Cell -> Bool
cellMatch (x,y, _) (a,b, _) = (x==a) && (y==b)


uniqCells = nubBy cellMatch 

type CellCount = Integer
count :: [Cell] -> Cell -> CellCount
count [] _ = 0
count (x:xs) c | cellMatch x c = 1+ count xs c
                |otherwise = count xs c


getAllNeighbors :: (Integer, Integer) -> [Cell] -> [Cell]
getAllNeighbors (w,h) = foldr ((++) . (getNeighbors (w,h)) ) []

life :: (Integer, Integer) -> World -> World
life _ [] = []
life (w,h) x =  uniqCells $ getAllStillAlive (getAllNeighbors (w,h) x ) x ++ getNewAlive (getAllNeighbors (w,h) x ) (getAllNeighbors (w,h) x ) 
   


