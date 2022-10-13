reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\SharingWizardOn" /T REG_DWORD /V CheckedValue /D 0 /F
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\Folder\SharingWizardOn" /T REG_DWORD /V DefaultValue /D 0 /F
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /T REG_DWORD /V SharingWizardOn /D 0 /F
