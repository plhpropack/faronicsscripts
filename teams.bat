copy \\w2k16adfs\wu$\Microsoft365\Teams_windows_x64.msi c:\PLH\Teams_windows_x64.msi /Y
REM copy \\w2k16adfs\wu$\PLH\Fonts\*.*tf c:\PLH\fonts /Y
echo teams > c:\PLH\teams1.txt
call msiexec /i c:\plh\Teams_windows_x64.msi /qn ALLUSERS=1
echo teams > c:\PLH\teams2.txt
