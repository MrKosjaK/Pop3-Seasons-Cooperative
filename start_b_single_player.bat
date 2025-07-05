@echo off

SET CURR_PATH="%~dp0..\..\"
PUSHD %CURR_PATH%
SET CURR_PATH=%CD%

START "" %CURR_PATH%\pop3b.exe /mod Pop3-Seasons-Cooperative /multi
POPD

ECHO Launching game...