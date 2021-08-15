-- Program to test parser, automatically generated by BNF Converter.

module Lambda.Test where

import           Control.Monad                  ( when )
import           Prelude                        ( ($)
                                                , (++)
                                                , (.)
                                                , (>)
                                                , (>>)
                                                , (>>=)
                                                , Either(..)
                                                , FilePath
                                                , IO
                                                , Int
                                                , Show
                                                , String
                                                , concat
                                                , getContents
                                                , mapM_
                                                , putStrLn
                                                , readFile
                                                , show
                                                , unlines
                                                )
import           System.Environment             ( getArgs )
import           System.Exit                    ( exitFailure
                                                , exitSuccess
                                                )

import           Lambda.Abs                     ( )
import           Lambda.Lex                     ( Token
                                                , mkPosToken
                                                )
import           Lambda.Par                     ( myLexer
                                                , pExp
                                                )
import           Lambda.Print                   ( Print
                                                , printTree
                                                )
import           Lambda.Skel                    ( )

type Err = Either String
type ParseFun a = [Token] -> Err a
type Verbosity = Int

putStrV :: Verbosity -> String -> IO ()
putStrV v s = when (v > 1) $ putStrLn s

runFile :: (Print a, Show a) => Verbosity -> ParseFun a -> FilePath -> IO ()
runFile v p f = putStrLn f >> readFile f >>= run v p

run :: (Print a, Show a) => Verbosity -> ParseFun a -> String -> IO ()
run v p s = case p ts of
  Left err -> do
    putStrLn "\nParse              Failed...\n"
    putStrV v "Tokens:"
    mapM_ (putStrV v . showPosToken . mkPosToken) ts
    putStrLn err
    exitFailure
  Right tree -> do
    putStrLn "\nParse Successful!"
    showTree v tree
    exitSuccess
 where
  ts = myLexer s
  showPosToken ((l, c), t) = concat [show l, ":", show c, "\t", show t]

showTree :: (Show a, Print a) => Int -> a -> IO ()
showTree v tree = do
  putStrV v $ "\n[Abstract Syntax]\n\n" ++ show tree
  putStrV v $ "\n[Linearized tree]\n\n" ++ printTree tree

usage :: IO ()
usage = do
  putStrLn $ unlines
    [ "usage: Call with one of the following argument combinations:"
    , "  --help          Display this help message."
    , "  (no arguments)  Parse stdin verbosely."
    , "  (files)         Parse content of files verbosely."
    , "  -s (files)      Silent mode. Parse content of files silently."
    ]
  exitFailure

main :: IO ()
main = do
  args <- getArgs
  case args of
    ["--help"] -> usage
    []         -> getContents >>= run 2 pExp
    "-s" : fs  -> mapM_ (runFile 0 pExp) fs
    fs         -> mapM_ (runFile 2 pExp) fs

