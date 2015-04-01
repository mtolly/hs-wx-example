{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Graphics.UI.WX as WX
import Graphics.UI.WX (set, on, Prop((:=)))
import qualified Data.Yaml as Y
import Data.Yaml ((.:))
import Data.Maybe (fromMaybe)

main :: IO ()
main = WX.start hello

hello :: IO ()
hello = do
  frame <- WX.frame
    [ WX.text := "OnyxBuild"
    , WX.resizeable := False
    ]
  text <- WX.staticText frame [WX.text := "No file opened."]
  set frame
    [ WX.layout := WX.margin 10 $ WX.widget text
    ]
  file <- WX.menuPane [WX.text := "&File"]
  _ <- WX.menuItem file
    [ WX.text := "&Open\tCtrl+O"
    , on WX.command := do
        mfp <- WX.fileOpenDialog frame
          True
          True
          "Open a YAML file"
          [("OnyxBuild YAML file", ["*.yml"])]
          ""
          ""
        title <- case mfp of
          Just fp -> Y.decodeFile fp >>= \res -> return $ case res of
            Nothing  -> "Not a valid YAML object"
            Just obj -> fromMaybe "No title" $ Y.parseMaybe (.: "title") obj
          Nothing -> return "File dialog closed"
        set text [WX.text := title]
        WX.refitMinimal frame
    ]
  _ <- WX.menuQuit file [on WX.command := WX.close frame]
  help <- WX.menuHelp []
  about <- WX.menuAbout help [WX.help := "About OnyxBuild"]
  set frame
    [ WX.menuBar := [file, help]
    , on (WX.menu about) :=
      WX.infoDialog frame "About OnyxBuild" "This will be something eventually!"
    ]
