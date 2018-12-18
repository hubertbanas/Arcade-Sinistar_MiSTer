@echo off

set    zip=sinistar.zip
set ifiles=sinistar.10+sinistar.10+sinistar.11+sinistar.01+sinistar.02+sinistar.03+sinistar.04+sinistar.05+sinistar.06+sinistar.07+sinistar.08+sinistar.09+sinistar.snd+decoder.4+decoder.6
set  ofile=a.sinistar.rom

rem =====================================
setlocal ENABLEDELAYEDEXPANSION

set pwd=%~dp0
echo.
echo.

if EXIST %zip% (

	!pwd!7za x -otmp %zip%
	if !ERRORLEVEL! EQU 0 ( 
		cd tmp

		copy /b/y %ifiles% !pwd!%ofile%
		if !ERRORLEVEL! EQU 0 ( 
			echo.
			echo ** done **
			echo.
			echo Copy "%ofile%" into root of SD card
		)
		cd !pwd!
		rmdir /s /q tmp
	)

) else (

	echo Error: Cannot find "%zip%" file
	echo.
	echo Put "%zip%", "7za.exe" and "%~nx0" into the same directory
)

echo.
echo.
pause
