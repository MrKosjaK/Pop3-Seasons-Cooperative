@echo off

SET curr_path=%~dp0
SET working_dir=%LocalAppData%\Bullfrog\Populous\Levels

ECHO Copying multiplayer levels into working folder!

COPY "%curr_path%levl2080.dat" "%working_dir%"
COPY "%curr_path%levl2082.dat" "%working_dir%"
COPY "%curr_path%levl2083.dat" "%working_dir%"
COPY "%curr_path%levl2084.dat" "%working_dir%"

COPY "%curr_path%levl2094.dat" "%working_dir%"
COPY "%curr_path%levl2100.dat" "%working_dir%"
COPY "%curr_path%levl2109.dat" "%working_dir%"
COPY "%curr_path%levl2110.dat" "%working_dir%"

COPY "%curr_path%levl2111.dat" "%working_dir%"
COPY "%curr_path%levl2112.dat" "%working_dir%"
COPY "%curr_path%levl2120.dat" "%working_dir%"
COPY "%curr_path%levl2127.dat" "%working_dir%"

COPY "%curr_path%levl2128.dat" "%working_dir%"
COPY "%curr_path%levl2131.dat" "%working_dir%"
COPY "%curr_path%levl2133.dat" "%working_dir%"
COPY "%curr_path%levl2134.dat" "%working_dir%"

ECHO Finished copying!

PAUSE