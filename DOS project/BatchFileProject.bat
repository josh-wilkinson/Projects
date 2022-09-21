@ECHO OFF
cls
ECHO This is a project by Josh W. and JMcD
ECHO TASK 1 by Josh W.
ECHO TASK 2 by Josh W.
ECHO TASK 3 by JMcD
ECHO TAsk 4 by JMcD
ECHO TASK 5 by Josh W.
ECHO Task 6 by Josh W.
ECHO TASK 7 by JMcD
ECHO TASK 8 by JMcD
ECHO TASK 9 by Josh W.
ECHO TASK 10 by Josh W.
ECHO.

pause
:MENU
cls

ECHO.
ECHO ......................................................
ECHO PRESS 1, 2 OR 3 to select your task, press 9 to exit.
ECHO ......................................................
ECHO.
ECHO 1 - Display User/PC Info
ECHO 2 - Check/Create Directory Structure
ECHO 3 - Create Logfile
ECHO 4 - Backup Logfile
ECHO 5 - File Comparison
ECHO 6 - View File Attributes
ECHO 7 - View Folder Permissions
ECHO 8 - List Non-System Processes
ECHO.
ECHO 9 - Exit
ECHO.
ECHO Type your preferred option and then press Enter...

REM This is what brings you to the other parts of the program
SET /P M=Type 1, 2, 3, 4, 5, 6, 7, 8 and 9, then press ENTER: 
IF %M%==1 GOTO INFO
IF %M%==2 GOTO STRUCTURE
IF %M%==3 GOTO CLOG
IF %M%==4 GOTO BLOG
IF %M%==5 GOTO FILECOMP
IF %M%==6 GOTO FILEATT
IF %M%==7 GOTO FOLDPER
IF %M%==8 GOTO NONSYSPRO
IF %M%==9 GOTO :YESORNO
IF %M%==66 GOTO ORDER66

GOTO MENU

REM Jake, this is where you type your program code

:INFO
cls
REM --Code for Information--
ECHO Hello %username%, you are currently logged into 
hostname
@ECHO It is %time%, on %date%.
pause
GOTO MENU

:STRUCTURE
cls
REM --Code for STRUCTURE--
IF NOT EXIST "C:\Batch\Logs" ECHO "Attempting to create directory"
IF NOT EXIST "C:\Backup\Logs" ECHO "Attempting to create directory"
IF NOT EXIST "C:\Batch\Logs" mkdir C:\Batch\Logs 
IF NOT EXIST "C:\Backup\Logs" mkdir C:\Backup\Logs 
IF EXIST C:\Batch\Logs ECHO "Batch Logs Directory Was Successfully Created..."
IF EXIST C:\Backup\Logs ECHO "Backup Logs Directory Was Successfully Created..."
pause
GOTO MENU

:CLOG
cls
@ECHO OFF
REM --Code for Create Log--
ECHO Adding to log file...
ECHO %username% %date% %time%  >> C:\Batch\Logs\logfile.txt 
hostname >> C:\Batch\Logs\logfile.txt
IF EXIST C:\Batch\Logs\logfile.txt ECHO Log file successfully created!
pause
GOTO MENU

:BLOG
cls
REM --Code for Backup Logfile--
REM Makes a simple copy/backup
@ECHO OFF
ECHO %date%, %time%.
COPY C:\Batch\Logs\logfile.txt C:\Backup\Logs\
pause
GOTO MENU

:FILECOMP
cls
REM --Code for File Comparison--
fc C:\Batch\Logs\logfile.txt C:\Backup\Logs\logfile.txt
pause
GOTO MENU

:FILEATT
cls
REM --Code for File Attribute--
ECHO Displaying the files attributes...
FOR %%? IN (C:\Batch\Logs\logfile.txt) DO (
	ECHO File Name Only       : %%~n?
	ECHO File Extension       : %%~x?
	ECHO Name in 8.3 notation : %%~sn?
	ECHO Located on Drive     : %%~d?
	ECHO File Size            : %%~z?
	ECHO Last-Modified Date   : %%~t?
	ECHO Parent Folder        : %%~dp?
	ECHO Fully Qualified Path : %%~f?
	ECHO FQP in 8.3 notation  : %%~sf?
	ECHO Location in the PATH : %%~dp$PATH:?
)
pause
GOTO MENU

:FOLDPER
cls
ECHO "Displaying folder permissions..."
iCACLS C:\Backup\Logs
REM !Each letter in brackets is important (like (OI) ---> Object inheiritance)
pause
GOTO MENU

:NONSYSPRO
cls
REM --Code for Non-System Processes--
REM There shouldn't be any system processes shown.
TASKLIST /v /fi "STATUS eq running"
pause
GOTO MENU

:YESORNO
cls
REM Here is where it asks you if you're sure you want to exit the program
SET /P AREYOUSURE=Are you sure (Y/[N])? 
IF /I "%AREYOUSURE%" NEQ "N" GOTO :END
IF /I "%AREYOUSURE%" NEQ "Y" GOTO :MENU

:ORDER66
cls
ECHO Executing order 66...
start https://www.youtube.com/watch?v=xSN6BOgrSSU
pause
GOTO MENU

:END
GOTO :EOF
REM This exits the program









