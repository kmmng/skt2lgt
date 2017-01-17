@echo off
set c_date=%date%
set c_y=%c_date:~-4%
set c_m=%c_date:~-10,2%
set c_d=%c_date:~-7,2%
set c_date=%c_y%%c_m%%c_d%
set scmd=sed -l 0 -i
set hlp=n
set dev_model=none
if "%1"=="l" set dev_model=c1lgt
if "%1"=="L" set dev_model=c1lgt
if "%1"=="" set dev_model=c1lgt
if "%1"=="" set dev_model=c1lgt
if "%1"=="s" set dev_model=c1skt
if "%1"=="S" set dev_model=c1skt
if "%1"=="k" set dev_model=c1ktt
if "%1"=="K" set dev_model=c1ktt
if "%dev_model%"=="c1lgt" set dev_model2=SHV-E210L
if "%dev_model%"=="c1skt" set dev_model2=SHV-E210S
if "%dev_model%"=="c1ktt" set dev_model2=SHV-E210K
if "%dev_model%"=="none" (
set hlp=y
goto help
)
set k_src=none
set k_src_2=none
if "%2"=="c" set k_src=cm
if "%2"=="C" set k_src=cm
if "%2"=="" set k_src=cm
if "%2"=="" set k_src=cm
if "%2"=="b" set k_src=boeffla
if "%2"=="B" set k_src=boeffla
if "%2"=="f" set k_src=fullgreen
if "%2"=="F" set k_src=fullgreen
if "%2"=="cm+" set k_src=cm+
if "%2"=="cmu" set k_src=cmu
if "%k_src%"=="none" (
set hlp=y
goto help
)
set k_src_2=%k_src%
if "%k_src%"=="cm" (
set k_url=git://github.com/CyanogenMod/android_kernel_samsung_smdk4412.git
set k_dir=android_kernel_samsung_smdk4412
set k_branch=cm-13.0
set src_cfg=cyanogenmod_i9300_defconfig
set dest_cfg=cyanogenmod_%dev_model%_defconfig
set tc_url=https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8
set tc_dir=arm-eabi-4.8
)
if "%k_src%"=="boeffla" (
set k_url=git://github.com/andip71/boeffla-kernel-cm-s3
set k_dir=boeffla-kernel-cm-s3
set k_branch=boeffla13.0
set src_cfg=boeffla_defconfig
set dest_cfg=boeffla_%dev_model%_defconfig
set tc_url=https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8
set tc_dir=arm-eabi-4.8
)
if "%k_src%"=="fullgreen" (
set k_url=git://github.com/FullGreen/fullgreenkernel_smdk4412.git
set k_dir=fullgreenkernel_smdk4412
set k_branch=cm-13.0
set src_cfg=cyanogenmod_c1skt_defconfig
set dest_cfg=cyanogenmod_%dev_model%_defconfig
set tc_url=https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8
set tc_dir=arm-eabi-4.8
)
if "%k_src%"=="cm+" (
set k_url=git://github.com/CyanogenMod/android_kernel_samsung_smdk4412.git
set k_dir=android_kernel_samsung_smdk4412
set k_branch=stable/cm-13.0-ZNH5Y
set src_cfg=cyanogenmod_i9300_defconfig
set dest_cfg=cyanogenmod_%dev_model%_defconfig
set tc_url=https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8
set tc_dir=arm-eabi-4.8
set k_src=cm
set k_src_2=cmstable
)
if "%k_src%"=="cmu" (
set k_url=git://github.com/CyanogenMod/android_kernel_samsung_smdk4412.git
set k_dir=android_kernel_samsung_smdk4412
set k_branch=cm-13.0
set src_cfg=cyanogenmod_i9300_defconfig
set dest_cfg=cyanogenmod_%dev_model%_defconfig
set tc_url=https://bitbucket.org/UBERTC/arm-eabi-6.0.git
set tc_dir=arm-eabi-6.0
set k_src=cm
set k_src_2=cmuber
)
Echo Configuring WSL installation... This can take a long time on the first run...
lxrun /install /y 1>>nul 2>>nul
bash -c "sudo apt-get -q=2 -y install git-core dos2unix flex bison build-essential zip" 1>>nul 2>>nul
if not "%k_src%"=="fullgreen" copy %~dp0c1kernel-cm.diff temppatch.diff 1>>nul 2>>nul
copy %~dp0\camera\s5c73m3.c s5c73m3.c 1>>nul 2>>nul
copy %~dp0\camera\s5c73m3.h s5c73m3.h 1>>nul 2>>nul
copy %~dp0\camera\s5c73m3_spi.c s5c73m3_spi.c 1>>nul 2>>nul
copy %~dp0\camera\s5c73m3_platform.h s5c73m3_platform.h 1>>nul 2>>nul
copy %~dp0\camera\midas-camera.c midas-camera.c 1>>nul 2>>nul
if not "%k_src%"=="boeffla" copy %~dp0template.zip cm-13.0-%c_date%-%k_src_2%-kernel-%dev_model%.zip 1>>nul 2>>nul
echo Running WSL shell script...
del zImage 2>>nul
del *.ko 2>>nul
del temp.sh 2>>nul
1>>temp.sh echo #!/bin/bash
1>>temp.sh echo echo Downloading ARM toolchain... This can take a long time on the first run...
1>>temp.sh echo git clone %tc_url% 2^>^>/dev/null
1>>temp.sh echo git checkout -f %tc_branch% 1^>^>/dev/null 2^>^>/dev/null
1>>temp.sh echo pushd %tc_dir% ^>^>/dev/null
REM This is needed to update to latest toolchain in case git checkout was done in earlier run
1>>temp.sh echo git pull 1^>^>/dev/null 2^>^>/dev/null
1>>temp.sh echo git checkout -f %k_branch% 1^>^>/dev/null 2^>^>/dev/null
1>>temp.sh echo popd ^>^>/dev/null
1>>temp.sh echo export CROSS_COMPILE=${PWD}/%tc_dir%/bin/arm-eabi-
1>>temp.sh echo export PATH=${PWD}/%tc_dir%/bin:${PATH}
1>>temp.sh echo export ARCH=arm
1>>temp.sh echo echo Downloading kernel source... This can take a long time on the first run...
1>>temp.sh echo git clone %k_url% 2^>^>/dev/null
if not "%k_src%"=="fullgreen" (
1>>temp.sh echo mv temppatch.diff %k_dir%
1>>temp.sh echo mkdir -p %k_dir%/camera
1>>temp.sh echo mv s5c73m3.c %k_dir%/camera/
1>>temp.sh echo mv s5c73m3.h %k_dir%/camera/
1>>temp.sh echo mv s5c73m3_spi.c %k_dir%/camera/
1>>temp.sh echo mv s5c73m3_platform.h %k_dir%/camera/
1>>temp.sh echo mv midas-camera.c %k_dir%/camera/
)
1>>temp.sh echo cd %k_dir%
REM This is needed to update to latest source in case git checkout was done in earlier run
1>>temp.sh echo git pull 1^>^>/dev/null 2^>^>/dev/null
1>>temp.sh echo git checkout -f %k_branch% 1^>^>/dev/null 2^>^>/dev/null
REM WSL symlink bug workaround
1>>temp.sh echo cd include
1>>temp.sh echo rm asm
1>>temp.sh echo ln -s asm-generic asm
1>>temp.sh echo cd ..
REM End of workaround
1>>temp.sh echo echo Patching kernel for %dev_model2%...
if "%k_src%"=="fullgreen" (
1>>temp.sh echo pushd arch/arm/mach-exynos ^>^>/dev/null
1>>temp.sh echo %scmd% 's/		.name = "lte_rmnet0",/#if !defined^(CONFIG_C1_LGT_EXPERIMENTAL^)\n		.name = "lte_rmnet0",\n#else\n		.name = "rmnet0",\n#endif/' board-c1lgt-modems.c
1>>temp.sh echo %scmd% 's/		.name = "lte_rmnet1",/#if !defined^(CONFIG_C1_LGT_EXPERIMENTAL^)\n		.name = "lte_rmnet1",\n#else\n		.name = "rmnet1",\n#endif/' board-c1lgt-modems.c
1>>temp.sh echo %scmd% 's/		.name = "lte_rmnet2",/#if !defined^(CONFIG_C1_LGT_EXPERIMENTAL^)\n		.name = "lte_rmnet2",\n#else\n		.name = "rmnet2",\n#endif/' board-c1lgt-modems.c
1>>temp.sh echo %scmd% 's/		.name = "lte_rmnet3",/#if !defined^(CONFIG_C1_LGT_EXPERIMENTAL^)\n		.name = "lte_rmnet3",\n#else\n		.name = "rmnet3",\n#endif/' board-c1lgt-modems.c
1>>temp.sh echo %scmd% '1,/	.use_handover = true,/s/	.use_handover = true,/#if !defined^(CONFIG_C1_LGT_EXPERIMENTAL^)\n	.use_handover = true,\n#else\n	.use_handover = false,\n#endif/' board-c1lgt-modems.c
1>>temp.sh echo %scmd% '/config MACH_C1_KOR_LGT/ { N; /	bool "LG U+"/ s/	bool "LG U+"/	bool "LG U+"\n	select FM34_WE395/}' Kconfig.local
1>>temp.sh echo %scmd% '/	select FM34_WE395/ { N; /endchoice/ s/endchoice/endchoice\n\nconfig C1_LGT_EXPERIMENTAL\n	bool "E210L Experimental Modem Config"\n 	depends on MACH_C1_KOR_LGT/}' Kconfig.local
1>>temp.sh echo popd ^>^>/dev/null
) else (
1>>temp.sh echo rm -rf drivers/misc/modem_if_c1
1>>temp.sh echo rm -rf include/linux/platform_data/modem_c1.h
1>>temp.sh echo patch --no-backup-if-mismatch -t -r - -p1 -s ^< temppatch.diff
1>>temp.sh echo rm -f temppatch.diff
REM GCC6 quick workaround
if "%tc_dir%"=="arm-eabi-6.0" (
1>>temp.sh echo pushd include/linux ^>^>/dev/null
1>>temp.sh echo wget https://raw.githubusercontent.com/FullGreen/fullgreenkernel_smdk4412/cm-13.0/include/linux/compiler-gcc6.h ^>^>/dev/null
1>>temp.sh echo popd ^>^>/dev/null
)
REM End of workaround
)
REM Disable CDMA modem init as it not used by our build
1>>temp.sh echo %scmd% 's/	setup_cdma_modem_env();/#if !defined(CONFIG_C1_LGT_EXPERIMENTAL)\n	setup_cdma_modem_env();\n#endif/' arch/arm/mach-exynos/board-c1lgt-modems.c
1>>temp.sh echo %scmd% 's/	config_cdma_modem_gpio();/#if !defined(CONFIG_C1_LGT_EXPERIMENTAL)\n	config_cdma_modem_gpio();\n#endif/' arch/arm/mach-exynos/board-c1lgt-modems.c
1>>temp.sh echo %scmd% 's/	bnk_cfg = \^&cbp_edpram_bank_cfg;/#if !defined(CONFIG_C1_LGT_EXPERIMENTAL)\n	bnk_cfg = \^&cbp_edpram_bank_cfg;/' arch/arm/mach-exynos/board-c1lgt-modems.c
1>>temp.sh echo %scmd% 's/	sromc_config_access_timing(bnk_cfg-^>csn, tm_cfg);/@ @ @ @/' arch/arm/mach-exynos/board-c1lgt-modems.c
1>>temp.sh echo %scmd% '1,/@ @ @ @/s/@ @ @ @/	sromc_config_access_timing(bnk_cfg-^>csn, tm_cfg);/' arch/arm/mach-exynos/board-c1lgt-modems.c
1>>temp.sh echo %scmd% '1,/@ @ @ @/s/@ @ @ @/	sromc_config_access_timing(bnk_cfg-^>csn, tm_cfg);\n#endif/' arch/arm/mach-exynos/board-c1lgt-modems.c
1>>temp.sh echo %scmd% 's/	platform_device_register(\^&cdma_modem);/#if !defined(CONFIG_C1_LGT_EXPERIMENTAL)\n	platform_device_register(\^&cdma_modem);\n#endif/' arch/arm/mach-exynos/board-c1lgt-modems.c
REM Update camera kernel driver from Samsung source, this seems to make camera app glitches less severe
1>>temp.sh echo mv camera/s5c73m3.c drivers/media/video/
1>>temp.sh echo mv camera/s5c73m3.h drivers/media/video/
1>>temp.sh echo mv camera/s5c73m3_spi.c drivers/media/video/
1>>temp.sh echo mv camera/s5c73m3_platform.h include/media/
1>>temp.sh echo mv camera/midas-camera.c arch/arm/mach-exynos/
1>>temp.sh echo rm -rf camera
1>>temp.sh echo echo Cleaning...
1>>temp.sh echo sleep 2
if "%k_src%"=="boeffla" (
1>>temp.sh echo rm -rf ../build ../repack ../compile.log
)
1>>temp.sh echo make clean 1^>^>/dev/null 2^>^>/dev/null
1>>temp.sh echo make mrproper 1^>^>/dev/null 2^>^>/dev/null
1>>temp.sh echo echo Creating kernel config file for %dev_model2%...
1>>temp.sh echo pushd arch/arm/configs ^>^>/dev/null
1>>temp.sh echo cp %src_cfg% %dest_cfg% 1^>^>/dev/null 2^>^>/dev/null
if not "%k_src%"=="fullgreen" (
1>>temp.sh echo %scmd% 's/CONFIG_TARGET_LOCALE_EUR=y//' %dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_TARGET_LOCALE_KOR is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_TARGET_LOCALE_KOR=y^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/CONFIG_MACH_M0=y//' %dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_MACH_C1 is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_MACH_C1=y^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/CONFIG_WLAN_REGION_CODE=100//' %dest_cfg%
1>>temp.sh echo %scmd% 's/CONFIG_SEC_MODEM_M0=y//' %dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_LTE_MODEM_CMC221 is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_LTE_MODEM_CMC221=y^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_LINK_DEVICE_DPRAM is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_LINK_DEVICE_DPRAM=y^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_LINK_DEVICE_USB is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_LINK_DEVICE_USB=y^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_USBHUB_USB3503 is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_USBHUB_USB3503=y^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/CONFIG_UMTS_MODEM_XMM6262=y//' %dest_cfg%
1>>temp.sh echo %scmd% 's/CONFIG_LINK_DEVICE_HSIC=y//' %dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_SIPC_VER_5 is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_SIPC_VER_5=y^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/CONFIG_SND_DEBUG=y//' %dest_cfg%
1>>temp.sh echo %scmd% 's/CONFIG_FM_RADIO=y//' %dest_cfg%
1>>temp.sh echo %scmd% 's/CONFIG_FM_SI4705=y//' %dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_TDMB is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_TDMB=y^>^>%dest_cfg%
1>>temp.sh echo echo CONFIG_TDMB_VENDOR_RAONTECH=y^>^>%dest_cfg%
1>>temp.sh echo echo CONFIG_TDMB_MTV318=y^>^>%dest_cfg%
1>>temp.sh echo echo CONFIG_TDMB_SPI=y^>^>%dest_cfg%
REM Fix video playback error, thanks to FullGreen
1>>temp.sh echo %scmd% 's/CONFIG_DMA_CMA=y//' %dest_cfg%
1>>temp.sh echo %scmd% '/CONFIG_CMA_SIZE_MBYTES/d' %dest_cfg%
1>>temp.sh echo %scmd% '/CONFIG_CMA_SIZE_SEL_MBYTES/d' %dest_cfg%
1>>temp.sh echo %scmd% '/CONFIG_CMA_ALIGNMENT/d' %dest_cfg%
1>>temp.sh echo %scmd% '/CONFIG_CMA_AREAS/d' %dest_cfg%
1>>temp.sh echo %scmd% 's/CONFIG_USE_FIMC_CMA=y//' %dest_cfg%
1>>temp.sh echo %scmd% 's/CONFIG_USE_MFC_CMA=y//' %dest_cfg%
)
if "%dev_model%"=="c1lgt" (
1>>temp.sh echo echo CONFIG_MACH_C1_KOR_LGT=y^>^>%dest_cfg%
1>>temp.sh echo echo CONFIG_C1_LGT_EXPERIMENTAL=y^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_FM34_WE395 is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_FM34_WE395=y^>^>%dest_cfg%
1>>temp.sh echo echo CONFIG_WLAN_REGION_CODE=203^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_SEC_MODEM_C1_LGT is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_SEC_MODEM_C1_LGT=y^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_CDMA_MODEM_CBP72 is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_CDMA_MODEM_CBP72=y^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_LTE_VIA_SWITCH is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_LTE_VIA_SWITCH=y^>^>%dest_cfg%
1>>temp.sh echo echo CONFIG_CMC_MODEM_HSIC_SYSREV=11^>^>%dest_cfg%
)
if "%dev_model%"=="c1skt" (
1>>temp.sh echo echo CONFIG_MACH_C1_KOR_SKT=y^>^>%dest_cfg%
1>>temp.sh echo echo CONFIG_WLAN_REGION_CODE=201^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_SEC_MODEM_C1 is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_SEC_MODEM_C1=y^>^>%dest_cfg%
1>>temp.sh echo echo CONFIG_CMC_MODEM_HSIC_SYSREV=9^>^>%dest_cfg%
)
if "%dev_model%"=="c1ktt" (
1>>temp.sh echo echo CONFIG_MACH_C1_KOR_KTT=y^>^>%dest_cfg%
1>>temp.sh echo echo CONFIG_WLAN_REGION_CODE=202^>^>%dest_cfg%
1>>temp.sh echo %scmd% 's/# CONFIG_SEC_MODEM_C1 is not set//' %dest_cfg%
1>>temp.sh echo echo CONFIG_SEC_MODEM_C1=y^>^>%dest_cfg%
1>>temp.sh echo echo CONFIG_CMC_MODEM_HSIC_SYSREV=9^>^>%dest_cfg%
)
1>>temp.sh echo popd ^>^>/dev/null
if not "%k_src%"=="boeffla" (
1>>temp.sh echo echo Building %dev_model2% kernel and modules...
1>>temp.sh echo sleep 2
1>>temp.sh echo make %dest_cfg%
1>>temp.sh echo make -j5
1>>temp.sh echo cp arch/arm/boot/zImage ..
1>>temp.sh echo cp `find -iname *.ko` ..
1>>temp.sh echo cd ..
1>>temp.sh echo arm-eabi-strip --strip-unneeded *.ko
1>>temp.sh echo zip -q -9 cm-13.0-%c_date%-%k_src_2%-kernel-%dev_model%.zip zImage
1>>temp.sh echo rm -rf modules
1>>temp.sh echo mkdir modules
1>>temp.sh echo cp *.ko modules
1>>temp.sh echo zip -q -9 -m -r cm-13.0-%c_date%-%k_src_2%-kernel-%dev_model%.zip modules
)
if "%k_src%"=="boeffla" (
1>>temp.sh echo echo Patching Boeffla files...
1>>temp.sh echo cd anykernel_boeffla
1>>temp.sh echo find -path "*.sh" -exec %scmd% 's/i9300/%dev_model%/g' {} \;
1>>temp.sh echo find -path "*.sh" -exec %scmd% 's/GT-I9300/%dev_model2%/g' {} \;
1>>temp.sh echo %scmd% 's@############### Ramdisk customization end ###############@# comm fix\n############### Ramdisk customization end ###############@' anykernel.sh
1>>temp.sh echo %scmd% 's@# comm fix@# comm fix\nreplace_line $ramdisk/init.target.rc "service cpboot-daemon /sbin/cbd -d" "service cbd-lte /sbin/cbd -d -t cmc221 -b d -m d";@' anykernel.sh
1>>temp.sh echo %scmd% 's@# comm fix@# comm fix\nreplace_line $ramdisk/init.target.rc "    write /data/.cid.info 0" "    write /data/.cid.info murata\\n    chown wifi system /data/.cid.info\\n    chmod 0660 /data/.cid.info";@' anykernel.sh
1>>temp.sh echo %scmd% 's@# comm fix@# comm fix\nreplace_line $ramdisk/init.rc "    group radio cache inet misc audio log qcom_diag" "    group radio cache inet misc audio log qcom_diag\\n    onrestart restart cbd-lte";@' anykernel.sh
1>>temp.sh echo %scmd% 's@# comm fix@# comm fix\nremove_line $ramdisk/init.rc "    onrestart restart cbd-lte";@' anykernel.sh
if "%dev_model%"=="c1lgt" (
1>>temp.sh echo find -path "*.sh" -exec %scmd% -e 's/mmcblk0p12/mmcblk0p13/g' -e 's/mmcblk0p11/mmcblk0p12/g' -e 's/mmcblk0p10/mmcblk0p11/g' -e 's/mmcblk0p9/mmcblk0p10/g' -e 's/mmcblk0p8/mmcblk0p9/g' {} \;
)
1>>temp.sh echo cd ramdisk/res/misc
1>>temp.sh echo zip -q -d boeffla-config-reset-v4.zip META-INF/CERT.RSA META-INF/CERT.SF META-INF/MANIFEST.MF
1>>temp.sh echo unzip -q boeffla-config-reset-v4.zip META-INF/com/google/android/updater-script
1>>temp.sh echo %scmd% 's/i9300\/n8000\/n801x/      %dev_model%      /' META-INF/com/google/android/updater-script
if "%dev_model%"=="c1lgt" (
1>>temp.sh echo %scmd% -e 's/mmcblk0p12/mmcblk0p13/g' -e 's/mmcblk0p11/mmcblk0p12/g' -e 's/mmcblk0p10/mmcblk0p11/g' -e 's/mmcblk0p9/mmcblk0p10/g' -e 's/mmcblk0p8/mmcblk0p9/g' META-INF/com/google/android/updater-script
)
1>>temp.sh echo zip -q -m -9 boeffla-config-reset-v4.zip META-INF/com/google/android/updater-script
1>>temp.sh echo rm -rf META-INF
1>>temp.sh echo cd ../../../..
1>>temp.sh echo %scmd% 's/boeffla_defconfig/%dest_cfg%/' bbuild-anykernel.sh
1>>temp.sh echo BK_VER=`tail -n 1 versions.txt`
1>>temp.sh echo BK_VER=`echo $BK_VER ^| sed s/:.*//`
1>>temp.sh echo %scmd% "s/BOEFFLA_VERSION=\".*/BOEFFLA_VERSION=\"${BK_VER}-CM13.0-%dev_model%\"/" bbuild-anykernel.sh
1>>temp.sh echo %scmd% "s#TOOLCHAIN=\".*#TOOLCHAIN=\"${CROSS_COMPILE}\"#" bbuild-anykernel.sh
1>>temp.sh echo echo Running Boeffla build script...
1>>temp.sh echo sleep 2
1>>temp.sh echo bash ./bbuild-anykernel.sh rel
1>>temp.sh echo cd ../build
1>>temp.sh echo cp arch/arm/boot/zImage ..
1>>temp.sh echo cp `find -iname *.ko` ..
1>>temp.sh echo cd ..
1>>temp.sh echo arm-eabi-strip --strip-unneeded *.ko
1>>temp.sh echo cp repack/cm-kernel.zip cm-13.0-%c_date%-boeffla-kernel-%dev_model%.zip
1>>temp.sh echo rm -rf build repack compile.log
)
bash -c "dos2unix -q temp.sh"
bash temp.sh
del temp.sh 2>>nul
del temppatch.diff 2>>nul
:help
if "%hlp%"=="y" (
echo Usage : %~nx0 [model] [source]
echo Model is : L for SHV-E210L, S for SHV-E210S, K for SHV-E210K
echo Source is : C for CM13, B for Boeffla, F for Fullgreen
echo Default is SHV-E210L CM13
)
set hlp=
set tc_url=
set tc_dir=
set k_src=
set k_src_2=
set k_url=
set k_dir=
set k_branch=
set dev_model=
set dev_model2=
set scmd=
set src_cfg=
set dest_cfg=
set c_date=
set c_y=
set c_m=
set c_d=
