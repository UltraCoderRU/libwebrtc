@echo off

REM To determine last stable WebRTC revision,
REM see https://chromiumdash.appspot.com/branches
REM and https://chromiumdash.appspot.com/schedule
set WEBRTC_REVISION=4280

set DEPOT_TOOLS_COMPATIBLE_REVISION=a964ca1296b

if not "%1"=="" set WEBRTC_REVISION="%1"

set REPO_ROOT=%~dp0

cd "%REPO_ROOT%"
if not exist "depot_tools" (
    echo Cloning Depot Tools...
    git.exe clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    cd "%REPO_ROOT%\depot_tools"
    python.exe update_depot_tools_toggle.py --disable
)

set PATH=%REPO_ROOT%depot_tools;%PATH%
set DEPOT_TOOLS_WIN_TOOLCHAIN=0

if not exist "%REPO_ROOT%\webrtc" (
	echo "Updating Depot Tools to the latest revision..."
	cd "%REPO_ROOT%\depot_tools"
	git.exe checkout -q -f main
    git.exe pull

    echo Cloning WebRTC...
    mkdir "%REPO_ROOT%\webrtc"
    cd "%REPO_ROOT%\webrtc"
    fetch --nohooks webrtc
    cd "%REPO_ROOT%\webrtc\src"
    call gclient sync --nohooks --with_branch_heads
)

REM Latest Depot Tools versions are not compatible
REM with old WebRTC versions, so we peek revision
REM from around the same time as the WebRTC and
REM forbid gclient to auto-update Depot Tools.
cd "%REPO_ROOT%\webrtc\src"
FOR /F "tokens=*" %%g IN ("git.exe log -n 1 --pretty=format:%ci \"branch-heads/%WEBRTC_REVISION%\"") do (SET LAST_WEBRTC_COMMIT_DATE=%%g)
cd "%REPO_ROOT%\depot_tools"
FOR /F "tokens=*" %%g IN ("git rev-list -n 1 --before=\"%LAST_WEBRTC_COMMIT_DATE%\" main") do (SET DEPOT_TOOLS_COMPATIBLE_REVISION=%%g)
echo "Updating Depot Tools to a compatible revision %DEPOT_TOOLS_COMPATIBLE_REVISION%..."
git.exe checkout -q -f %DEPOT_TOOLS_COMPATIBLE_REVISION%

echo Updating WebRTC to version %WEBRTC_REVISION%...
cd %REPO_ROOT%\webrtc\src
call gclient sync --with_branch_heads --reset
git.exe fetch
git.exe checkout -f -B %WEBRTC_REVISION% branch-heads/%WEBRTC_REVISION%
call gclient sync --force -D --reset

cd %REPO_ROOT%


echo Updating Depot Tools...
cd %REPO_ROOT%\depot_tools
call update_depot_tools.bat