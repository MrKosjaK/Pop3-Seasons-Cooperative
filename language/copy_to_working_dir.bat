@echo off

SET curr_path=%CD%
SET working_dir=%LocalAppData%\Bullfrog\Populous\Language

ECHO Copying language files into working folder!

COPY "%curr_path%\LangStrRep00.ini" "%working_dir%"

ECHO Finished copying!

PAUSE