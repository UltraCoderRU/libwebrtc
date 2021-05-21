if (BUILD_DEB_PACKAGE)
	set(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH INTERNAL FORCE)
endif ()

# Prepare CMake exports
configure_file(LibWebRTCConfig.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfig.cmake @ONLY)
configure_file(LibWebRTCConfigVersion.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfigVersion.cmake @ONLY)
configure_file(LibWebRTCTargets.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCTargets.cmake @ONLY)

######################
#  INSTALL SECTION
######################

# Install headers
install(DIRECTORY
	"${WEBRTC_SOURCE_DIR}/api"
	"${WEBRTC_SOURCE_DIR}/base"
	"${WEBRTC_SOURCE_DIR}/call"
	"${WEBRTC_SOURCE_DIR}/common_audio"
	"${WEBRTC_SOURCE_DIR}/common_video"
	"${WEBRTC_SOURCE_DIR}/logging"
	"${WEBRTC_SOURCE_DIR}/media"
	"${WEBRTC_SOURCE_DIR}/modules"
	"${WEBRTC_SOURCE_DIR}/p2p"
	"${WEBRTC_SOURCE_DIR}/pc"
	"${WEBRTC_SOURCE_DIR}/rtc_base"
	"${WEBRTC_SOURCE_DIR}/system_wrappers"
	DESTINATION "include/webrtc"
	FILES_MATCHING PATTERN "*.h"
)

if (EXISTS "${WEBRTC_SOURCE_DIR}/common_types.h")
	install(FILES "${WEBRTC_SOURCE_DIR}/common_types.h" DESTINATION "include/webrtc")
endif ()

install(DIRECTORY "${WEBRTC_SOURCE_DIR}/third_party/jsoncpp"
	DESTINATION "include/webrtc/third_party"
	FILES_MATCHING PATTERN "*.h"
)

install(DIRECTORY "${WEBRTC_SOURCE_DIR}/third_party/libyuv"
	DESTINATION "include/webrtc/third_party"
	FILES_MATCHING PATTERN "*.h"
)

install(DIRECTORY "${WEBRTC_SOURCE_DIR}/third_party/abseil-cpp/absl"
	DESTINATION "include/webrtc"
	FILES_MATCHING PATTERN "*.h"
)

# Install pdb files
if (MSVC)
	# TODO: fix install on first run
	file(GLOB_RECURSE PDB_FILES "${WEBRTC_BUILD_DIR}/Debug/*.pdb")
	install(FILES DESTINATION lib CONFIGURATIONS Debug)
endif()

# Install library
if (WIN32)
	set(LIBRARY_FILENAME_DEBUG "webrtcd.lib")
	set(LIBRARY_FILENAME_RELEASE "webrtc.lib")
else()
	set(LIBRARY_FILENAME_DEBUG "libwebrtcd.a")
	set(LIBRARY_FILENAME_RELEASE "libwebrtc.a")
endif()
if (CMAKE_GENERATOR MATCHES "Visual Studio")
	install(FILES ${WEBRTC_BUILD_DIR}/Debug/obj/webrtc.lib DESTINATION lib RENAME "webrtcd.lib" CONFIGURATIONS Debug)
	install(FILES ${WEBRTC_BUILD_DIR}/Release/obj/webrtc.lib DESTINATION lib CONFIGURATIONS Release)
else ()
	if (CMAKE_BUILD_TYPE STREQUAL "Debug")
		if (WIN32)
			install(FILES ${WEBRTC_BUILD_DIR}/obj/webrtc.lib DESTINATION lib RENAME "webrtcd.lib")
		else()
			install(FILES ${WEBRTC_BUILD_DIR}/obj/libwebrtc.a DESTINATION lib RENAME "libwebrtcd.a")
		endif()
	else ()
		if (WIN32)
			install(FILES ${WEBRTC_BUILD_DIR}/obj/webrtc.lib DESTINATION lib)
		else()
			install(FILES ${WEBRTC_BUILD_DIR}/obj/libwebrtc.a DESTINATION lib)
		endif()
	endif ()
endif ()

install(FILES
	UseLibWebRTC.cmake
	${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfig.cmake
	${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfigVersion.cmake
	${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCTargets.cmake
	DESTINATION "lib/cmake/LibWebRTC"
)

if (CMAKE_GENERATOR MATCHES "Visual Studio")
	install(FILES LibWebRTCTargets-debug.cmake DESTINATION "lib/cmake/LibWebRTC" CONFIGURATIONS Debug)
	install(FILES LibWebRTCTargets-release.cmake DESTINATION "lib/cmake/LibWebRTC" CONFIGURATIONS Release)
else ()
	if (CMAKE_BUILD_TYPE STREQUAL "Debug")
		install(FILES LibWebRTCTargets-debug.cmake DESTINATION "lib/cmake/LibWebRTC")
	else ()
		install(FILES LibWebRTCTargets-release.cmake DESTINATION "lib/cmake/LibWebRTC")
	endif ()
endif ()

if (BUILD_DEB_PACKAGE)
	set(CPACK_GENERATOR "DEB")
	set(CPACK_PACKAGE_NAME "libwebrtc-dev")
	set(CPACK_PACKAGE_VENDOR "Kirill Kirilenko")
	set(CPACK_PACKAGE_CONTACT "Kirill Kirilenko <kirill@ultracoder.org>")
	set(CPACK_PACKAGE_VERSION_MAJOR ${WEBRTC_VERSION})
	set(CPACK_PACKAGE_VERSION_MINOR "")
	set(CPACK_PACKAGE_VERSION_PATCH "")
	set(CPACK_PACKAGE_DESCRIPTION "WebRTC static library and header files")
	set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/UltraCoderRU/libwebrtc")
	set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${WEBRTC_VERSION}")
	set(CPACK_DEBIAN_PACKAGE_DEPENDS "")
	include(CPack)
endif ()
