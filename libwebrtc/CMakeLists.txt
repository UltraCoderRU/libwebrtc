if (BUILD_DEB_PACKAGE)
	set(CMAKE_INSTALL_PREFIX "/usr" CACHE PATH INTERNAL FORCE)
endif ()

# Prepare CMake exports
configure_file(LibWebRTCConfig.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfig.cmake @ONLY)
configure_file(LibWebRTCConfigVersion.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfigVersion.cmake @ONLY)

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
	COMPONENT common
	FILES_MATCHING PATTERN "*.h"
)

if (EXISTS "${WEBRTC_SOURCE_DIR}/common_types.h")
	install(FILES "${WEBRTC_SOURCE_DIR}/common_types.h" DESTINATION "include/webrtc" COMPONENT common)
endif ()

install(DIRECTORY "${WEBRTC_SOURCE_DIR}/third_party/jsoncpp"
	DESTINATION "include/webrtc/third_party"
	COMPONENT common
	FILES_MATCHING PATTERN "*.h"
)

install(DIRECTORY "${WEBRTC_SOURCE_DIR}/third_party/libyuv"
	DESTINATION "include/webrtc/third_party"
	COMPONENT common
	FILES_MATCHING PATTERN "*.h"
)

install(DIRECTORY "${WEBRTC_SOURCE_DIR}/third_party/abseil-cpp/absl"
	DESTINATION "include/webrtc"
	COMPONENT common
	FILES_MATCHING PATTERN "*.h"
)

# Install pdb files
if (MSVC)
	# TODO: fix install on first run
	file(GLOB_RECURSE PDB_FILES "${WEBRTC_BUILD_DIR}/Debug/*.pdb")
	install(FILES DESTINATION lib COMPONENT debug)
endif()

# Install library
if (WIN32)
	set(LIBRARY_FILENAME_DEBUG "webrtcd.lib")
	set(LIBRARY_FILENAME_RELEASE "webrtc.lib")
else()
	set(LIBRARY_FILENAME_DEBUG "libwebrtcd.a")
	set(LIBRARY_FILENAME_RELEASE "libwebrtc.a")
endif()

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
	if (WIN32)
		install(FILES ${WEBRTC_BUILD_DIR}/obj/webrtc.lib DESTINATION lib RENAME "webrtcd.lib" COMPONENT debug)
	else()
		install(FILES ${WEBRTC_BUILD_DIR}/obj/libwebrtc.a DESTINATION lib RENAME "libwebrtcd.a" COMPONENT debug)
	endif()
else ()
	if (WIN32)
		install(FILES ${WEBRTC_BUILD_DIR}/obj/webrtc.lib DESTINATION lib COMPONENT release)
	else()
		install(FILES ${WEBRTC_BUILD_DIR}/obj/libwebrtc.a DESTINATION lib COMPONENT release)
	endif()
endif ()


install(FILES
	UseLibWebRTC.cmake
	${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfig.cmake
	${CMAKE_CURRENT_BINARY_DIR}/LibWebRTCConfigVersion.cmake
	${CMAKE_CURRENT_SOURCE_DIR}/LibWebRTCTargets.cmake
	DESTINATION "lib/cmake/LibWebRTC"
	COMPONENT common
)

if (CMAKE_BUILD_TYPE STREQUAL "Debug")
	install(FILES LibWebRTCTargets-debug.cmake DESTINATION "lib/cmake/LibWebRTC" COMPONENT debug)
else ()
	install(FILES LibWebRTCTargets-release.cmake DESTINATION "lib/cmake/LibWebRTC" COMPONENT release)
endif ()

if (BUILD_DEB_PACKAGE)
	set(CPACK_GENERATOR "DEB")
	set(CPACK_PACKAGE_VENDOR "Kirill Kirilenko")
	set(CPACK_PACKAGE_CONTACT "Kirill Kirilenko <kirill@ultracoder.org>")
	set(CPACK_PACKAGE_VERSION_MAJOR ${WEBRTC_VERSION})
	set(CPACK_PACKAGE_VERSION_MINOR "")
	set(CPACK_PACKAGE_VERSION_PATCH "")
	set(CPACK_PACKAGE_HOMEPAGE_URL "https://github.com/UltraCoderRU/libwebrtc")
	set(CPACK_DEBIAN_PACKAGE_SECTION "devel")
	set(CPACK_DEB_COMPONENT_INSTALL ON)
	set(CPACK_DEBIAN_ENABLE_COMPONENT_DEPENDS ON)

	set(CPACK_DEBIAN_COMMON_PACKAGE_NAME "libwebrtc-common-dev")
	set(CPACK_DEBIAN_COMMON_FILE_NAME "libwebrtc-common-dev-${WEBRTC_VERSION}.deb")
	set(CPACK_DEBIAN_COMMON_DESCRIPTION "WebRTC header files and CMake modules")

	set(CPACK_DEBIAN_RELEASE_PACKAGE_NAME "libwebrtc-release-dev")
	set(CPACK_DEBIAN_RELEASE_FILE_NAME "libwebrtc-release-dev-${WEBRTC_VERSION}.deb")
	set(CPACK_DEBIAN_RELEASE_DESCRIPTION "WebRTC static library (release version)")
	set(CPACK_DEBIAN_RELEASE_PACKAGE_DEPENDS "libwebrtc-common-dev (=${WEBRTC_VERSION})")
	set(CPACK_DEBIAN_RELEASE_PACKAGE_PROVIDES "libwebrtc-dev")

	set(CPACK_DEBIAN_DEBUG_PACKAGE_NAME "libwebrtc-debug-dev")
	set(CPACK_DEBIAN_DEBUG_FILE_NAME "libwebrtc-debug-dev-${WEBRTC_VERSION}.deb")
	set(CPACK_DEBIAN_DEBUG_DESCRIPTION "WebRTC static library (debug version)")
	set(CPACK_DEBIAN_DEBUG_PACKAGE_DEPENDS "libwebrtc-common-dev (=${WEBRTC_VERSION})")
	set(CPACK_DEBIAN_DEBUG_PACKAGE_PROVIDES "libwebrtc-dev")

	include(CPack)
endif ()
