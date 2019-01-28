---------------------------------------------------------------------------------
-- Arcade: Sinistar for MiSTer by Sorgelig.
-- 18 December 2018
---------------------------------------------------------------------------------
-- cpu09l - Version : 0128
-- Synthesizable 6809 instruction compatible VHDL CPU core
-- Copyright (C) 2003 - 2010 John Kent
---------------------------------------------------------------------------------
-- cpu68 - Version 9th Jan 2004 0.8
-- 6800/01 compatible CPU core 
-- GNU public license - December 2002 : John E. Kent
---------------------------------------------------------------------------------
--
-- This port is only possible because of previous work by many many others - Thank You
-- to find out more search "Williams robotron" on a search engine.  
-- 
-- 
-- Keyboard players inputs :
--
--   F10   : Advance
--   F9    : Auto up
--   F7    : High score reset
--
--   F4    : Add coin right
--   F3    : Add coin left
--   F2    : Start 2 players
--   F1    : Start 1 player
--
--   UP    : move up
--   Down  : move Down
--   Left  : move Left
--   Right : move right
--   Ctrl  : fire
--   Space : bomb
--
--
-- Joystick support. Analog stick can be used for precise turn/move.
-- 
-- Issues:
--  * Speach chip isn't implemented
--  * Has sporadic graphical glitches (not preventing the gameplay)
-- 
---------------------------------------------------------------------------------

                                *** Attention ***

ROM is not included. In order to use this arcade, you need to provide a correct ROM file.

Find this zip file somewhere. You need to find the file exactly as required.
Do not rename other zip files even if they also represent the same game - they are not compatible!
The name of zip is taken from M.A.M.E. project, so you can get more info about
hashes and contained files there.

To generate the ROM using Windows:
1) Copy the zip into "releases" directory
2) Execute bat file - it will show the name of zip file containing required files.
3) Put required zip into the same directory and execute the bat again.
4) If everything will go without errors or warnings, then you will get the a.*.rom file.
5) Copy generated a.*.rom into root of SD card along with the Arcade-*.rbf file

To generate the ROM using Linux/MacOS:
1) Copy the zip into "releases" directory
2) Execute build_rom.sh
3) Copy generated a.*.rom into root of SD card along with the Arcade-*.rbf file

To generate the ROM using MiSTer:
1) scp "releases" directory along with the zip file onto MiSTer:/media/fat/
2) Using OSD execute build_rom.sh
3) Copy generated a.*.rom into root of SD card along with the Arcade-*.rbf file
