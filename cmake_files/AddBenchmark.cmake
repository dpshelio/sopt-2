include(PackageLookup)  # check for existence, or install external projects
lookup_package(GBenchmark REQUIRED)


if(NOT TARGET benchmarks)
  add_custom_target(benchmarks)
endif()

function(add_benchmark targetname)
  cmake_parse_arguments(benchmark
    "" "WORKING_DIRECTORY" "LIBRARIES;LABELS;COMPILE_FLAGS;DEPENDS;INCLUDES" ${ARGN})

  # Source deduce from targetname if possible
  unset(source)
  if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${targetname}.cc")
    set(source ${targetname}.cc)
  elseif("${benchmark_UNPARSED_ARGUMENTS}" STREQUAL "")
    message(FATAL_ERROR "No source given or found for ${targetname}")
  endif()

  if(GBENCHMARK_INCLUDE_DIR)
    include_directories(${GBENCHMARK_INCLUDE_DIR})
  endif()
  add_executable(benchmark_${targetname} ${source} ${benchmark_UNPARSED_ARGUMENTS})
  set_target_properties(benchmark_${targetname} PROPERTIES OUTPUT_NAME ${targetname})
  if(GBENCHMARK_INCLUDE_DIR)
    target_include_directories(benchmark_${targetname} PUBLIC ${GBENCHMARK_INCLUDE_DIR})
  endif()
  if(benchmark_INCLUDES)
    target_include_directories(benchmark_${targetname} PUBLIC ${benchmark_INCLUDES})
  endif()
  if(benchmark_COMPILE_FLAGS)
    set_target_properties(benchmark_${targetname}
      PROPERTIES COMPILE_FLAGS ${benchmark_COMPILE_FLAGS})
  endif()
  if(TARGET GBenchmark)
    list(APPEND benchmark_DEPENDS GBenchmark)
  endif()
  if(benchmark_DEPENDS)
    add_dependencies(benchmark_${targetname} ${benchmark_DEPENDS})
  endif()

  if(EXISTS "${GBENCHMARK_LIBRARY}")
    target_link_libraries(benchmark_${targetname} ${GBENCHMARK_LIBRARY})
  endif()
  if(benchmark_LIBRARIES)
    target_link_libraries(benchmark_${targetname} ${benchmark_LIBRARIES})
  endif()
  if(TARGET lookup_dependencies)
    add_dependencies(benchmark_${targetname} lookup_dependencies)
  endif()

  add_custom_target(benchmark_${targetname}-run COMMAND benchmark_${targetname}
    COMMENT "Running benchmark ${targetname}" )
  add_dependencies(benchmark_${targetname}-run benchmark_${targetname})
  add_dependencies(benchmarks benchmark_${targetname}-run)
  if(GBenchmark_BUILT_AS_EXTERNAL_PROJECT)
    depends_on_lookups(benchmark_${targetname})
  endif()
endfunction()
