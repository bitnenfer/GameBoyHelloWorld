@echo off 

echo Assembling...
tools\rgbds\rgbasm.exe -o main.o main.asm
echo Linking...
tools\rgbds\rgblink.exe -o hello.gb main.o
echo Fixing Checksum...
tools\rgbds\rgbfix.exe -p0 -v hello.gb
