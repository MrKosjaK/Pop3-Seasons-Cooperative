@echo off

ECHO Preparing workspace for online testing...

:: Path setup
SET CURR_PATH=%~dp0
SET WORK_DIR=%LocalAppData%\Bullfrog\Populous
SET LVL_PATH=%CURR_PATH%levels
SET LANG_PATH=%CURR_PATH%language
SET OBJ_PATH=%CURR_PATH%objects
SET SCR_PATH=%CURR_PATH%scripts
SET SND_PATH=%CURR_PATH%sounds
SET DATA_PATH=%CURR_PATH%data

:: Data
ECHO.
ECHO Copying data files...

:: Language
ECHO.
ECHO Copying language files...

COPY "%LANG_PATH%\LangStrRep00.ini" "%WORK_DIR%\language"

:: Levels
ECHO.
ECHO Copying level files...

COPY "%LVL_PATH%\levl2080.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2082.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2083.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2084.dat" "%WORK_DIR%\levels"

COPY "%LVL_PATH%\levl2094.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2100.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2109.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2110.dat" "%WORK_DIR%\levels"

COPY "%LVL_PATH%\levl2111.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2112.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2120.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2127.dat" "%WORK_DIR%\levels"

COPY "%LVL_PATH%\levl2128.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2131.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2133.dat" "%WORK_DIR%\levels"
COPY "%LVL_PATH%\levl2134.dat" "%WORK_DIR%\levels"

:: Objects
ECHO.
ECHO Copying object files...

:: Scripts
ECHO.
ECHO Copying lua script files...
COPY "%SCR_PATH%\globals.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\common.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\level_1.lua" "%WORK_DIR%\scripts"

:: Sound
ECHO.
ECHO Copying sound files...

ECHO.
ECHO Finished preparing for online testing!

PAUSE