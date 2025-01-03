REM powershell -Command "Invoke-WebRequest https://downbox.webrootanywhere.com/wsasmeexe/1954-CNTM-CC35-9246-4D66.exe -OutFile C:\PLH\1954-cntm-cc35-9246-4d66.exe"

powershell -Command "Invoke-WebRequest https://anywhere.webrootcloudav.com/zerol/wsasme.msi -OutFile C:\PLH\wsasme.msi"

powershell -Command Start-Process 'msiexec.exe' -ArgumentList '/I "C:\PLH\wsasme.msi" GUILIC=1954-cntm-cc35-9246-4d66 /qn /l*v c:\plh\install.log' -Wait

REM https://anywhere.webrootcloudav.com/zerol/wsasme.msi

REM Ping 127.0.0.1 -n 30

REM call msiexec /i c:\plh\wsasme.msi GUILIC=1954-cntm-cc35-9246-4d66 CMDLINE=SME,quiet /qn /l*v c:\plh\install.log


REM (Start-Process "msiexec.exe" -ArgumentList "/i $dirFiles\ABDS2017\Img\x64\RVT\RVT.msi INSTALLDIR=""C:\Program Files\Autodesk\"" ADSK_SETUP_EXE=1 /qb!" -NoNewWindow -Wait -PassThru).ExitCode




REM powershell -Command Start-Process 'msiexec.exe' -ArgumentList '/I "C:\PLH\wsasme.msi" GUILIC=1954-cntm-cc35-9246-4d66 /qn /l*v c:\plh\install.log' -Wait
