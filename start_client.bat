@echo off

ECHO Welcome to the Seasons Co-Op Connecting setup script!
ECHO Follow through instructions to configure settings.
ECHO.
ECHO.

SET NICK=Player
SET PORT=7575
SET IP=127.0.0.1
SET PLAYER_NUM=1

SET CURR_PATH="%~dp0..\..\"
PUSHD %CURR_PATH%
SET CURR_PATH=%CD%

SET /p IP=Enter IPv4 address of the server (default: 127.0.0.1):

Echo IPv4 address is set to: %IP%
ECHO.

SET /p PORT=Enter port of the server (default: 7575):

ECHO Port is set to: %PORT%
ECHO.

SET /p NICK=Enter your player nickname (default: Player):

ECHO Nickname is set to: %NICK%
ECHO.

SET /p PLAYER_NUM=Enter the num of the tribe to play as (1 = Blue, 2 = Red, 3 = Yellow etc...):

ECHO Tribe is set to: %PLAYER_NUM%
ECHO.

START "" "%CURR_PATH%\pop3.exe" /j %IP%:%PORT% /n %NICK% /pn %PLAYER_NUM% /mod Pop3-Seasons-Cooperative /multi 
POPD

ECHO Launching game as client...