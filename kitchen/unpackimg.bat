@echo off
set CYGWIN=nodosfilewarning
set hideErrors=n

%~d0
cd "%~p0"
if "%~1" == "" goto noargs
set "file=%~f1"
set bin=..\android_win_tools
set "errout= "
if "%hideErrors%" == "y" set "errout=2>nul"

rem Android Image Kitchen - UnpackImg Script
rem by osm0sis @ xda-developers
rem.

rem Supplied image: %~nx1
rem.

if exist split_img\nul set "noclean=1"
if exist ramdisk\nul set "noclean=1"
if not "%noclean%" == "1" goto noclean
rem Removing old work folders and files . . .
rem.
call cleanup.bat

:noclean
rem Setting up work folders . . .
rem.
md split_img
md ramdisk

rem Splitting image to "/split_img/" . . .
rem.
cd split_img
%bin%\unpackbootimg -i "%file%" > nul
if errorlevel == 1 call "%~p0\cleanup.bat" & goto error
rem.
%bin%\file -m %bin%\magic *-ramdisk.gz %errout% | %bin%\cut -d: -f2 %errout% | %bin%\cut -d" " -f2 %errout% > "%~nx1-ramdiskcomp"
for /f "delims=" %%a in ('type "%~nx1-ramdiskcomp"') do @set ramdiskcomp=%%a
if "%ramdiskcomp%" == "gzip" set "unpackcmd=gzip -dc" & set "compext=gz"
set "extra= "
ren *ramdisk.gz *ramdisk.cpio.%compext%
cd ..

rem Unpacking ramdisk to "/ramdisk/" . . .
rem.
cd ramdisk
rem Compression used: %ramdiskcomp%
if "%compext%" == "" goto error
%bin%\%unpackcmd% "../split_img/%~nx1-ramdisk.cpio.%compext%" %extra% %errout% | %bin%\cpio -i %errout% 2>nul
if errorlevel == 1 goto error
rem.
cd ..

rem Done!
goto end

:noargs
rem No image file supplied.

:error
rem Error!

:end
rem.
