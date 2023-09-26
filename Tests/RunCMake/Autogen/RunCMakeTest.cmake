include(RunCMake)

run_cmake(NoQt)
if (DEFINED with_qt_version)
  set(RunCMake_TEST_OPTIONS
    -Dwith_qt_version=${with_qt_version}
    "-DQt${with_qt_version}_DIR:PATH=${Qt${with_qt_version}_DIR}"
    "-DCMAKE_PREFIX_PATH:STRING=${CMAKE_PREFIX_PATH}"
  )

  run_cmake(QtInFunction)
  run_cmake(QtInFunctionNested)
  run_cmake(QtInFunctionProperty)

  run_cmake(CMP0111-imported-target-full)
  run_cmake(CMP0111-imported-target-libname)
  run_cmake(CMP0111-imported-target-implib-only)

  block()
    set(RunCMake_TEST_BINARY_DIR  ${RunCMake_BINARY_DIR}/MocPredefs-build)
    run_cmake(MocPredefs)
    set(RunCMake_TEST_NO_CLEAN 1)
    run_cmake_command(MocPredefs-build ${CMAKE_COMMAND} --build . --config Debug)
  endblock()

  # Detect information from the toolchain:
  # - CMAKE_INCLUDE_FLAG_CXX
  # - CMAKE_INCLUDE_SYSTEM_FLAG_CXX
  run_cmake(Inspect)
  include("${RunCMake_BINARY_DIR}/Inspect-build/info.cmake")

  if(CMAKE_INCLUDE_SYSTEM_FLAG_CXX)
    if(RunCMake_GENERATOR MATCHES "Visual Studio")
      string(REGEX REPLACE "^-" "/" test_expect_stdout "${CMAKE_INCLUDE_SYSTEM_FLAG_CXX}")
    else()
      set(test_expect_stdout "-*${CMAKE_INCLUDE_SYSTEM_FLAG_CXX}")
    endif()
    string(APPEND test_expect_stdout " *(\"[^\"]*|([^ ]|\\ )*)[\\/]dummy_autogen[\\/]include")
    if(RunCMake_GENERATOR_IS_MULTI_CONFIG)
      string(APPEND test_expect_stdout "_Debug")
    endif()

    block()
      set(RunCMake_TEST_BINARY_DIR  ${RunCMake_BINARY_DIR}/CMP0151-new-build)
      run_cmake_with_options(CMP0151-new ${RunCMake_TEST_OPTIONS} -DCMAKE_POLICY_DEFAULT_CMP0151=NEW)
      set(RunCMake_TEST_NO_CLEAN 1)
      set(RunCMake_TEST_EXPECT_stdout "${test_expect_stdout}")
      message(STATUS "RunCMake_TEST_EXPECT_stdout: ${RunCMake_TEST_EXPECT_stdout}")
      run_cmake_command(CMP0151-new-build ${CMAKE_COMMAND} --build . --config Debug --verbose)
    endblock()

    block()
      set(RunCMake_TEST_BINARY_DIR  ${RunCMake_BINARY_DIR}/AutogenUseSystemIncludeOn-build)
      run_cmake_with_options(AutogenUseSystemIncludeOn ${RunCMake_TEST_OPTIONS} -DCMAKE_POLICY_DEFAULT_CMP0151=NEW)
      set(RunCMake_TEST_NO_CLEAN 1)
      set(RunCMake_TEST_EXPECT_stdout "${test_expect_stdout}")
      message(STATUS "RunCMake_TEST_EXPECT_stdout: ${RunCMake_TEST_EXPECT_stdout}")
      run_cmake_command(AutogenUseSystemIncludeOn ${CMAKE_COMMAND} --build . --config Debug --verbose)
    endblock()
  endif()

  if(CMAKE_INCLUDE_FLAG_CXX)
    if(RunCMake_GENERATOR MATCHES "Visual Studio")
      string(REGEX REPLACE "^-" "/" test_expect_stdout "${CMAKE_INCLUDE_FLAG_CXX}")
    else()
      set(test_expect_stdout "-*${CMAKE_INCLUDE_FLAG_CXX}")
    endif()
    string(APPEND test_expect_stdout " *(\"[^\"]*|([^ ]|\\ )*)[\\/]dummy_autogen[\\/]include")
    if(RunCMake_GENERATOR_IS_MULTI_CONFIG)
      string(APPEND test_expect_stdout "_Debug")
    endif()

    block()
      set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/CMP0151-old-build)
      run_cmake_with_options(CMP0151-old ${RunCMake_TEST_OPTIONS} -DCMAKE_POLICY_DEFAULT_CMP0151=OLD)
      set(RunCMake_TEST_NO_CLEAN 1)
      set(RunCMake_TEST_EXPECT_stdout "${test_expect_stdout}")
      message(STATUS "RunCMake_TEST_EXPECT_stdout: ${RunCMake_TEST_EXPECT_stdout}")
      run_cmake_command(CMP0151-old-build ${CMAKE_COMMAND} --build . --config Debug --verbose)
    endblock()

    block()
      set(RunCMake_TEST_BINARY_DIR  ${RunCMake_BINARY_DIR}/AutogenUseSystemIncludeOff-build)
      run_cmake_with_options(AutogenUseSystemIncludeOff ${RunCMake_TEST_OPTIONS} -DCMAKE_POLICY_DEFAULT_CMP0151=NEW)
      set(RunCMake_TEST_NO_CLEAN 1)
      set(RunCMake_TEST_EXPECT_stdout "${test_expect_stdout}")
      message(STATUS "RunCMake_TEST_EXPECT_stdout: ${RunCMake_TEST_EXPECT_stdout}")
      run_cmake_command(AutogenUseSystemIncludeOff ${CMAKE_COMMAND} --build . --config Debug --verbose)
    endblock()

    if(RunCMake_GENERATOR MATCHES "Make|Ninja")
      block()
        set(RunCMake_TEST_BINARY_DIR  ${RunCMake_BINARY_DIR}/AutogenSkipLinting-build)
        list(APPEND RunCMake_TEST_OPTIONS
          "-DPSEUDO_CPPCHECK=${PSEUDO_CPPCHECK}"
          "-DPSEUDO_CPPLINT=${PSEUDO_CPPLINT}"
          "-DPSEUDO_IWYU=${PSEUDO_IWYU}"
          "-DPSEUDO_TIDY=${PSEUDO_TIDY}")

        run_cmake(AutogenSkipLinting)
        set(RunCMake_TEST_NO_CLEAN 1)
        run_cmake_command(AutogenSkipLinting-build ${CMAKE_COMMAND} --build . --config Debug --verbose)
      endblock()
    endif()
  endif()

  if(RunCMake_GENERATOR_IS_MULTI_CONFIG AND NOT RunCMake_GENERATOR MATCHES "Xcode")
    block()
      set(RunCMake_TEST_BINARY_DIR  ${RunCMake_BINARY_DIR}/MocGeneratedFile-build)
      run_cmake(MocGeneratedFile)
      set(RunCMake_TEST_NO_CLEAN 1)
      run_cmake_command(MocGeneratedFile-build ${CMAKE_COMMAND} --build . --config Debug --verbose)
    endblock()
    if(RunCMake_GENERATOR MATCHES "Ninja Multi-Config")
      block()
        set(RunCMake_TEST_BINARY_DIR  ${RunCMake_BINARY_DIR}/MocGeneratedFile-cross-config-build)
        list(APPEND RunCMake_TEST_OPTIONS -DCMAKE_CROSS_CONFIGS=all)
        run_cmake(MocGeneratedFile)
        set(RunCMake_TEST_NO_CLEAN 1)
        run_cmake_command(MocGeneratedFile-cross-config-build ${CMAKE_COMMAND} --build . --config Release --target libgen:Debug)
        run_cmake_command(MocGeneratedFile-cross-config-build ${CMAKE_COMMAND} --build . --config Debug --target libgen:Release)
      endblock()
    endif()
  endif()

  if(RunCMake_GENERATOR MATCHES "Make|Ninja")
    block()
      if(QtCore_VERSION VERSION_GREATER_EQUAL 5.15.0)
        set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/QtAutoMocDeps-build)
        run_cmake(QtAutoMocDeps)
        set(RunCMake_TEST_NO_CLEAN 1)
        # Build the project.
        run_cmake_command(QtAutoMocDeps-build ${CMAKE_COMMAND} --build . --verbose)
        # Touch just the library source file, which shouldn't cause a rerun of AUTOMOC
        # for app_with_qt target.
        file(TOUCH "${RunCMake_SOURCE_DIR}/simple_lib.cpp")
        set(RunCMake_TEST_NOT_EXPECT_stdout "Automatic MOC for target app_with_qt|\
Automatic MOC for target sub_exe_1|\
Automatic MOC for target sub_exe_2")
        set(RunCMake_TEST_VARIANT_DESCRIPTION "-Don't execute AUTOMOC for 'app_with_qt', 'sub_exe_1' and 'sub_exe_2'")
        # Build and assert that AUTOMOC was not run for app_with_qt, sub_exe_1 and sub_exe_2.
        run_cmake_command(QtAutoMocDeps-build ${CMAKE_COMMAND} --build . --verbose)
        unset(RunCMake_TEST_VARIANT_DESCRIPTION)
        unset(RunCMake_TEST_NOT_EXPECT_stdout)

        macro(check_file_exists file)
          if (EXISTS "${file}")
            set(check_result "PASSED")
            set(message_type "STATUS")
          else()
            set(check_result "FAILED")
            set(message_type "FATAL_ERROR")
          endif()

          message(${message_type} "QtAutoMocDeps-build-\"${file}\" was generated - ${check_result}")
        endmacro()

        check_file_exists("${RunCMake_TEST_BINARY_DIR}/app_with_qt_autogen/deps")
        check_file_exists("${RunCMake_TEST_BINARY_DIR}/QtSubDir1/sub_exe_1_autogen/deps")
        check_file_exists("${RunCMake_TEST_BINARY_DIR}/QtSubDir2/sub_exe_2_autogen/deps")

        check_file_exists("${RunCMake_TEST_BINARY_DIR}/app_with_qt_autogen/timestamp")
        check_file_exists("${RunCMake_TEST_BINARY_DIR}/QtSubDir1/sub_exe_1_autogen/timestamp")
        check_file_exists("${RunCMake_TEST_BINARY_DIR}/QtSubDir2/sub_exe_2_autogen/timestamp")

        # Touch a header file to make sure an automoc dependency cycle is not introduced.
        file(TOUCH "${RunCMake_SOURCE_DIR}/MyWindow.h")
        set(RunCMake_TEST_VARIANT_DESCRIPTION "-First build after touch to detect dependency cycle")
        run_cmake_command(QtAutoMocDeps-build ${CMAKE_COMMAND} --build . --verbose)
        # Need to run a second time to hit the dependency cycle.
        set(RunCMake_TEST_VARIANT_DESCRIPTION "-Don't hit dependency cycle")
        run_cmake_command(QtAutoMocDeps-build ${CMAKE_COMMAND} --build . --verbose)
      endif()
    endblock()
  endif()

  function(run_make_program dir)
    execute_process(
      COMMAND "${RunCMake_MAKE_PROGRAM}" ${ARGN}
      WORKING_DIRECTORY "${dir}"
      OUTPUT_VARIABLE make_program_stdout
      ERROR_VARIABLE make_program_stderr
      RESULT_VARIABLE make_program_result
      )
      if (NOT DEFINED RunMakeProgram_expected_result)
        set(RunMakeProgram_expected_result 0)
      endif()
      if(NOT "${make_program_result}" MATCHES "${RunMakeProgram_expected_result}")
        message(STATUS "
============ beginning of ${RunCMake_MAKE_PROGRAM}'s stdout ============
${make_program_stdout}
=============== end of ${RunCMake_MAKE_PROGRAM}'s stdout ===============
")
        message(STATUS "
============ beginning of ${RunCMake_MAKE_PROGRAM}'s stderr ============
${make_program_stderr}
=============== end of ${RunCMake_MAKE_PROGRAM}'s stderr ===============
")
        message(FATAL_ERROR
                "top ${RunCMake_MAKE_PROGRAM} build failed exited with status ${make_program_result}")
    endif()
    set(make_program_stdout "${make_program_stdout}" PARENT_SCOPE)
  endfunction(run_make_program)

  function(count_substring STRING SUBSTRING COUNT_VAR)
      string(LENGTH "${STRING}" STRING_LENGTH)
      string(LENGTH "${SUBSTRING}" SUBSTRING_LENGTH)
      if (SUBSTRING_LENGTH EQUAL 0)
          message(FATAL_ERROR "SUBSTRING_LENGTH is 0")
      endif()

      if (STRING_LENGTH EQUAL 0)
          message(FATAL_ERROR "STRING_LENGTH is 0")
      endif()

      if (STRING_LENGTH LESS SUBSTRING_LENGTH)
          message(FATAL_ERROR "STRING_LENGTH is less than SUBSTRING_LENGTH")
      endif()

      set(COUNT 0)
      string(FIND "${STRING}" "${SUBSTRING}" SUBSTRING_START)
      while(SUBSTRING_START GREATER_EQUAL 0)
          math(EXPR COUNT "${COUNT} + 1")
          math(EXPR SUBSTRING_START "${SUBSTRING_START} + ${SUBSTRING_LENGTH}")
          string(SUBSTRING "${STRING}" ${SUBSTRING_START} -1 STRING)
          string(FIND "${STRING}" "${SUBSTRING}" SUBSTRING_START)
      endwhile()

      set(${COUNT_VAR} ${COUNT} PARENT_SCOPE)
  endfunction()

  function(expect_only_once make_program_stdout expected_output test_name)
    count_substring("${make_program_stdout}" "${expected_output}" count)
    if(NOT count EQUAL 1)
      message(STATUS "${test_name}-expect_only_once - FAILED")
      message(FATAL_ERROR "Expected to find ${expected_output} exactly once in ${make_program_stdout} but found ${count} occurrences of ${expected_output}")
    else()
      message(STATUS "${test_name}-expect_only_once - PASSED")
    endif()
  endfunction()

  function(expect_n_times string_to_check expected_output expected_count test_name)
    count_substring("${string_to_check}" "${expected_output}" count)
    if(NOT count EQUAL ${expected_count})
      message(STATUS "${test_name}-expect_${expected_count}_times - FAILED")
      message(FATAL_ERROR "Expected to find ${expected_output} exactly ${expected_count} times in ${string_to_check} but found ${count} occurrences of ${expected_output}")
    else()
      message(STATUS "${test_name}-expect_${expected_count}_times - PASSED")
    endif()
  endfunction()

  function(not_expect make_program_stdout unexpected_output test_name)
    count_substring("${make_program_stdout}" "${unexpected_output}" count)
    if(NOT count EQUAL 0)
      message(STATUS "${test_name}-not_expect - FAILED")
      message(FATAL_ERROR "Expected to find ${unexpected_output} exactly 0 times in ${make_program_stdout} but found ${count} occurrences of ${unexpected_output}")
    else()
      message(STATUS "${test_name}-not_expect - PASSED")
    endif()
  endfunction()

  if (QtCore_VERSION VERSION_GREATER_EQUAL 5.15.0)
    foreach(exe IN ITEMS Moc Uic Rcc)
      if(RunCMake_GENERATOR MATCHES "Ninja Multi-Config")
        block()
          set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/Auto${exe}ExecutableConfig-build)
          run_cmake_with_options(Auto${exe}ExecutableConfig ${RunCMake_TEST_OPTIONS} -DCMAKE_AUTOGEN_VERBOSE=ON)
          foreach(config IN ITEMS Debug Release RelWithDebInfo)
            block()
              run_make_program(${RunCMake_TEST_BINARY_DIR} --verbose -f build-${config}.ninja)

              set(expected_output "running_exe_${config}")
              expect_only_once("${make_program_stdout}" "${expected_output}" "Auto${exe}ExecutableConfig-${config}-${expected_output}")

              foreach(sub_config IN ITEMS Debug Release RelWithDebInfo)
                if(NOT sub_config STREQUAL config)
                  set(unexpected_output "running_exe_${sub_config}")
                  not_expect("${make_program_stdout}" "${unexpected_output}" "Auto${exe}ExecutableConfig-${config}-${unexpected_output}")
                endif()
              endforeach()

              if (exe STREQUAL "Moc" OR exe STREQUAL "Uic")
                set(expected_output "cmake_autogen")
              else()
                set(expected_output "cmake_autorcc")
              endif()
              expect_only_once("${make_program_stdout}" "${expected_output}" "Auto${exe}ExecutableConfig-${config}-${expected_output}")
            endblock()
          endforeach()
        endblock()
        block()
          foreach(ninja_config IN ITEMS Debug Release RelWithDebInfo)
            foreach(target_config IN ITEMS Debug Release RelWithDebInfo)
              block()
                set(TEST_SUFFIX "-CrossConfig-${ninja_config}-${target_config}")
                set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/Auto${exe}ExecutableConfig${TEST_SUFFIX}-build)
                set(RunCMake_TEST_VARIANT_DESCRIPTION ${TEST_SUFFIX})
                run_cmake_with_options(Auto${exe}ExecutableConfig ${RunCMake_TEST_OPTIONS} -DCMAKE_CROSS_CONFIGS=all -DCMAKE_DEFAULT_BUILD_TYPE=${ninja_config})
                unset(RunCMake_TEST_VARIANT_DESCRIPTION)

                run_make_program(${RunCMake_TEST_BINARY_DIR} --verbose -f build-${ninja_config}.ninja dummy:${target_config})

                set(expected_output "running_exe_${ninja_config}")
                expect_only_once("${make_program_stdout}" "${expected_output}" "Auto${exe}ExecutableConfig${TEST_SUFFIX}-${expected_output}")

                foreach(sub_config IN ITEMS Debug Release RelWithDebInfo)
                  if(NOT sub_config STREQUAL ninja_config)
                    set(unexpected_output "running_exe_${sub_config}")
                    not_expect("${make_program_stdout}" "${unexpected_output}" "Auto${exe}ExecutableConfig${TEST_SUFFIX}-${unexpected_output}")
                  endif()
                endforeach()

                if (exe STREQUAL "Moc" OR exe STREQUAL "Uic")
                  set(expected_output "cmake_autogen")
                else()
                  set(expected_output "cmake_autorcc")
                endif()
                expect_only_once("${make_program_stdout}" "${expected_output}" "Auto${exe}ExecutableConfig${TEST_SUFFIX}-${expected_output}")
              endblock()
            endforeach()
          endforeach()
        endblock()
        block()
          foreach(ninja_config IN ITEMS Debug Release RelWithDebInfo)
            set(TEST_SUFFIX "-CrossConfig-${ninja_config}-all-all")
            set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/Auto${exe}ExecutableConfig${TEST_SUFFIX}-build)
            set(RunCMake_TEST_VARIANT_DESCRIPTION ${TEST_SUFFIX})
            run_cmake_with_options(Auto${exe}ExecutableConfig ${RunCMake_TEST_OPTIONS} -DCMAKE_CROSS_CONFIGS=all)
            unset(RunCMake_TEST_VARIANT_DESCRIPTION)
            run_make_program(${RunCMake_TEST_BINARY_DIR} --verbose -f build-${ninja_config}.ninja all:all)
          endforeach()
        endblock()
      elseif (RunCMake_GENERATOR MATCHES "Ninja|Make")
        block()
          set(RunCMake_TEST_BINARY_DIR  ${RunCMake_BINARY_DIR}/Auto${exe}ExecutableConfig-build)
          foreach(config IN ITEMS Debug Release RelWithDebInfo)
            block()
              set(RunCMake_TEST_VARIANT_DESCRIPTION "-${config}")
              run_cmake_with_options(Auto${exe}ExecutableConfig ${RunCMake_TEST_OPTIONS} -DCMAKE_BUILD_TYPE=${config} -DCMAKE_AUTOGEN_VERBOSE=ON)
              unset(RunCMake_TEST_VARIANT_DESCRIPTION)
              set(RunCMake_TEST_NO_CLEAN 1)
              set(RunCMake_TEST_EXPECT_stdout ".*running_exe_${config}*")
              run_cmake_command(Auto${exe}ExecutableConfig-${config}-build ${CMAKE_COMMAND} --build .)
            endblock()
          endforeach()
        endblock()
      endif()
    endforeach()
  endif()
endif ()
