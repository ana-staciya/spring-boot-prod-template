@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PROPS_FILE=%SCRIPT_DIR%gradle\wrapper\gradle-wrapper.properties"

if not exist "%PROPS_FILE%" (
  echo Missing %PROPS_FILE%
  exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in ("%PROPS_FILE%") do (
  if /i "%%A"=="distributionUrl" set "DIST_URL=%%B"
)

set "DIST_URL=%DIST_URL:\:=:%"

if "%DIST_URL%"=="" (
  echo distributionUrl is not set in %PROPS_FILE%
  exit /b 1
)

for %%F in ("%DIST_URL%") do set "DIST_ZIP=%%~nxF"
set "DIST_BASE=%DIST_ZIP:.zip=%"
set "DIST_ROOT=%DIST_BASE%"
if /i "%DIST_ROOT:~-4%"=="-bin" set "DIST_ROOT=%DIST_ROOT:~0,-4%"
if /i "%DIST_ROOT:~-4%"=="-all" set "DIST_ROOT=%DIST_ROOT:~0,-4%"

if "%GRADLE_USER_HOME%"=="" set "GRADLE_USER_HOME=%USERPROFILE%\.gradle"

set "DIST_DIR=%GRADLE_USER_HOME%\wrapper\dists\%DIST_BASE%"
set "ZIP_PATH=%DIST_DIR%\%DIST_ZIP%"
set "GRADLE_HOME=%DIST_DIR%\%DIST_ROOT%"

if not exist "%GRADLE_HOME%\bin\gradle.bat" (
  if not exist "%DIST_DIR%" mkdir "%DIST_DIR%"
  if not exist "%ZIP_PATH%" (
    echo Downloading Gradle from %DIST_URL%
    powershell -NoProfile -Command "Invoke-WebRequest -Uri '%DIST_URL%' -OutFile '%ZIP_PATH%'"
    if errorlevel 1 exit /b 1
  )
  powershell -NoProfile -Command "Expand-Archive -Path '%ZIP_PATH%' -DestinationPath '%DIST_DIR%' -Force"
  if errorlevel 1 exit /b 1
)

call "%GRADLE_HOME%\bin\gradle.bat" %*
