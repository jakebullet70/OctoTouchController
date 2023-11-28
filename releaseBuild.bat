ECHO OFF
ECHO -------- start builds -----------------
c:
cd C:\dev\b4x\src\OctoTouchController

del *.apk 
del OctoTouchController_java_src_legacy.7z 
del OctoTouchController_java_src.7z

ECHO ------------- legacy ------------------
"C:\Program Files\Anywhere Software\B4A\B4ABuilder.exe" -task=build -Configuration=legacy -Optimize=true -Output=OctoTouchController_legacy
copy Objects\*.apk 
7z a -t7z -r OctoTouchController_java_src_legacy.7z "Objects\src\*.*"

ECHO -------------- FOSS -------------------
"C:\Program Files\Anywhere Software\B4A\B4ABuilder.exe" -task=build -Configuration=Default -Optimize=true -Output=OctoTouchController
copy Objects\*.apk 
7z a -t7z -r OctoTouchController_java_src.7z "Objects\src\*.*"

ECHO -------------- end --------------------
pause
