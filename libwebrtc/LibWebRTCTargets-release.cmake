#----------------------------------------------------------------
# CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "webrtc" for configuration "Release"
set_property(TARGET webrtc APPEND PROPERTY IMPORTED_CONFIGURATIONS Release)

if (MSVC)
  set(_WEBRTC_LIBRARY_PATH "${_IMPORT_PREFIX}/lib/webrtc.lib")
else ()
  set(_WEBRTC_LIBRARY_PATH "${_IMPORT_PREFIX}/lib/libwebrtc.a")
endif ()

set_target_properties(webrtc PROPERTIES IMPORTED_LOCATION_RELEASE "${_WEBRTC_LIBRARY_PATH}")

list(APPEND _IMPORT_CHECK_TARGETS webrtc)
list(APPEND _IMPORT_CHECK_FILES_FOR_webrtc "${_WEBRTC_LIBRARY_PATH}")

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
