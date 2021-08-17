-- This Happy file was machine-generated by the BNF converter
{
{-# OPTIONS_GHC -fno-warn-incomplete-patterns -fno-warn-overlapping-patterns #-}
{-# LANGUAGE PatternSynonyms #-}

module Lambda.Par
  ( happyError
  , myLexer
  , pTerm
  ) where

import Prelude

import qualified Lambda.Abs
import Lambda.Lex

}

%name pTerm Term
-- no lexer declaration
%monad { Err } { (>>=) } { return }
%tokentype {Token}
%token
  '('      { PT _ (TS _ 1) }
  ')'      { PT _ (TS _ 2) }
  '.'      { PT _ (TS _ 3) }
  'lambda' { PT _ (TS _ 4) }
  L_Ident  { PT _ (TV $$)  }

%%

Ident :: { Lambda.Abs.Ident }
Ident  : L_Ident { Lambda.Abs.Ident $1 }

Term :: { Lambda.Abs.Term }
Term
  : Ident { Lambda.Abs.TmVar $1 }
  | '(' 'lambda' Ident '.' Term ')' { Lambda.Abs.TmAbs $3 $5 }
  | Term Term { Lambda.Abs.TmApp $1 $2 }

{

type Err = Either String

happyError :: [Token] -> Err a
happyError ts = Left $
  "syntax error at " ++ tokenPos ts ++
  case ts of
    []      -> []
    [Err _] -> " due to lexer error"
    t:_     -> " before `" ++ (prToken t) ++ "'"

myLexer :: String -> [Token]
myLexer = tokens

}

