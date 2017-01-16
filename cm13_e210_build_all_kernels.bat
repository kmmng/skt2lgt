@echo off
pushd "%1"
call %~dp0cm13_e210_kernel_wsl.bat l c
call %~dp0cm13_e210_kernel_wsl.bat s c
call %~dp0cm13_e210_kernel_wsl.bat k c
call %~dp0cm13_e210_kernel_wsl.bat l cm+
call %~dp0cm13_e210_kernel_wsl.bat s cm+
call %~dp0cm13_e210_kernel_wsl.bat k cm+
call %~dp0cm13_e210_kernel_wsl.bat l cmu
call %~dp0cm13_e210_kernel_wsl.bat s cmu
call %~dp0cm13_e210_kernel_wsl.bat k cmu
call %~dp0cm13_e210_kernel_wsl.bat l b
call %~dp0cm13_e210_kernel_wsl.bat s b
call %~dp0cm13_e210_kernel_wsl.bat k b
call %~dp0cm13_e210_kernel_wsl.bat l f
call %~dp0cm13_e210_kernel_wsl.bat s f
call %~dp0cm13_e210_kernel_wsl.bat k f
del *.ko
del zImage
popd
