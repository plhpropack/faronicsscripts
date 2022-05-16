copy \\w2k16adfs\wu$\Certificates\PropackRootCA.crt c:\PLH\PropackRootCA.crt
Import-Certificate -FilePath "C:\plh\ProopackRootCA.crt" -CertStoreLocation Cert:\LocalMachine\Root
del "c:\PLH\PropackRootCA.crt"
