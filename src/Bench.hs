{-# LANGUAGE ForeignFunctionInterface #-}
-- module Bench where

import Criterion.Main
import MatMul
import Endoscope
import Data.Bits
import Data.List

import Foreign
import Foreign.C.Types


import qualified Data.Vector.Storable as V
import qualified Data.Vector.Storable.Mutable as VM


foreign import ccall unsafe "domultpacked"
     c_mult_packed :: Int -> IO ()

foreign import ccall unsafe "domultunpacked"
     c_mult_unpacked :: Int -> IO ()

foreign import ccall unsafe "matrix_mul_gf2"
     c_mulgf2 :: Ptr a -> Ptr b -> Ptr c -> IO ()

foreign import ccall unsafe "matmul_basicgf2"
     c_mulgf2basic ::  Ptr a -> Ptr b -> Ptr c -> IO ()

foreign import ccall safe "setfront" 
     setfront :: Ptr a -> CInt-> IO ()
doset  a = do
 let vs = V.fromList ([1,2,3] :: [CInt])
 v <- V.thaw vs
 VM.unsafeWith v $ \ptr -> do
    setfront ptr 23
 out <- V.freeze v
 print out

do_cpacked a = c_mult_packed

do_cunpacked a = c_mult_unpacked


-- import qualified Data.Set as Set

--toPacked :: [[a]] -> [Int]
toPacked rows = map packRow rows
      
packRow x = sum $ map shiftTup  $ zip x [0..] 
shiftTup (a,b) = shift a b

toPackedTup a = (toPacked a, toPacked $ transpose a)

       
packedMats x = map toPackedTup $ matsZ2 x


packedRowMult arow bcol = (.&.) 1 $ popCount $ (.&.) arow bcol

-- Recheck these vals....
-- transpose A*B = transpose B * transpose A    
packedTupMult (ar,art) (br, brt) = (toPacked $ [ [packedRowMult a b  | b <- brt ] | a <- ar ], 
      toPacked $ [ [packedRowMult a b  | b <- art ] | a <- br ])

takeNum = 5000

matList3 = matsZ2 3
cProd elts mf =  [ mf x y | x <- elts, y <- elts]

regmult x = length $ cProd (take takeNum (matsZ2 x)) mmult

imult x = length $ cProd [0..(takeNum)] (*)

pmult x = length $ cProd (take takeNum $ packedMats x) packedTupMult

-- Our benchmark harness.
main =
       defaultMain [
       bgroup "cmult" [ bench "packed" $ whnf do_cpacked 3
         , bench "unpacked" $ whnf do_cunpacked 3
         , bench "doset" $ whnf doset 3],


       bgroup "intmul" [ bench "3" $ whnf imult 3
       --, bench "4" $ whnf imult 4
               ],
       bgroup "matmul" [ bench "3" $ whnf regmult 3 
       --, bench "4" $ whnf regmult 4
               ],
       bgroup "packmul" [ bench "3" $ whnf pmult 3 
       --, bench "4" $ whnf pmult 4
       ]
               --,

       -- bgroup "trans endoscope " [ bench "2" $ whnf endoTransThing 2,
       --           bench "3" $ whnf endoTransThing 3
       --           ,bench "4" $ whnf endoTransThing 4
       --         ],
       -- bgroup "perm endoscope" [ bench "2" $ whnf endoPermThing 2,
       --           bench "3" $ whnf endoPermThing 3
       --           ,bench "4" $ whnf endoPermThing 4
       --         ]


  ]
