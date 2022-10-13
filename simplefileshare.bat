reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\SharingWizardOn" /T REG_DWORD /V CheckedValue /D 0 /F
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\SharingWizardOn" /T REG_DWORD /V DefaultValue /D 0 /F
REG ADD HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced /v SharingWizardOn /t REG_DWORD /d 0x00000000 /f > NUL
