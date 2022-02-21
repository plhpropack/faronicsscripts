reg query HKEY_CLASSES_ROOT\{359C24F1-51B5-44CE-8F2D-2FBB1A0FE4EA}\FWA_GUI_Agent | Find "Name" > c:\plh\pc.txt
 for /f "tokens=3* delims= " %x in (c:\plh\pc.txt) do copy C:\Windows\SoftwareDistribution\ReportingEvents.log \\w2k16adfs\wu$\%x_ReportingEvents.log
del "c:\plh\pc.txt"
