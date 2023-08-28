c:
cd dev\b4x\src\OctoTouchController
del *.apk < y
"C:\Program Files\Anywhere Software\B4A\B4ABuilder.exe" -task=build -Configuration=Default -Optimize=true -Output=OctoTouchController
copy Objects\*.apk 
"C:\Program Files\Anywhere Software\B4A\B4ABuilder.exe" -task=build -Configuration=klipper -Optimize=true -Output=KlipperTouchController
copy Objects\*.apk 
pause

