.PHONY: default

default:
	rm -rf wxtest.app/Contents/libs/*.dylib
	stack build
	cp $(shell stack exec which wxtest) wxtest.app/Contents/MacOS/
	dylibbundler -cd -of -b -x wxtest.app/Contents/MacOS/wxtest -d wxtest.app/Contents/libs/
