-- | Benchmarks for SkipList.
--
-- We have two types of benchmarks.
-- 1/ The performance of @SkipList@ lookup compared to regular
--    list lookup (i.e. @!!@). Note that @SkipList@ gets /amortized/
--    good performance, so we need to test a lot of accesses in order
--    to see the benefit.
-- 2/ The performance of skip lists with different quantizations.
--    This tries to find the optimal quantization to balance indexing
--    with the added complexity of the @SkipList@ indexing structure.
--
module Main where

import           Criterion.Main
import qualified Data.SkipList  as SL

main = defaultMain
       [ -- Compare SkipList indexing with list indexing.
         env (pure big) $ \ big -> bgroup "all"
         [ bench "!!" $ whnf (go id (!!)) big
         , bench "SkipList<16>" $
           whnf (go (SL.toSkipList 16) SL.lookup) big ]
       , -- Compare different SkipList quantizations
         -- NOTE: This benchmarks to find a good tradeoff between
         -- memory usage and indexing size.
         env (pure big) $ \ big -> bgroup "Quantities"
         [ bench ("SkipList<" ++ show i ++ ">") $
           whnf (go (SL.toSkipList i) SL.lookup) big
         | i <- [2,4,8,16,32,64] ]
       ]
    where
      big = [0..1000]

      go make get big = big == (get sl <$> big)
          where sl = make big
