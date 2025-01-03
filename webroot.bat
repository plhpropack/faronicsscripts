REM powershell -Command "Invoke-WebRequest https://downbox.webrootanywhere.com/wsasmeexe/1954-CNTM-CC35-9246-4D66.exe -OutFile C:\PLH\1954-cntm-cc35-9246-4d66.exe"

powershell -Command "Invoke-WebRequest https://anywhere.webrootcloudav.com/zerol/wsasme.msi -OutFile C:\PLH\wsasme.msi"

REM https://anywhere.webrootcloudav.com/zerol/wsasme.msi

Ping 127.0.0.1 -n 30

call msiexec /i c:\plh\wsasme.msi GUILIC=1954-cntm-cc35-9246-4d66 CMDLINE=SME,quiet /qn /l*v c:\plh\install.log
