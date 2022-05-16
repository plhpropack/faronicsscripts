copy \\w2k16adfs\wu$\Certificates\PropackRootCA.crt c:\PLH\PropackRootCA.crt
copy \\w2k16adfs\wu$\Certificates\PropackRootCA.ps1 c:\PLH\PropackRootCA.ps1
powershell -ExecutionPolicy UnRestricted -file C:\plh\PropackRootCA.ps1
del "c:\PLH\PropackRootCA.crt"
del "c:\PLH\PropackRootCA.ps1"
