powershell -c "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/plhpropack/faronicsscripts/main/lock.jpg' -OutFile 'c:\plh\lock_.jpg'
powershell -c "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/plhpropack/faronicsscripts/main/desktop.jpg' -OutFile 'c:\plh\desktop_.jpg'

xcopy "\\w2k16adfs\Propack Unclassifed (UN)\Propack\desktop.jpg" "C:\plh\desktop.jpg" /h /y
xcopy "\\w2k16adfs\Propack Unclassifed (UN)\Propack\lock.jpg" "C:\plh\lock.jpg" /h /y


REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP /v LockScreenImagePath /t REG_SZ /d "C:\plh\lock.jpg" /f
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP /v LockScreenImageUrl /t REG_SZ /d "C:\plh\lock.jpg" /f
REG ADD HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP /v LockScreenImageStatus /t REG_DWORD /d 1 /f
