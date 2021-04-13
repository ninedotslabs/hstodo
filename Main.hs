{-# LANGUAGE LambdaCase #-}

import Data.List (delete)
import Data.Maybe (fromJust)
import System.Directory (removeFile, renameFile)
import System.Environment (getArgs)
import System.IO
  ( IOMode (ReadMode),
    hClose,
    hGetContents,
    hPutStr,
    openFile,
    openTempFile,
  )

type Param = [Char]

type Params = [Param]

type Command = [[Char]] -> IO ()

type Task = [Char]

type Tasks = [Task]

appName :: [Char]
appName = "Haskell TODO"

appVersion :: [Char]
appVersion = "Version: 0.1.0"

authorName :: [Char]
authorName = "Alfian Hidayat"

dispatch :: Param -> Command
dispatch cmd = case cmd of
  "add" -> add
  "view" -> view
  "remove" -> remove
  _ -> help

reduceArgs :: Params -> IO ()
reduceArgs (command : args) = dispatch command args
reduceArgs _ = help []

main :: IO ()
main = getArgs >>= reduceArgs

add :: Command
add [fileName, todoItem] = appendFile fileName (todoItem ++ "\n")

view :: Command
view [fileName] = readFile fileName >>= mapM_ putStrLn . zipWith (\n line -> show n ++ " - " ++ line) [0 ..] . lines

remove :: Command
remove [fileName, numberString] =
  openFile fileName ReadMode >>= \handle ->
    openTempFile "." "temp" >>= \(tempName, tempHandle) ->
      hGetContents handle >>= \contents ->
        hPutStr
          tempHandle
          ( unlines $
              delete (lines contents !! read numberString) (lines contents)
          )
          >> hClose handle
          >> hClose tempHandle
          >> removeFile fileName
          >> renameFile tempName fileName

help :: Command
help _ =
  putStrLn appName
    >> putStrLn appVersion
    >> putStrLn ("Author: " ++ authorName ++ "\n")
    >> putStrLn "Usage : "
    >> putStrLn "\n add todo.txt \"Swimming\""
    >> putStrLn "\n view todo.txt"
    >> putStrLn "\n remove todo.txt 1"
