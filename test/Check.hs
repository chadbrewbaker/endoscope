module Main where

import Test.QuickCheck
import MatMul

idMat :: [[Integer]]
idMat =[[1,0], 
       [0, 1]]
 
fibMat = [[1, 1],
       [1, 0]]
 

prop_id_mult_comm (Positive x) = mmult [[x,x],[x,x]] idMat == mmult idMat [[x,x],[x,x]]



main = quickCheck prop_id_mult_comm
