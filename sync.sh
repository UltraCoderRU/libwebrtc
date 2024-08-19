#!/bin/bash
set -e

# To determine last stable WebRTC revision,
# see https://chromiumdash.appspot.com/branches
# and https://chromiumdash.appspot.com/schedule
WEBRTC_REVISION=4692

if [ $# -eq 1 ]; then
    WEBRTC_REVISION=$1
fi

REPO_ROOT=$(dirname $(readlink -f $0))

cd ${REPO_ROOT}
if [ ! -d depot_tools ];
then
    echo "Cloning Depot Tools..."
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
    cd ${REPO_ROOT}/depot_tools
    python update_depot_tools_toggle.py --disable
else
    echo "Updating Depot Tools to the latest revision..."
    cd ${REPO_ROOT}/depot_tools
    git checkout -q -f main
    git pull
fi

export PATH=${REPO_ROOT}/depot_tools:$PATH

if [ ! -d ${REPO_ROOT}/webrtc ];
then
    echo "Cloning WebRTC..."
    mkdir ${REPO_ROOT}/webrtc
    cd ${REPO_ROOT}/webrtc
    fetch --nohooks webrtc
    cd ${REPO_ROOT}/webrtc/src
    gclient sync --nohooks --with_branch_heads
else
    echo "Updating WebRTC branches info..."
    gclient sync --nohooks --with_branch_heads
fi

# Latest Depot Tools versions are not compatible
# with old WebRTC versions, so we peek revision
# from around the same time as the WebRTC and
# forbid gclient to auto-update Depot Tools.
cd ${REPO_ROOT}/webrtc/src
LAST_WEBRTC_COMMIT_DATE=$(git log -n 1 --pretty=format:%ci "branch-heads/${WEBRTC_REVISION}")
cd ${REPO_ROOT}/depot_tools
DEPOT_TOOLS_COMPATIBLE_REVISION=$(git rev-list -n 1 --before="$LAST_WEBRTC_COMMIT_DATE" main)
echo "Updating Depot Tools to a compatible revision ${DEPOT_TOOLS_COMPATIBLE_REVISION}..."
git checkout -q -f ${DEPOT_TOOLS_COMPATIBLE_REVISION}

echo "Updating WebRTC to version ${WEBRTC_REVISION}..."
cd ${REPO_ROOT}/webrtc/src
git clean -ffd
git checkout -B ${WEBRTC_REVISION} branch-heads/${WEBRTC_REVISION}
gclient sync --force -D --reset
