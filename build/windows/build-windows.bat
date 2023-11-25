@echo off

SET NSIS="C:\Program Files (x86)\NSIS\makensis.exe"

set SCRIPTDIR=%~dp0
SET OUT_DIR=%SCRIPTDIR%bin
set TMP_DIR=%OUT_DIR%\temp

if not exist %NSIS% (
    echo [!] NSIS not found [%NSIS%]
	echo [!] Install NSIS [https://nsis.sourceforge.io/] and try again.
	goto :error
)

call :copy_files
call :build_nsis_installer

goto :success


:copy_files
    echo [*] Copying files...

    mkdir %TMP_DIR%

    xcopy /E /I /Y "radicalvpnd/radicalvpnd.exe" %TMP_DIR%
    IF not ERRORLEVEL 0 (
        echo [!] Failed to copy files.
        exit /b 1
    )

    goto :eof

:build_nsis_installer
    echo [*] Building NSIS installer...

    mkdir %OUT_DIR%

    set FILE_OUT="%OUT_DIR%/RadicalVPN-Setup.exe"
    %NSIS% /DPRODUCT_VERSION="0.0.1" /DOUT_FILE=%FILE_OUT% /DSOURCE_DIR=%TMP_DIR% "build/windows/RadicalVPN Client.nsi"
    IF not ERRORLEVEL 0 (
		echo [!] Failed to build NSIS installer.
		exit /b 1
	)

    goto :eof

:success
	echo [*] Installer created successfully.
	exit /b 0


:error
	echo [!] Installation failed: #%errorlevel%.
	exit /b %errorlevel%