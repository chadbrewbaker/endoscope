
module Main where

import Criterion.Main
import MatMul 

idMat :: [[Integer]]
idMat =[[1,0], 
       [0, 1]]

fibMat :: [[Integer]] 
fibMat = [[1, 1],
       [1, 0]]

main = defaultMain [
  bgroup "factorial" [ bench "2" $ whnf matmul idMat fibMat
  					 , bench "16" $ whnf matmul idMat fibMat
  					 , bench "32" $ whnf matmul idMat fibMat
  					 , bench "200" $ whnf matmul idMat fibMat
  					 , bench "5000" $ whnf matmul idMat fibMat
  					 ]
  ]
