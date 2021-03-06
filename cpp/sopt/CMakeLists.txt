# list of headers
set(headers
  bisection_method.h chained_operators.h credible_region.h
  imaging_forward_backward.h forward_backward.h primal_dual.h imaging_padmm.h logging.disabled.h 
  maths.h proximal.h relative_variation.h sdmm.h
  wavelets.h conjugate_gradient.h l1_proximal.h logging.enabled.h padmm.h proximal_expression.h
  reweighted.h types.h wrapper.h exception.h linear_transform.h logging.h positive_quadrant.h
  real_type.h sampling.h power_method.h ${PROJECT_BINARY_DIR}/include/sopt/config.h
  )
set(wavelet_headers
  wavelets/direct.h wavelets/indirect.h wavelets/innards.impl.h wavelets/sara.h
  wavelets/wavelet_data.h wavelets/wavelets.h
  )

set(sources wavelets/wavelets.cc wavelets/wavelet_data.cc)
if(TIFF_FOUND)
  list(APPEND sources utilities.cc)
  list(APPEND headers utilities.h)
endif()
if(SOPT_MPI)
  list(APPEND sources mpi/communicator.cc mpi/registered_types.cc mpi/session.cc wavelets/sara.cc)
  list(APPEND mpi_headers mpi/communicator.h mpi/registered_types.h mpi/utilities.h mpi/session.h)
endif()

add_library(sopt SHARED ${sources})
add_dependencies(sopt lookup_dependencies)
set(version "${Sopt_VERSION_MAJOR}.${Sopt_VERSION_MINOR}.${Sopt_VERSION_PATCH}")
set(soversion "${Sopt_VERSION_MAJOR}.${Sopt_VERSION_MINOR}")
set_target_properties(sopt PROPERTIES VERSION ${version} SOVERSION ${soversion})

target_include_directories(sopt PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/..>
  $<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/include>
  $<INSTALL_INTERFACE:include/>)

if(TIFF_FOUND)
  target_link_libraries(sopt ${TIFF_LIBRARY})
  target_include_directories(sopt SYSTEM PUBLIC ${TIFF_INCLUDE_DIR})
endif()
# Add spdlog as direct dependency if not downloaded
if(SPDLOG_INCLUDE_DIR AND NOT spdlog_BUILT_AS_EXTERNAL_PROJECT)
  target_include_directories(sopt SYSTEM PUBLIC ${SPDLOG_INCLUDE_DIR})
elseif(SPDLOG_INCLUDE_DIR AND spdlog_BUILT_AS_EXTERNAL_PROJECT)
  target_include_directories(sopt SYSTEM PUBLIC $<BUILD_INTERFACE:${SPDLOG_INCLUDE_DIR}>)
endif()
# Add eigen as direct dependency if not downloaded
if(EIGEN3_INCLUDE_DIR AND NOT Eigen3_BUILT_AS_EXTERNAL_PROJECT)
  target_include_directories(sopt SYSTEM PUBLIC ${EIGEN3_INCLUDE_DIR})
elseif(EIGEN3_INCLUDE_DIR AND Eigen3_BUILT_AS_EXTERNAL_PROJECT)
  target_include_directories(sopt SYSTEM PUBLIC $<BUILD_INTERFACE:${EIGEN3_INCLUDE_DIR}>)
endif()
if(TARGET openmp::openmp)
  target_link_libraries(sopt openmp::openmp)
endif()
if(SOPT_MPI)
  target_link_libraries(sopt ${MPI_CXX_LIBRARIES})
  target_include_directories(sopt SYSTEM PUBLIC ${MPI_CXX_INCLUDE_PATH})
endif()

install(FILES ${headers} DESTINATION include/sopt)
install(FILES ${wavelet_headers} DESTINATION include/sopt/wavelets)
install(FILES ${mpi_headers} DESTINATION include/sopt/mpi)
install(TARGETS sopt
  EXPORT SoptCPPTargets
  DESTINATION share/cmake/sopt
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  INCLUDES DESTINATION include
  )
