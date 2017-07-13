module Main where

import Control.Monad

import Data.SkipList as SL

import Test.Tasty
import Test.Tasty.HUnit

allTests = testGroup "SkipList"
  [ testCase "[1..]@2" $ testSkipList 2 [0..100] [1..]
  , testCase "[1..]@3" $ testSkipList 3 [0..100] [1..]
  , testCase "[1..]@10" $ testSkipList 10 [0..1000] [1..]
  , testCase "[1..100]@10" $ testSkipList 10 [0..99] [1..100]
  ]

testSkipList :: (Eq a, Show a) => Int -> [Int] -> [a] -> Assertion
testSkipList quant is lst = do
  forM_ is $ \ i ->
    assertEqual (msg i) (lst !! i) (sl `SL.lookup` i)
  where
    msg i = "[" ++ show i ++ "]"
    sl = SL.toSkipList quant lst

main :: IO ()
main = defaultMain allTests
