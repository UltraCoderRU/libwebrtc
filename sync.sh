#!/bin/bash
set -e

# To determine last stable WebRTC revision,
# see https://chromiumdash.appspot.com/branches
# and https://chromiumdash.appspot.com/schedule
WEBRTC_REVISION=4280

if [ $# -eq 1 ]; then
  WEBRTC_REVISION=$1
fi

REPO_ROOT=$(dirname $(readlink -f $0))
export PATH=${REPO_ROOT}/depot_tools:$PATH

cd ${REPO_ROOT}
if [ ! -d depot_tools ];
then
    echo "Cloning Depot Tools..."
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
fi

echo "Updating Depot Tools..."
cd ${REPO_ROOT}/depot_tools
./update_depot_tools

cd ${REPO_ROOT}
if [ ! -d webrtc ];
then
    echo "Cloning WebRTC..."
    mkdir webrtc
    cd webrtc
    fetch --nohooks --no-history webrtc
fi

echo "Updating WebRTC to version ${WEBRTC_REVISION}..."
cd ${REPO_ROOT}/webrtc/src
gclient sync --with_branch_heads --reset
git fetch
git checkout -B ${WEBRTC_REVISION} branch-heads/${WEBRTC_REVISION}
gclient sync --force -D --reset
