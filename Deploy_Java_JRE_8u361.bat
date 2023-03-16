@cls
@echo off
setlocal ENABLEDELAYEDEXPANSION

set ProgramName=Java  
set ZLocation="%ProgramFiles%"
set YLocation="%ProgramFiles(x86)%"
set RegKey64="HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JavaSoft\Java Runtime Environment"
set RegKey32="HKEY_LOCAL_MACHINE\SOFTWARE\JavaSoft\Java Runtime Environment"
set DesiredVersion=1.8.0_361
set DeployDirectory=\\domain.com\netlogon\software\Java-JRE-8u361
set exe32Name=jre-8u361-windows-i586.msi
set exe64Name=jre-8u361-windows-x64.msi

call :TestIfAdmin
call :TestArchitecture
call :InstallProgram64
call :InstallProgram32
goto :EndScript

:TestIfAdmin
if exist "%SystemRoot%\system32\TempDeleteMeAdminTestFolder" ( rmdir "%SystemRoot%\system32\TempDeleteMeAdminTestFolder" )
mkdir "%SystemRoot%\system32\TempDeleteMeAdminTestFolder" 2>nul
if "%errorlevel%" == "0" (
	rmdir "%SystemRoot%\system32\TempDeleteMeAdminTestFolder" & goto :eof
) else (
	goto :EndScript
)

:TestArchitecture
if not exist %YLocation% (
	set x64sys=no
	goto :Test32
) else (
	goto :Test64
	)

:Test32
if not exist %ZLocation%\%ProgramName% (
	set x32sys=yes
	goto :InstallProgram32
) 	else (
	goto :TestVersion32
	)

:Test64
if not exist %ZLocation%\%ProgramName% (
	goto :TestIfNeed32on64
) else (
	goto :TestVersion64
	)

:TestIfNeed32on64
if not exist %YLocation%\%ProgramName% (
	set x64sys=yes
	goto :InstallProgram64
) else (
	goto :Test32VersionOn64
)

:Test32VersionOn64
reg query %RegKey64% | findstr %DesiredVersion%
if %errorlevel%==0 (
	set x32sys=no
	goto :eof
)	else (
	set x32sys=yes
	goto :eof
)

:TestVersion64
reg query %RegKey32% | findstr %DesiredVersion%
if %errorlevel%==0 (
	set x64sys=no
	goto :TestIfNeed32on64
) else (
	set x64sys=yes
	goto :TestIfNeed32on64
)

:TestVersion32
reg query %RegKey32% | findstr %DesiredVersion%
if %errorlevel%==0 (
	goto :EndScript
) else (
	set x32sys=yes
	goto :eof
)

:InstallProgram64
if %x64sys%==yes (
copy %DeployDirectory%\%exe64Name% %windir%\temp
start /wait msiexec /i %windir%\temp\%exe64Name% INSTALL_SILENT=Enable EULA=Disable WEB_JAVA=Enable WEB_JAVA_SECURITY_LEVEL=H AUTO_UPDATE=Disable /quiet /norestart
goto :eof
) else (
goto :eof
)

:InstallProgram32
if %x32sys%==yes (
copy %DeployDirectory%\%exe32Name% %windir%\temp
start /wait msiexec /i %windir%\temp\%exe32Name% INSTALL_SILENT=Enable EULA=Disable WEB_JAVA=Enable WEB_JAVA_SECURITY_LEVEL=H AUTO_UPDATE=Disable /quiet /norestart
goto :eof
) else (
goto :eof
)

:EndScript
endlocal
exit