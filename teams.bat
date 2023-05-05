copy \\w2k16adfs\wu$\Microsoft365\Teams_windows_x64.exe c:\PLH\Teams_windows_x64.exe /Y
REM copy \\w2k16adfs\wu$\PLH\Fonts\*.*tf c:\PLH\fonts /Y
echo teams > c:\PLH\teams1.txt
call c:\plh\Teams_windows_x64.exe -s
echo teams > c:\PLH\teams2.txt
