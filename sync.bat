@echo off

REM To determine last stable WebRTC revision,
REM see https://chromiumdash.appspot.com/branches
REM and https://chromiumdash.appspot.com/schedule
set WEBRTC_REVISION=4280

if not "%1"=="" set WEBRTC_REVISION="%1"

set REPO_ROOT=%~dp0
set PATH=%REPO_ROOT%depot_tools;%PATH%
set DEPOT_TOOLS_WIN_TOOLCHAIN=0

cd %REPO_ROOT%
if not exist "depot_tools" (
    echo Cloning Depot Tools...
    git.exe clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
)

echo Updating Depot Tools...
cd %REPO_ROOT%\depot_tools
call update_depot_tools.bat

cd %REPO_ROOT%
if not exist "webrtc" (
    echo Cloning WebRTC...
    mkdir webrtc
    cd webrtc
    fetch --nohooks --no-history webrtc
)

echo Updating WebRTC to version %WEBRTC_REVISION%...
cd %REPO_ROOT%\webrtc\src
call gclient sync --with_branch_heads
git.exe fetch
git.exe checkout -B %WEBRTC_REVISION% branch-heads/%WEBRTC_REVISION%
call gclient sync --force -D

cd %REPO_ROOT%
