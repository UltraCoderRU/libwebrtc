# libwebrtc [![License][license-img]][license-href]

This repository contains a collection of CMake scripts to help you embed
Google's native WebRTC implementation inside your project as simple as this:

```cmake
cmake_minimum_required(VERSION 3.9)
project(sample)

find_package(LibWebRTC REQUIRED)
include(${LIBWEBRTC_USE_FILE})

set(SOURCE_FILES main.cpp)
add_executable(sample ${SOURCE_FILES})
target_link_libraries(sample ${LIBWEBRTC_LIBRARIES})
```

## Prerequisites

- CMake 3.9 or later
- Python 2.7 (optional for Windows since it will use the interpreter located
  inside the `depot_tools` installation)

### Debian & Ubuntu

- Required development packages:

```
# apt-get install build-essential libglib2.0-dev libgtk2.0-dev libxtst-dev \
                  libxss-dev libpci-dev libdbus-1-dev libgconf2-dev \
                  libgnome-keyring-dev libnss3-dev libasound2-dev libpulse-dev \
                  libudev-dev
```

- GCC & G++ 4.8 or later, for C++11 support

### macOS

- OS X 10.11 or later
- Xcode 7.3.1 or later

### Windows

- Windows 7 x64 or later
- Visual Studio 2015/2017

  Make sure that you install the following components:
  
  - Visual C++, which will select three sub-categories including MFC
  - Universal Windows Apps Development Tools
    - Tools (1.4.1) and Windows 10 SDK (**10.0.14393**)

- [Windows 10 SDK][w10sdk] with **Debugging Tools for Windows** or
  [Windows Driver Kit 10][wdk10] installed in the same Windows 10 SDK
  installation directory.

## Getting sources
Clone the repository and run script to fetch WebRTC sources.
You can pass WebRTC version (branch) to script to fetch specific version.

```
git clone https://github.com/UltraCoderRU/libwebrtc.git
cd libwebrtc
python3 sync.py [WEBRTC_VERSION]
```

## Compiling

Create an output directory, browse inside it, then run CMake to configure project.

```
mkdir build
cd build
cmake -G Ninja -DCMAKE_BUILD_TYPE=<Debug/Release> -DCMAKE_INSTALL_PREFIX=<install_path> ..
```

After configuration build library using standard CMake commands.

```
cmake --build .
cmake --install .
```

The library will be located inside the `lib` subdirectory of the `<install_path>`.
The `include` subdirectory will contain the header files.
CMake scripts will be placed inside the `lib/cmake/LibWebRTC` subdirectory.

## Using WebRTC in your project

To import LibWebRTC into your CMake project use `find_package`:
```cmake
find_package(LibWebRTC REQUIRED)
include(${LIBWEBRTC_USE_FILE})

target_link_libraries(my-app ${LIBWEBRTC_LIBRARIES})
```

You should add library installation path to `CMAKE_INSTALL_PREFIX` variable
while configuring your project:
```
cmake -DCMAKE_PREFIX_PATH=<install_path> ...
```

## Configuration

The library will be compiled and usable on the same host's platform and
architecture. Here are some CMake flags which could be useful if you need to
perform cross-compiling.

- **GN_EXTRA_ARGS**

    Add extra arguments to the `gn gen --args` parameter.

- **NINJA_ARGS**

    Arguments to pass while executing the `ninja` command.

## Status

The following table displays the current state of this project, including
supported platforms and architectures.

<table>
  <tr>
    <td align="center"></td>
    <td align="center">x86</td>
    <td align="center">amd64</td>
    <td align="center">arm</td>
    <td align="center">arm64</td>
  </tr>
  <tr>
    <th align="center">Linux</th>
    <td align="center">-</td>
    <td align="center">✔</td>
    <td align="center">-</td>
    <td align="center">-</td>
  </tr>
  <tr>
    <th align="center">Windows</th>
    <td align="center">-</td>
    <td align="center">✔</td>
    <td align="center">-</td>
    <td align="center">-</td>
  </tr>
  <tr>
    <th align="center">MacOS</th>
    <td align="center">-</td>
    <td align="center">-</td>
    <td align="center">-</td>
    <td align="center">-</td>
  </tr>
  <tr>
    <th align="center">Android</th>
    <td align="center">-</td>
    <td align="center">-</td>
    <td align="center">-</td>
    <td align="center">-</td>
  </tr>
  <tr>
    <th align="center">iOS</th>
    <td align="center">-</td>
    <td align="center">-</td>
    <td align="center">-</td>
    <td align="center">-</td>
  </tr>
</table>


## Acknowledgements

Many thanks to Dr. Alex Gouaillard for being an excellent mentor for this
project.

Everything started from his
«[Automating libwebrtc build with CMake][webrtc-dr-alex-cmake]» blog article,
which was a great source of inspiration for me to create the easiest way to link
the WebRTC library in any native project.

[license-img]:https://img.shields.io/badge/License-Apache%202.0-blue.svg
[license-href]:https://opensource.org/licenses/Apache-2.0
[w10sdk]:https://developer.microsoft.com/en-us/windows/downloads/windows-10-sdk
[wdk10]:https://go.microsoft.com/fwlink/p/?LinkId=526733
[webrtc-dr-alex-cmake]:http://webrtcbydralex.com/index.php/2015/07/22/automating-libwebrtc-build-with-cmake
