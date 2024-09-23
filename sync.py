#!/usr/bin/env python3

import os
import sys
import subprocess
from pathlib import Path


def execute(command: str):
    subprocess.run(command, shell=True, check=True)


def get_output(command: str):
    return subprocess.run(command, capture_output=True, shell=True, check=True).stdout.decode()


# To determine last stable WebRTC revision,
# see https://chromiumdash.appspot.com/branches
# and https://chromiumdash.appspot.com/schedule
WEBRTC_REVISION = 4692

if len(sys.argv) == 2:
    WEBRTC_REVISION = sys.argv[1]

REPO_ROOT = Path(__file__).resolve().parent
DEPOT_TOOLS_DIR = REPO_ROOT / 'depot_tools'
WEBRTC_DIR = REPO_ROOT / 'webrtc'
SRC_DIR = WEBRTC_DIR / 'src'

os.environ['PATH'] = '{}{}{}'.format(DEPOT_TOOLS_DIR, os.pathsep, os.environ['PATH'])
if sys.platform == 'win32':
    os.environ['DEPOT_TOOLS_WIN_TOOLCHAIN'] = '0'

os.chdir(REPO_ROOT)
if not os.path.isdir(DEPOT_TOOLS_DIR):
    print('Cloning Depot Tools...')
    execute('git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git')
    os.chdir(DEPOT_TOOLS_DIR)

    if sys.platform == 'win32':
        execute('gclient --version')
        execute('where python')

    execute('python update_depot_tools_toggle.py --disable')
else:
    print('Updating Depot Tools to the latest revision...')
    os.chdir(DEPOT_TOOLS_DIR)
    execute('git checkout -q -f main')
    execute('git pull -q')

if not os.path.isdir(WEBRTC_DIR):
    print('Cloning WebRTC...')
    os.mkdir(WEBRTC_DIR)
    os.chdir(WEBRTC_DIR)
    execute('fetch --nohooks webrtc')
    os.chdir(SRC_DIR)
    execute('gclient sync --with_branch_heads --nohooks')
else:
    print('Updating WebRTC branches info...')
    os.chdir(SRC_DIR)
    execute('gclient sync --with_branch_heads --nohooks')

# Latest Depot Tools versions are not compatible
# with old WebRTC versions, so we peek revision
# from around the same time as the WebRTC and
# forbid gclient to auto-update Depot Tools.
os.chdir(SRC_DIR)
LAST_WEBRTC_COMMIT_DATE = get_output('git log -n 1 --pretty=format:%ci branch-heads/{}'.format(WEBRTC_REVISION)).strip()
os.chdir(DEPOT_TOOLS_DIR)
DEPOT_TOOLS_COMPATIBLE_REVISION = get_output('git rev-list -n 1 --before="{}" main'.format(LAST_WEBRTC_COMMIT_DATE)).strip()
print('Updating Depot Tools to a compatible revision {}...'.format(DEPOT_TOOLS_COMPATIBLE_REVISION))
execute('git checkout -f {}'.format(DEPOT_TOOLS_COMPATIBLE_REVISION))

print('Updating WebRTC to version {}...'.format(WEBRTC_REVISION))
os.chdir(SRC_DIR)
execute('git clean -ffd')
execute('git checkout -q -B {} branch-heads/{}'.format(WEBRTC_REVISION, WEBRTC_REVISION))
execute('gclient sync --force -D --reset')
