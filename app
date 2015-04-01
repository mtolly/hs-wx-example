#!/bin/bash
set -e
set -u

cabal build
cp dist/build/wxtest/wxtest wxtest
strip wxtest
.cabal-sandbox/bin/macosx-app wxtest
rm wxtest
dylibbundler -x wxtest.app/Contents/MacOS/wxtest -b -d wxtest.app/Contents/libs/ -p "@executable_path/../libs/" -of -od
