#Set lock screen
md c:\PLH

Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/plhpropack/faronicsscripts/main/lock.jpg' -OutFile 'c:\plh\lock.jpg'
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/plhpropack/faronicsscripts/main/desktop.jpg' -OutFile 'c:\plh\desktop.jpg'
REM Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/plhpropack/faronicsscripts/refs/heads/main/lockscreen.reg'  -OutFile 'c:\plh\lockscreen.reg'

REM xcopy "\\w2k16adfs\Propack Unclassifed (UN)\Propack\desktop.jpg" "C:\plh\desktop.jpg" /h /y
REM xcopy "\\w2k16adfs\Propack Unclassifed (UN)\Propack\lock.jpg" "C:\plh\lock.jpg" /h /y

reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP /v "LockScreenImagePath" /t REG_SZ /d "C:\plh\lock.jpg" /f
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP /v "LockScreenImageUrl" /t REG_SZ /d "C:\plh\lock.jpg" /f
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP /v "LockScreenImageStatus" /t REG_DWORD  /d "1" /f

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v "RotatingLockScreenEnabled" /t REG_DWORD  /d "0" /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD  /d "0"

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v "Wallpaper" /t REG_SZ /d "C:\plh\desktop.jpg" /f
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v "WallpaperStyle" /t REG_SZ  /d "4" /f
