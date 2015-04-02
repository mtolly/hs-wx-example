{-# LANGUAGE OverloadedStrings #-}
module Main where

import qualified Graphics.UI.WX as WX
import qualified Graphics.UI.WXCore as WXC
import Graphics.UI.WX (set, on, Prop((:=)))
import qualified Data.Yaml as Y
import Data.Yaml ((.:))
import Data.Maybe (fromMaybe)

main :: IO ()
main = WX.start hello

hello :: IO ()
hello = do
  WXC.wxcAppSetAppName "OnyxBuild"
  frame <- WX.frame
    [ WX.text := "OnyxBuild"
    , WX.resizeable := False
    ]
  text <- WX.staticText frame [WX.text := "No file opened."]
  set frame
    [ WX.layout := WX.margin 10 $ WX.widget text
    ]
  let loadFile fp = do
        title <- Y.decodeFileEither fp >>= \res -> return $ case res of
          Left _ -> "Not a valid YAML object"
          Right obj -> fromMaybe "No title" $ Y.parseMaybe (.: "title") obj
        set text [WX.text := title]
        WX.refitMinimal frame
  WXC.fileDropTarget frame $ \_ fps -> case fps of
    fp : _ -> loadFile fp
    []     -> return ()
  file <- WX.menuPane [WX.text := "&File"]
  _ <- WX.menuItem file
    [ WX.text := "&Open…\tCtrl+O"
    , on WX.command := do
        mfp <- WX.fileOpenDialog frame
          True -- rememberCurrentDir
          True -- allowReadOnly
          "Open a YAML file" -- message
          [("OnyxBuild YAML file", ["*.yml"])] -- wildcards
          "" -- directory
          "" -- filename
        case mfp of
          Just fp -> loadFile fp
          Nothing -> return ()
    ]
  _ <- WX.menuQuit file [on WX.command := WX.close frame]
  help <- WX.menuHelp []
  _ <- WX.menuAbout help
    [ on WX.command := do
      WX.infoDialog frame "About OnyxBuild" "This will be something eventually!"
    ]
  set frame
    [ WX.menuBar := [file, help]
    ]
