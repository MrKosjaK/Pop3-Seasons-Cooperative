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
COPY "%DATA_PATH%\hfx0-0.dat" "%WORK_DIR%\data"

:: Language
ECHO.
ECHO Copying language files...

COPY "%LANG_PATH%\LangStrRep00.ini" "%WORK_DIR%\language"

:: Levels
ECHO.
ECHO Converting singleplayer levels into multiplayer levels...

COPY "%LVL_PATH%\levl2001.dat" "%LVL_PATH%\levl2080.dat"
COPY "%LVL_PATH%\levl2002.dat" "%LVL_PATH%\levl2082.dat"
COPY "%LVL_PATH%\levl2003.dat" "%LVL_PATH%\levl2083.dat"
COPY "%LVL_PATH%\levl2004.dat" "%LVL_PATH%\levl2084.dat"

COPY "%LVL_PATH%\levl2005.dat" "%LVL_PATH%\levl2094.dat"
COPY "%LVL_PATH%\levl2006.dat" "%LVL_PATH%\levl2100.dat"
COPY "%LVL_PATH%\levl2007.dat" "%LVL_PATH%\levl2109.dat"
COPY "%LVL_PATH%\levl2008.dat" "%LVL_PATH%\levl2110.dat"

COPY "%LVL_PATH%\levl2009.dat" "%LVL_PATH%\levl2111.dat"
COPY "%LVL_PATH%\levl2010.dat" "%LVL_PATH%\levl2112.dat"
COPY "%LVL_PATH%\levl2011.dat" "%LVL_PATH%\levl2120.dat"
COPY "%LVL_PATH%\levl2012.dat" "%LVL_PATH%\levl2127.dat"

COPY "%LVL_PATH%\levl2013.dat" "%LVL_PATH%\levl2128.dat"
COPY "%LVL_PATH%\levl2014.dat" "%LVL_PATH%\levl2131.dat"
COPY "%LVL_PATH%\levl2015.dat" "%LVL_PATH%\levl2133.dat"
COPY "%LVL_PATH%\levl2016.dat" "%LVL_PATH%\levl2134.dat"

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

:: Levels
COPY "%SCR_PATH%\level_1.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\level_2.lua" "%WORK_DIR%\scripts"

:: Level's Database
COPY "%SCR_PATH%\lvl1_ai_func.lua" "%WORK_DIR%\scripts"

::Misc
COPY "%SCR_PATH%\globals.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\common.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\assets.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\weather.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\game_lobby.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\game_state.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\gui.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\popscript.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\turnclock.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\searcharea.lua" "%WORK_DIR%\scripts"
COPY "%SCR_PATH%\ai_shaman.lua" "%WORK_DIR%\scripts"

:: Sound
ECHO.
ECHO Copying sound files...

ECHO.
ECHO Finished preparing for online testing!