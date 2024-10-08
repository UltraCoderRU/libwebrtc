cmake_minimum_required(VERSION 3.20)

set(CMAKE_CONFIGURATION_TYPES Debug Release CACHE STRING INTERNAL FORCE)

project(libwebrtc)

set(USE_CLANG ON CACHE BOOL "Build using internal Clang compiler (set to OFF to build using system GCC/MSVC)")
set(GN_EXTRA_ARGS "" CACHE STRING "Extra 'gn gen' arguments to pass when configuring WebRTC")
set(NINJA_ARGS "" CACHE STRING "Ninja arguments to pass when compiling WebRTC")
option(BUILD_DEB_PACKAGE "Build .deb package" OFF)

# Allow the use of IN_LIST operand
cmake_policy(SET CMP0057 NEW)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake)

include(FindLibraries)
include(TargetOsAndCpu)

include(Utils)
prependPath("${CMAKE_SOURCE_DIR}/depot_tools")
if (WIN32)
    set(ENV{DEPOT_TOOLS_WIN_TOOLCHAIN} 0)
endif()

set(WEBRTC_SOURCE_DIR "${CMAKE_SOURCE_DIR}/webrtc/src")
set(WEBRTC_BUILD_DIR "${CMAKE_BINARY_DIR}/webrtc")

include(Version)
get_webrtc_version_from_git(WEBRTC_VERSION)
message(STATUS "WebRTC version: ${WEBRTC_VERSION}")

if (MSVC)
    # Always build with dynamic runtime on MSVC
    patch_file(${WEBRTC_SOURCE_DIR}/build/config/win/BUILD.gn ":static_crt" ":dynamic_crt")
endif ()

# Copy all files from 'patches' directory to 'webrtc/src'
# For example, 'patches/api/foo.h' will be copied to 'webrtc/src/api/foo.h'
include(PatchSources)
patch_sources("${CMAKE_CURRENT_SOURCE_DIR}/patches" "${CMAKE_CURRENT_SOURCE_DIR}/webrtc/src")

include(AddWebRTCTarget)
add_webrtc_target(${WEBRTC_SOURCE_DIR} ${WEBRTC_BUILD_DIR})

add_subdirectory(libwebrtc)
