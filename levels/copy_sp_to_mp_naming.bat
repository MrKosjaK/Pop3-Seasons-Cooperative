@echo off

SET curr_path=%~dp0

ECHO Copying single player formatted levels into multiplayer ones!

COPY "%curr_path%\levl2001.dat" "%curr_path%\levl2080.dat"
COPY "%curr_path%\levl2002.dat" "%curr_path%\levl2082.dat"
COPY "%curr_path%\levl2003.dat" "%curr_path%\levl2083.dat"
COPY "%curr_path%\levl2004.dat" "%curr_path%\levl2084.dat"

COPY "%curr_path%\levl2005.dat" "%curr_path%\levl2094.dat"
COPY "%curr_path%\levl2006.dat" "%curr_path%\levl2100.dat"
COPY "%curr_path%\levl2007.dat" "%curr_path%\levl2109.dat"
COPY "%curr_path%\levl2008.dat" "%curr_path%\levl2110.dat"

COPY "%curr_path%\levl2009.dat" "%curr_path%\levl2111.dat"
COPY "%curr_path%\levl2010.dat" "%curr_path%\levl2112.dat"
COPY "%curr_path%\levl2011.dat" "%curr_path%\levl2120.dat"
COPY "%curr_path%\levl2012.dat" "%curr_path%\levl2127.dat"

COPY "%curr_path%\levl2013.dat" "%curr_path%\levl2128.dat"
COPY "%curr_path%\levl2014.dat" "%curr_path%\levl2131.dat"
COPY "%curr_path%\levl2015.dat" "%curr_path%\levl2133.dat"
COPY "%curr_path%\levl2016.dat" "%curr_path%\levl2134.dat"

ECHO Finished copying!

PAUSE