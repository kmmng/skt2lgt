@echo off
set CYGWIN=nodosfilewarning
set hideErrors=n

cd "%~p0"
if not exist split_img\nul goto nofiles
if not exist ramdisk\nul goto nofiles
set bin=android_win_tools
set "errout= "
if "%hideErrors%" == "y" set "errout=2>nul"

rem Android Image Kitchen - RepackImg Script
rem by osm0sis @ xda-developers
rem.

if not exist *-new.* goto nowarning
rem Warning: Overwriting existing files!
rem.

:nowarning
del ramdisk-new.cpio* 2>nul
if "%1" == "--original" rem Repacking with original ramdisk . . . & goto skipramdisk
rem Packing ramdisk . . .
rem.
for /f "delims=" %%a in ('dir /b split_img\*-ramdiskcomp') do @set ramdiskcname=%%a
for /f "delims=" %%a in ('type "split_img\%ramdiskcname%"') do @set ramdiskcomp=%%a

if "%1" == "--level" if not [%2] == [] (
  set "level=-%2"
  set "lvltxt= - Level: %2"
) else (
  set lvltxt=
  set level=
)
rem Using compression: %ramdiskcomp%%lvltxt%
if "%ramdiskcomp%" == "gzip" set "repackcmd=gzip %level%" & set "compext=gz"
%bin%\mkbootfs ramdisk %errout% | %bin%\%repackcmd% %errout% > ramdisk-new.cpio.%compext%
if errorlevel == 1 goto error
:skipramdisk
rem.

rem Getting build information . . .
rem.
for /f "delims=" %%a in ('dir /b split_img\*-zImage') do @set kernel=%%a
rem kernel = %kernel%
for /f "delims=" %%a in ('dir /b split_img\*-ramdisk.cpio*') do @set ramdisk=%%a
if "%1" == "--original" rem ramdisk = %ramdisk% & set "ramdisk=--ramdisk "split_img/%ramdisk%""
if not "%1" == "--original" set "ramdisk=--ramdisk ramdisk-new.cpio.%compext%"
for /f "delims=" %%a in ('dir /b split_img\*-cmdline') do @set cmdname=%%a
for /f "delims=" %%a in ('type "split_img\%cmdname%"') do @set cmdline=%%a
rem cmdline = %cmdline%
if defined cmdline set cmdline=%cmdline:"=\"%
for /f "delims=" %%a in ('dir /b split_img\*-board') do @set boardname=%%a
for /f "delims=" %%a in ('type "split_img\%boardname%"') do @set board=%%a
rem board = %board%
if defined board set board=%board:"=\"%
for /f "delims=" %%a in ('dir /b split_img\*-base') do @set basename=%%a
for /f "delims=" %%a in ('type "split_img\%basename%"') do @set base=%%a
rem base = %base%
for /f "delims=" %%a in ('dir /b split_img\*-pagesize') do @set pagename=%%a
for /f "delims=" %%a in ('type "split_img\%pagename%"') do @set pagesize=%%a
rem pagesize = %pagesize%
for /f "delims=" %%a in ('dir /b split_img\*-kerneloff') do @set koffname=%%a
for /f "delims=" %%a in ('type "split_img\%koffname%"') do @set kerneloff=%%a
rem kernel_offset = %kerneloff%
for /f "delims=" %%a in ('dir /b split_img\*-ramdiskoff') do @set roffname=%%a
for /f "delims=" %%a in ('type "split_img\%roffname%"') do @set ramdiskoff=%%a
rem ramdisk_offset = %ramdiskoff%
for /f "delims=" %%a in ('dir /b split_img\*-tagsoff') do @set toffname=%%a
for /f "delims=" %%a in ('type "split_img\%toffname%"') do @set tagsoff=%%a
rem tags_offset = %tagsoff%
if not exist "split_img\*-second" goto skipsecond
for /f "delims=" %%a in ('dir /b split_img\*-second') do @set second=%%a
rem second = %second% & set "second=--second "split_img/%second%""
for /f "delims=" %%a in ('dir /b split_img\*-secondoff') do @set soffname=%%a
for /f "delims=" %%a in ('type "split_img\%soffname%"') do @set secondoff=%%a
rem second_offset = %secondoff% & set "second_offset=--second_offset %secondoff%"
:skipsecond
if not exist "split_img\*-dtb" goto skipdtb
for /f "delims=" %%a in ('dir /b split_img\*-dtb') do @set dtb=%%a
rem dtb = %dtb% & set "dtb=--dt "split_img/%dtb%""
:skipdtb
rem.

rem Building image . . .
rem.
%bin%\mkbootimg --kernel "split_img/%kernel%" %ramdisk% %second% --cmdline "%cmdline%" --board "%board%" --base %base% --pagesize %pagesize% --kernel_offset %kerneloff% --ramdisk_offset %ramdiskoff% %second_offset% --tags_offset %tagsoff% %dtb% -o image-new.img %errout%
if errorlevel == 1 goto error

rem Done!
goto end

:nofiles
rem No files found to be packed/built.

:error
rem Error!

:end
rem.
