@echo off
if "%1"=="" goto end
if not exist %1 goto end
set xe=%~dp07z.exe
set kp=%~dp0kitchen
set scmd=%~dp0sed -l 0 -i
set d2u=%~dp0dos2unix.exe -q
set wd=%~dp1
pushd %~dp1

echo Creating new zip file...
set ff=%~nx1
set ff=%ff:c1skt=c1lgt%
copy %~nx1 %ff% > nul

echo Deleting old signatures...
%xe% d "%ff%" META-INF\CERT.RSA > nul
%xe% d "%ff%" META-INF\CERT.SF > nul
%xe% d "%ff%" META-INF\MANIFEST.MF > nul

echo Patching updater-script for partition layout, model name, setup script...
%xe% x -y "%ff%" META-INF\com\google\android\updater-script > nul
pushd META-INF\com\google\android
%scmd% -e "s/mmcblk0p12/mmcblk0p13/" -e "s/mmcblk0p11/mmcblk0p12/" -e "s/mmcblk0p10/mmcblk0p11/" -e "s/mmcblk0p9/mmcblk0p10/" -e "s/mmcblk0p8/mmcblk0p9/" updater-script
%scmd% "s/\/c1skt/\/c1lgt/g" updater-script
%scmd% "s/\/E210S/\/E210L/g" updater-script
REM This not needed anymore as system image is not modified
REM %scmd% "/ui_print(\"Verifying the updated system image...\");/,/  abort(\"system partition has unexpected contents after OTA update\");/ d" updater-script
REM %scmd% "/endif;/ { N; /show_progress(0.020000, 10);/ s/endif;\nshow_progress(0.020000, 10);/show_progress(0.020000, 10);/}" updater-script
%scmd% "s/run_program(\"\/tmp\/install\/bin\/backuptool.sh\", \"restore\");/run_program(\"\/tmp\/install\/bin\/backuptool.sh\", \"restore\");\ndelete_recursive(\"\/system\/lib\/modules\");\npackage_extract_dir(\"system\", \"\/system\");/" updater-script
%scmd% "s/run_program(\"\/tmp\/install\/bin\/backuptool.sh\", \"restore\");/run_program(\"\/tmp\/install\/bin\/backuptool.sh\", \"restore\");\ndelete_recursive(\"\/system\/app\/helper\");\ndelete(\"\/system\/etc\/sound\/c1skt\");/" updater-script
del sed*.*
%d2u% updater-script
popd
%xe% a -y "%ff%" META-INF > nul
rd /s /q META-INF

echo Patching build.prop for model name, radio settings...
%xe% x -y "%ff%" system\build.prop > nul
pushd system
%scmd% "s/c1skt/c1lgt/g" build.prop
%scmd% "s/E210S/E210L/g" build.prop
%scmd% "s/ro.telephony.default_network=9/ro.telephony.default_network=0/" build.prop
%scmd% "s/persist.radio.adb_log_on=1/persist.radio.adb_log_on=0/" build.prop
del sed*.*
%d2u% build.prop
popd

echo Adding modules from new kernel...
md system\lib\modules
copy *.ko system\lib\modules\ > nul

echo Extracting mixer configuration and patching it...
%xe% x -y "%ff%" system.transfer.list > nul
%xe% x -y "%ff%" system.new.dat > nul
%~dp0sdat2img system.transfer.list system.new.dat system.ext4 > nul
%xe% x -y system.ext4 etc\sound\c1skt > nul
del system.transfer.list
del system.new.dat
del system.ext4
move etc system > nul
pushd system\etc\sound
ren c1skt c1lgt
%scmd% "/<device name=\"speaker\">/ { N; /    <path name=\"on\">/ s/    <path name=\"on\">/    <path name=\"on\">\n        <ctl name=\"FM Control\" val=\"4\"\/>/}" c1lgt
%scmd% "/    <path name=\"off\">/ { N; /        <ctl name=\"SPK Switch\" val=\"0\"\/>/ s/    <path name=\"off\">/    <path name=\"off\">\n        <ctl name=\"FM Control\" val=\"4\"\/>/}" c1lgt
%scmd% "/<device name=\"earpiece\">/ { N; /    <path name=\"on\">/ s/    <path name=\"on\">/    <path name=\"on\">\n        <ctl name=\"FM Control\" val=\"4\"\/>/}" c1lgt
%scmd% "/    <path name=\"off\">/ { N; /        <ctl name=\"RCV Switch\" val=\"0\"\/>/ s/    <path name=\"off\">/    <path name=\"off\">\n        <ctl name=\"FM Control\" val=\"4\"\/>/}" c1lgt
%scmd% "/<device name=\"headphone\">/ { N; /    <path name=\"on\">/ s/    <path name=\"on\">/    <path name=\"on\">\n        <ctl name=\"FM Control\" val=\"4\"\/>/}" c1lgt
%scmd% "/    <path name=\"off\">/ { N; /        <ctl name=\"HP Switch\" val=\"0\"\/>/ s/    <path name=\"off\">/    <path name=\"off\">\n        <ctl name=\"FM Control\" val=\"4\"\/>/}" c1lgt
%scmd% "/<device name=\"sco-out\">/ { N; /    <path name=\"on\">/ s/    <path name=\"on\">/    <path name=\"on\">\n        <ctl name=\"FM Control\" val=\"4\"\/>/}" c1lgt
%scmd% "/    <path name=\"off\">/ { N; /        <ctl name=\"AIF2DAC2L Mixer AIF1.1 Switch\" val=\"0\"\/>/ s/    <path name=\"off\">/    <path name=\"off\">\n        <ctl name=\"FM Control\" val=\"4\"\/>/}" c1lgt
del sed*.*
%d2u% c1lgt
popd

