{-# LANGUAGE RankNTypes #-}
module Data.SkipList
     ( SkipList
     , toSkipList
     , lookup )
where

import Prelude hiding (lookup)

import Debug.Trace (trace)
import Data.List (intercalate)

data SkipList' a =
  SkipList' ![a] (SkipList' (SkipList' a))

-- | SkipLists are lists that support (semi-)efficient indexing.
data SkipList a = SkipList !Int !(SkipList' a)

instance Foldable SkipList where
  foldMap f (SkipList _ (SkipList' ls _)) = foldMap f ls

-- | Convert a list to a @SkipList@.
toSkipList :: Int -> [a] -> SkipList a
toSkipList quant = SkipList quant . toSkipList' quant

-- | Build the infinite tree of skips.
toSkipList' :: Int -> [a] -> SkipList' a
toSkipList' quant ls
  | quant > 1 =
    let self = SkipList' ls $ toSkipList' quant (self : (toSkipList' quant <$> fastTails ls)) in self
  | otherwise = error "Can not make SkipList with quantization <= 1"
  where
    fastTails ls = dropped : fastTails dropped
      where dropped = drop quant ls

-- | Lookup in a @SkipList@.
lookup :: SkipList a -> Int -> a
lookup (SkipList q (SkipList' ls z)) i
  | i >= q = get q (\ (SkipList' a _) i -> a !! i) z i
  | otherwise = ls !! i
  where
    get :: forall a b. Int -> (b -> Int -> a) -> SkipList' b -> Int -> a
    get m k (SkipList' here next) i
      | i >= q * m = get (q*m) (get m k) next i
      | otherwise  = k (here !! idx) rest
      where idx  = i `div` m
            rest = i `mod` m
