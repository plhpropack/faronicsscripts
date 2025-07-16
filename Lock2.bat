




reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP /v "LockScreenImagePath" /t REG_SZ /d "C:\\plh\\lock.jpg" /f > c:\plh\lock2.txt
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP /v "LockScreenImageUrl" /t REG_SZ /d "C:\\plh\\lock.jpg" /f >> c:\plh\lock2.txt
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP /v "LockScreenImageStatus" /t REG_DWORD  /d "1" /f >> c:\plh\lock2.txt

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v "RotatingLockScreenEnabled" /t REG_DWORD  /d "0" /f >> c:\plh\lock2.txt
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager /v "RotatingLockScreenOverlayEnabled" /t REG_DWORD  /d "0" /f >> c:\plh\lock2.txt

reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v "Wallpaper" /t REG_SZ /d "C:\\plh\\desktop.jpg" /f >> c:\plh\lock2.txt
reg add HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System /v "Wallpaper" /t REG_SZ  /d "C:\\plh\\desktop.jpg" /f >> c:\plh\lock2.txt
