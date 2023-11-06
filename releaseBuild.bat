c:
cd dev\b4x\src\OctoTouchController
del *.apk < y
"C:\Program Files\Anywhere Software\B4A\B4ABuilder.exe" -task=build -Configuration=Default -Optimize=true -Output=OctoTouchController
copy Objects\*.apk 
del OctoTouchController_java_src.7z
7z a -t7z -r OctoTouchController_java_src.7z "Objects\src\*.*"
pause
