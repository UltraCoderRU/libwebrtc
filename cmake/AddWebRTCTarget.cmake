function(add_webrtc_target SOURCE_DIR BUILD_DIR)

	set(GEN_ARGS_COMMON "target_cpu=\"${TARGET_CPU}\" target_os=\"${TARGET_OS}\" is_component_build=false use_gold=false use_custom_libcxx=false use_custom_libcxx_for_host=false rtc_enable_protobuf=false")

	if (MSVC)
		set(GEN_ARGS_COMMON "${GEN_ARGS_COMMON} is_clang=false use_lld=false")
	endif ()

	set(GEN_ARGS_DEBUG "${GEN_ARGS_COMMON} is_debug=true")
	set(GEN_ARGS_RELEASE "${GEN_ARGS_COMMON} is_debug=false")

	if (MSVC)
		set(GEN_ARGS_DEBUG "${GEN_ARGS_DEBUG} enable_iterator_debugging=true")
	endif ()

	if (WIN32)
		set(GN_EXECUTABLE gn.bat)
	else ()
		set(GN_EXECUTABLE gn)
	endif ()

	macro(run_gn DIRECTORY)
		execute_process(COMMAND ${GN_EXECUTABLE} gen ${DIRECTORY} "--args=${GEN_ARGS}" WORKING_DIRECTORY ${SOURCE_DIR})
	endmacro()

	if (CMAKE_GENERATOR MATCHES "Visual Studio")
		# Debug config
		message(STATUS "Running gn for debug configuration...")
		set(GEN_ARGS "${GEN_ARGS_DEBUG}")
		if (GN_EXTRA_ARGS)
			set(GEN_ARGS "${GEN_ARGS} ${GN_EXTRA_ARGS}")
		endif ()
		run_gn("${BUILD_DIR}/Debug")
		
		# Release config
		message(STATUS "Running gn for release configuration...")
		set(GEN_ARGS "${GEN_ARGS_RELEASE}")
		if (GN_EXTRA_ARGS)
			set(GEN_ARGS "${GEN_ARGS} ${GN_EXTRA_ARGS}")
		endif ()
		run_gn("${BUILD_DIR}/Release")
	else ()
		message(STATUS "Running gn...")
		if (CMAKE_BUILD_TYPE STREQUAL "Debug")
			set(GEN_ARGS "${GEN_ARGS_DEBUG}")
		else ()
			set(GEN_ARGS "${GEN_ARGS_RELEASE}")
		endif ()
		if (GN_EXTRA_ARGS)
			set(GEN_ARGS "${GEN_ARGS} ${GN_EXTRA_ARGS}")
		endif ()
		run_gn("${BUILD_DIR}")
	endif ()

	macro(add_custom_command_with_path TARGET_NAME)
		add_custom_command(TARGET ${TARGET_NAME} POST_BUILD
			COMMAND ${CMAKE_COMMAND} -E env "PATH=$ENV{PATH}" ${ARGN}
			WORKING_DIRECTORY ${SOURCE_DIR}
			VERBATIM
		)
	endmacro()

	add_custom_target(webrtc-build ALL)
	add_custom_target(webrtc-clean)
	if (CMAKE_GENERATOR MATCHES "Visual Studio")
		add_custom_command_with_path(webrtc-build ninja -C "${BUILD_DIR}/$<CONFIG>" :webrtc jsoncpp libyuv ${NINJA_ARGS})
		add_custom_command_with_path(webrtc-clean ${GN_EXECUTABLE} clean "${BUILD_DIR}/$<CONFIG>")
	else ()
		add_custom_command_with_path(webrtc-build ninja -C "${BUILD_DIR}" :webrtc jsoncpp libyuv ${NINJA_ARGS})
		add_custom_command_with_path(webrtc-clean ${GN_EXECUTABLE} clean "${BUILD_DIR}")
	endif ()

endfunction()
