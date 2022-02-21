
reg query HKEY_CLASSES_ROOT\{359C24F1-51B5-44CE-8F2D-2FBB1A0FE4EA}\FWA_GUI_Agent | Find "Name" > c:\plh\pc.txt
reg query HKEY_CLASSES_ROOT\{359C24F1-51B5-44CE-8F2D-2FBB1A0FE4EA}\FWA_GUI_Agent > c:\plh\deploy.txt
 for /f "tokens=3* delims= " %%x in (c:\plh\pc.txt) do type c:\plh\deploy.txt > c:\plh\%%x_DEPLOY.txt
 del "c:\plh\deploy.txt"
 del "c:\plh\pc.txt"
