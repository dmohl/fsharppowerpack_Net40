@if "%_echo%"=="" echo off

set _SCRIPT_DRIVE=%~d0
set _SCRIPT_PATH=%~p0
set _SCRIPT_ROOT=%_SCRIPT_DRIVE%%_SCRIPT_PATH%

set PATH=%ProgramFiles%\Microsoft SDKs\Windows\v6.0A\bin;%ProgramFiles%\Microsoft Visual Studio 9.0\Common7\IDE;%_SCRIPT_ROOT%\tools\win86\vc;%_SCRIPT_ROOT%\tools\win86\masm611\bin;%_SCRIPT_ROOT%\Release\bin;%_SCRIPT_ROOT%\Proto\built\bin;%SystemRoot%\Microsoft.NET\Framework\v3.5;%SystemRoot%\Microsoft.NET\Framework\v2.0.50727;%PATH%

set LIB=%_SCRIPT_ROOT%\tools\win86\vc\lib
set FSHARP_HOME=%_SCRIPT_ROOT%

set TARGETFSHARP=VS2008

color 6
title "%_SCRIPT_ROOT% Test Environment"
