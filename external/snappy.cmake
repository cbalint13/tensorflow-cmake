# Copyright 2017 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================
if (systemlib_SNAPPY)

  find_package(PkgConfig)
  pkg_search_module(SNAPPY REQUIRED snappy)
  include_directories(${SNAPPY_INCLUDEDIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${SNAPPY_LIBRARIES})
  list(APPEND ADD_LINK_DIRECTORY ${SNAPPY_LIBDIR})
  list(APPEND ADD_CFLAGS ${SNAPPY_CFLAGS_OTHER})

  message(STATUS "Found snappy (\"${SNAPPY_VERSION}\") external")
  message(STATUS "  snappy includes: ${SNAPPY_INCLUDEDIR}")
  message(STATUS "  snappy libraries: ${SNAPPY_LIBRARIES}")

  add_custom_target(snappy_build)
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES snappy_build)

else (systemlib_SNAPPY)

  include (ExternalProject)

  set(snappy_URL https://github.com/google/snappy.git)
  set(snappy_TAG "55924d11095df25ab25c405fadfe93d0a46f82eb")
  set(snappy_BUILD ${CMAKE_CURRENT_BINARY_DIR}/snappy/src/snappy_build)
  set(snappy_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/snappy/src/snappy)

  if(WIN32)
      if(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
          set(snappy_STATIC_LIBRARIES ${snappy_BUILD}/$(Configuration)/snappy.lib)
      else()
          set(snappy_STATIC_LIBRARIES ${snappy_BUILD}/snappy.lib)
      endif()
  else()
      set(snappy_STATIC_LIBRARIES ${snappy_BUILD}/libsnappy.a)
  endif()

  set(snappy_HEADERS
      "${snappy_INCLUDE_DIR}/snappy.h"
  )

  ExternalProject_Add(snappy_build
      PREFIX snappy
      GIT_REPOSITORY ${snappy_URL}
      GIT_TAG ${snappy_TAG}
      DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
      BUILD_IN_SOURCE 1
      BUILD_BYPRODUCTS ${snappy_STATIC_LIBRARIES}
      INSTALL_COMMAND ""
      LOG_DOWNLOAD ON
      LOG_CONFIGURE ON
      LOG_BUILD ON
      CMAKE_CACHE_ARGS
          -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=${tensorflow_ENABLE_POSITION_INDEPENDENT_CODE}
          -DCMAKE_BUILD_TYPE:STRING=Release
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
          -DSNAPPY_BUILD_TESTS:BOOL=OFF
  )

  # actually enables snappy in the source code
  add_definitions(-DTF_USE_SNAPPY)

  include_directories(${snappy_INCLUDE_DIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${snappy_STATIC_LIBRARIES})

  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES snappy_build)

endif (systemlib_SNAPPY)
