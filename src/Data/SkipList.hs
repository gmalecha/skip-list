{-# LANGUAGE RankNTypes #-}
-- | @SkipList@s are comprised of a list and an index on top of it
-- which makes deep indexing into the list more efficient (O(log n)).
-- They achieve this by essentially memoizing the @tail@ function to
-- create a balanced tree.
module Data.SkipList
     ( SkipList
     , toSkipList
     , lookup )
where

import Prelude hiding (lookup)

-- | A SkipIndex stores "pointers" into the tail of a list for efficient
-- deep indexing. If you have
--   SkipIndex ls i
-- and the quantization is `q` then the elements of `q` are "pointers"
-- into every `q`th tail of the list. For example, if `q` = 2 and
-- `ls = [1,2,3,4,5,6,7]`, then the frist level of `i` contains:
--   [1,2,3,4,5,6,7], [3,4,5,6,7], [5,6,7], [7]
-- the next level of `i` conceptually contains:
--   [1,2,3,4,5,6,7], [5,6,7]
-- Note however, that these are not lists, but rather references to
-- @SkipIndex@s from `i`
data SkipIndex a =
  SkipIndex ![a] (SkipIndex (SkipIndex a))

-- | SkipLists are lists that support (semi-)efficient indexing.
data SkipList a = SkipList !Int !(SkipIndex a)

instance Functor SkipList where
  fmap f (SkipList q (SkipIndex raw _)) = toSkipList q $ f <$> raw

instance Foldable SkipList where
  foldMap f (SkipList _ (SkipIndex ls _)) = foldMap f ls

-- | Convert a list to a @SkipList@.
toSkipList :: Int -> [a] -> SkipList a
toSkipList quant = SkipList quant . toSkipIndex quant

-- | Build the infinite tree of skips.
toSkipIndex :: Int -> [a] -> SkipIndex a
toSkipIndex quant
  | quant > 1 = \ ls ->
    let self = SkipIndex ls $ toSkipIndex quant (self : rest)
        rest = toSkipIndex quant <$> fastTails ls
    in self
  | otherwise = error "Can not make SkipList with quantization <= 1"
  where
    fastTails ls = dropped : fastTails dropped
      where dropped = drop quant ls

-- | Lookup in a @SkipList@.
lookup :: SkipList a -> Int -> a
lookup (SkipList q (SkipIndex ls index)) i
  | i >= q    = get q q (\ (SkipIndex a _) -> (!!) a) index i
  | otherwise = ls !! i

-- | Get an element from a @SkipIndex@.
get :: Int             -- ^ The step increment in the index
    -> Int             -- ^ The current step size
    -> (b -> Int -> a) -- ^ Continuation to call with the result
    -> SkipIndex b     -- ^ The index to look in
    -> Int             -- ^ The position to look for
    -> a
get q stepSize kont (SkipIndex here next) n
  | n >= q * stepSize =
    get q (q*stepSize) (get q stepSize kont) next n
  | otherwise  = kont (here !! idx) rest
  where idx  = n `div` stepSize
        rest = n `mod` stepSize