echo Adding everything to a zip file...
%xe% a -y "%ff%" system > nul
rd /s /q system

echo Patching file_contexts for partition layout, devices...
%xe% x -y "%ff%" file_contexts > nul
%scmd% -e "s/mmcblk0p12/mmcblk0p13/" -e "s/mmcblk0p11/mmcblk0p12/" -e "s/mmcblk0p10/mmcblk0p11/" -e "s/mmcblk0p9 /mmcblk0p10/"  -e "s/mmcblk0p8/mmcblk0p9/" file_contexts
%scmd% "s/\/dev\/umts_boot0                         u:object_r:radio_device:s0/\/dev\/umts_boot0                         u:object_r:radio_device:s0\n\/dev\/cdma_boot0                         u:object_r:radio_device:s0/" file_contexts
%scmd% "s/\/dev\/umts_boot1                         u:object_r:radio_device:s0/\/dev\/umts_boot1                         u:object_r:radio_device:s0\n\/dev\/cdma_boot1                         u:object_r:radio_device:s0/" file_contexts
%scmd% "s/\/dev\/umts_ipc0                          u:object_r:radio_device:s0/\/dev\/umts_ipc0                          u:object_r:radio_device:s0\n\/dev\/cdma_ipc0                          u:object_r:radio_device:s0/" file_contexts
%scmd% "s/\/dev\/umts_ramdump0                      u:object_r:radio_device:s0/\/dev\/umts_ramdump0                      u:object_r:radio_device:s0\n\/dev\/cdma_ramdump0                      u:object_r:radio_device:s0/" file_contexts
%scmd% "s/\/dev\/umts_rfs0                          u:object_r:radio_device:s0/\/dev\/umts_rfs0                          u:object_r:radio_device:s0\n\/dev\/cdma_rfs0                          u:object_r:radio_device:s0/" file_contexts
%scmd% "s/\/dev\/cdma_rfs0                          u:object_r:radio_device:s0/\/dev\/cdma_rfs0                          u:object_r:radio_device:s0\n\/dev\/cdma_multipdp                      u:object_r:radio_device:s0/" file_contexts
%scmd% "s/c1skt/c1lgt/" file_contexts
del sed*.*
%d2u% file_contexts
%xe% a -y "%ff%" file_contexts > nul

echo Unpacking boot image...
%xe% x -y "%ff%" boot.img > nul
move boot.img %kp% > nul
pushd %kp%
cmd /c cleanup.bat
cmd /c unpackimg.bat boot.img
del boot.img

echo Patching ramdisk for partition layout, devices, model name, ril service...
move %wd%file_contexts ramdisk > nul
cd ramdisk
%scmd% -e "s/mmcblk0p12/mmcblk0p13/" -e "s/mmcblk0p11/mmcblk0p12/" -e "s/mmcblk0p10/mmcblk0p11/" -e "s/mmcblk0p9/mmcblk0p10/" -e "s/mmcblk0p8/mmcblk0p9/" fstab.smdk4x12
%scmd% "s/c1skt/c1lgt/g" default.prop
%scmd% "s/c1skt/c1lgt/g" selinux_version
%scmd% "s/c1skt/c1lgt/g" service_contexts
%scmd% "s/    group radio cache inet misc audio log qcom_diag/    group radio cache inet misc audio log qcom_diag\n    onrestart restart cbd-lte/" init.rc
%scmd% "s/    write \/data\/.cid.info 0/    write \/data\/.cid.info murata\n    chown wifi system \/data\/.cid.info\n    chmod 0660 \/data\/.cid.info/" init.target.rc
%scmd% "s/service cpboot-daemon \/sbin\/cbd -d/service cbd-lte \/sbin\/cbd -d -t cmc221 -b d -m d/" init.target.rc
del sed*.*
%d2u% fstab.smdk4x12
%d2u% default.prop
%d2u% selinux_version
%d2u% service_contexts
%d2u% init.rc
%d2u% init.target.rc

echo Repacking boot image with a new kernel...
cd ..
copy %wd%zImage split_img\boot.img-zImage > nul
cmd /c repackimg.bat
move image-new.img %wd% > nul
call cleanup.bat
cd %~dp0
popd
ren image-new.img boot.img
%xe% a -y "%ff%" boot.img > nul
del boot.img

REM This is optional and needs 64-bit java and a lot of free ram
REM echo Test-signing the file...
REM java -jar -Xmx2048m %~dp0signapk.jar -w %~dp0testkey.x509.pem %~dp0testkey.pk8 "%ff%" "signed%ff%"
REM move "signed%ff%" "%ff%" > nul

popd
set xe=
set kp=
set wd=
set scmd=
set d2u=
set ff=
:end
