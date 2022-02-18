t@(SETLOCAL
  ECHO OFF
  SET "_Path=C:\Users\inkjet\AppData\Local\Temp\"
)

REM Delete all Subdirectories and their File Contents
FOR /F "delims=:" %%_ IN ('
  dir /B /A:D "%_Path%*" ') do (
  RD /S /Q "%_Path%%%_\")

REM Delete all files in Root Folder:
DEL /F /Q  "%_Path%*" & DEL /F /Q /A:H "%_Path%*"
