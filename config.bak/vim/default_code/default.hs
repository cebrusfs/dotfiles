{-# LANGUAGE LambdaCase, NPlusKPatterns, TupleSections #-}
{-# OPTIONS_GHC -Wall -fno-warn-unused-imports -fno-warn-missing-signatures -fno-warn-unused-binds #-}
-- import {{{
import Control.Applicative
import Control.Arrow
import Control.Exception
import Control.Monad
import Control.Monad.ST

import Data.Array
import Data.Bits
import Data.Char
import Data.Either
import Data.Function
import Data.IORef
import Data.List
import Data.Maybe
import Data.Monoid
import Data.Ord
import Data.STRef
import Data.String
import Data.Tuple


import qualified Data.Array.Unboxed as UArray
import qualified Data.Graph as Graph
import qualified Data.Tree as Tree
import qualified Data.Map as Map
import qualified Data.Set as Set
import qualified Data.Sequence as Seq
import qualified Data.Text as Text

import Data.Array.Unboxed (UArray)
import Data.Graph (Graph)
import Data.Tree (Tree, Forest)
import Data.Map (Map)
import Data.Set (Set)
import Data.Sequence (Seq, (<|), (|>), (><))
import Data.Text (Text)

import Debug.Trace
import Text.Printf
-- }}}
-- silly utilities {{{
(#) = flip ($)
infixl 0 #

glength :: (Num b) => [a] -> b
glength = genericLength

(!>) :: Seq a -> Int -> a
(!>) = Seq.index
-- }}}
-- input and output {{{
inputInt     = (read <$> getLine) :: IO Int
inputInteger = (read <$> getLine) :: IO Integer
inputDouble  = (read <$> getLine) :: IO Double

inputRow :: (Read a) => IO [a]
inputRow = map read . words <$> getLine
inputInts     = inputRow :: IO [Int]
inputIntegers = inputRow :: IO [Integer]
inputDoubles  = inputRow :: IO [Double]
-- }}}
-- Math Theory {{{
makePrimes ::  (Ix a, Integral a) => a -> [a]
makePrimes m = 2 : sieve 3 odd_ary where
    odd_ary = UArray.array (3, m) [(i, odd i) | i <- [3 .. m]]
    sieve p ary
        | p * p > m = [i | (i, True) <- assocs ary]
        | ary ! p   = sieve (p+2) $ ary // [(i,False) | i <- [p*p, p*p+2*p .. m]]
        | otherwise = sieve (p+2) ary

flatFactor ::  Integral a => [a] -> a -> [a]
flatFactor ps n
    | n <= 1 = []
    | otherwise = p : flatFactor ps' (n `div` p)
    where
        ps' = dropWhile ((/= 0) . mod n) ps
        p = if null ps' then n else head ps'

factor ::  (Integral a, Integral a') => [a] -> a -> [(a, a')]
factor ps n
    | n <= 0 = []
    | otherwise = map (head &&& glength) $ group $ flatFactor ps n

numOfDivisor ps = product . map ((+1) . snd) . factor ps

sumOfDivisor ps = product . map cal . factor ps where
    cal :: Integral a => (a, a) -> a
    cal (p, m) = (p^(m + 1) - 1) `div` (p - 1)
-- }}}
-- StringTool {{{
toBase ::  Integral a => a -> a -> String
toBase b n
    | b < 2 || b > 16 = error "toBase: the base must be 2 .. 16"
    | n >= 0          = ans
    | otherwise       = '-' : ans
    where
        ans = toBase' [] (abs n) :: String
        toDigit = intToDigit . fromIntegral
        toBase' xs 0 = xs
        toBase' xs val = toBase' (toDigit (val `mod` b):xs) (val `div` b)

readInt     = read :: String -> Int
readInteger = read :: String -> Integer
-- }}}
-- BasicAlgorithm {{{
unique :: Ord a => [a] -> [a]
unique = map head . group . sort

histogram :: (Ord a, Num b) => [a] -> Map a b
histogram = Map.fromListWith (+) . map (,1)
-- }}}

main :: IO ()
main = return ()
