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
    , WX.visible := False
    ]

  file <- WX.menuPane [WX.text := "&File"]
  _ <- WX.menuQuit file [WX.help := "Quit the demo", on WX.command := WX.close frame]
  help <- WX.menuHelp []
  about <- WX.menuAbout help [WX.help := "About OnyxBuild"]
  set frame
    [ WX.menuBar := [file, help]
    , on (WX.menu about) :=
      WX.infoDialog frame "About OnyxBuild" "This will be something eventually!"
    ]

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
  set frame
    [ WX.layout := WX.label title
    , WX.visible := True
    ]
