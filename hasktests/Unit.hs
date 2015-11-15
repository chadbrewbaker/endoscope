module Main where

import Test.HUnit
import MatMul 

factorial 0 = 1
factorial 1 = 1
factorial 2 = 2
factorial a = a * factorial (a-1)

testFiveFactorial = TestCase $ assertEqual 
  "Testing 5!"
  (1*2*3*4*5) 
  (factorial 5) 

--test size stays same
idMat :: [[Integer]]
idMat =[[1,0], 
       [0, 1]]

fibMat :: [[Integer]] 
fibMat = [[1, 1],
       [1, 0]]
 
testMatMulGivesCorrectSize = TestCase $ assertEqual
  "Testing matmul returns propper dimension"
  (length (mmult idMat idMat))
  2

main = runTestTT $ TestList[
	testFiveFactorial,
	testMatMulGivesCorrectSize
	]


