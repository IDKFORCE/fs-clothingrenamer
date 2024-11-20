@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION


:: Check if I've been opened with anything
IF "%~1" == "" GOTO :ERROR_NOFOLDER


:: Environment variables
FOR %%I IN ("%~1") DO SET target_foldername=%%~nxI
SET /A total_filecount = 0
SET /A renamed_filecount = 0
SET /A skipped_filecount = 0
SET /A backup_foldercount = 0


:: Find out how many files would be affected
FOR /F "delims=|" %%D IN ('DIR /A:D /B "%~1"') DO (
    FOR /F "delims=|" %%F IN ('DIR /B "%~1\%%D"') DO (
        SET /A total_filecount += 1
    )
)


:: No files detected
IF %total_filecount% EQU 0 (
    CLS
    ECHO You told me to convert "%~1"
    ECHO That directory does not contain anything though.
    PAUSE
    EXIT
)


:: Main menu thing
:MAIN_MENU
CLS
ECHO Executing Convertion "%~1"
ECHO This Will Affect %total_filecount% File(s).
ECHO.
ECHO Please Choose One Of The Options Below:
ECHO 1) Make Backup Before Renaming [Recomended]
ECHO 2) Rename Original Files [Not Recomended]
ECHO 3) Cancel
CHOICE /C 123 /N
IF %errorlevel% == 1 GOTO :COPY_FOLDER
IF %errorlevel% == 2 GOTO :RENAME_CONFIRMATION
IF %errorlevel% == 3 GOTO :CANCEL


:: Copy Folder (Check If The Copy Folder Already Exists)
:COPY_FOLDER
CLS
IF EXIST "%~1_BAK_%backup_foldercount%\" (
    CLS
    SET /A backup_foldercount += 1
    GOTO :COPY_FOLDER
) ELSE (
    ROBOCOPY "%~1" "%~1_BAK_%backup_foldercount%" /E /NS /NC /NFL
    GOTO :RENAME
)


:: Checking For Confirmation
:RENAME_CONFIRMATION
CLS
ECHO Are You Sure You Want To Fucking Rename The Original Fucking Files? This Can Not Be Fucking Undone! [Choose wisely]
ECHO.
ECHO 1) Fuck Yes I' Know What The Fuck Im Doing! [Continue]
ECHO 2) Fuck No, Abort. [Go Back]
CHOICE /C 12 /N
IF %errorlevel% == 1 GOTO :RENAME
IF %errorlevel% == 2 GOTO :MAIN_MENU


:: Checking And Renaming
:RENAME
CLS
ECHO Checking And Renaming Files, Please Wait...
FOR /F "delims=|" %%D IN ('DIR /A:D /B "%~1"') DO (
    FOR /F "delims=|" %%F IN ('DIR /B "%~1\%%D"') DO (
        ECHO %%F | FINDSTR "%%D" > NUL
        IF errorlevel 1 (
            RENAME "%~1\%%D\%%F" "%%D^%%F"
            SET /A renamed_filecount += 1
        ) ELSE (
            SET /A skipped_filecount += 1
        )
    )
)
CLS
ECHO Successfully renamed %renamed_filecount% file(s).
ECHO %skipped_filecount% were skipped.
PAUSE
EXIT


:: Cancel/SelfCrash
:CANCEL
CLS
ECHO Task Failed Successfully Your Officially Stupid Dont Stop Me Mid Way While I Was Doing Your Work Loser.
PAUSE
EXIT


:: No Such Folder Detected.
:ERROR_NOFOLDER
CLS
ECHO You Have To Fucking Drag And Drop The Fucking 'stream' Folder Onto [fs-clothingrenamer.bat],
ECHO Otherwise It Wont Fucking Work.
PAUSE
EXIT
