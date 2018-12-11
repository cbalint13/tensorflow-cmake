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
if (systemlib_PROTOBUF)

  find_package(Protobuf 3.3.0 REQUIRED)
  include_directories(${PROTOBUF_INCLUDE_DIRS})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${PROTOBUF_LIBRARIES})
  set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_PROTOC_EXECUTABLE})

  message(STATUS "  protobuf includes: ${PROTOBUF_INCLUDE_DIRS}")
  message(STATUS "  protobuf compiler: ${PROTOBUF_PROTOC_EXECUTABLE}")

  add_custom_target(protobuf_build)
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES protobuf_build)

else (systemlib_PROTOBUF)

  include (ExternalProject)

  set(PROTOBUF_INCLUDE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/protobuf/src/protobuf/src)
  set(PROTOBUF_BUILD ${CMAKE_CURRENT_BINARY_DIR}/protobuf/src/protobuf)
  set(PROTOBUF_URL https://github.com/google/protobuf.git)
  set(PROTOBUF_TAG v3.6.0)

  if(WIN32)
    if(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
      set(protobuf_STATIC_LIBRARIES 
        debug ${PROTOBUF_BUILD}/$(Configuration)/libprotobufd.lib
        optimized ${PROTOBUF_BUILD}/$(Configuration)/libprotobuf.lib)
      set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_BUILD}/$(Configuration)/protoc.exe)
     else()
      if(CMAKE_BUILD_TYPE EQUAL Debug)
        set(protobuf_STATIC_LIBRARIES
          ${PROTOBUF_BUILD}/libprotobufd.lib)
      else()
        set(protobuf_STATIC_LIBRARIES
          ${PROTOBUF_BUILD}/libprotobuf.lib)
      endif()
      set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_BUILD}/protoc.exe)
     endif()

    # This section is to make sure CONFIGURE_COMMAND use the same generator settings
    set(PROTOBUF_GENERATOR_PLATFORM)
    if (CMAKE_GENERATOR_PLATFORM)
      set(PROTOBUF_GENERATOR_PLATFORM -A ${CMAKE_GENERATOR_PLATFORM})
    endif()
    set(PROTOBUF_GENERATOR_TOOLSET)
    if (CMAKE_GENERATOR_TOOLSET)
    set(PROTOBUF_GENERATOR_TOOLSET -T ${CMAKE_GENERATOR_TOOLSET})
    endif()
    set(PROTOBUF_ADDITIONAL_CMAKE_OPTIONS -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
      -G${CMAKE_GENERATOR} ${PROTOBUF_GENERATOR_PLATFORM} ${PROTOBUF_GENERATOR_TOOLSET})
    # End of section
  else()
    set(protobuf_STATIC_LIBRARIES ${PROTOBUF_BUILD}/libprotobuf.a)
    set(PROTOBUF_PROTOC_EXECUTABLE ${PROTOBUF_BUILD}/protoc)
   endif()

  ExternalProject_Add(protobuf_build
      PREFIX protobuf
      DEPENDS zlib_build
      GIT_REPOSITORY ${PROTOBUF_URL}
      GIT_TAG ${PROTOBUF_TAG}
      DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
      BUILD_IN_SOURCE 1
      BUILD_BYPRODUCTS ${PROTOBUF_PROTOC_EXECUTABLE} ${protobuf_STATIC_LIBRARIES}
      SOURCE_DIR ${PROTOBUF_BUILD}
      # SOURCE_SUBDIR cmake/ # Requires CMake 3.7, this will allow removal of CONFIGURE_COMMAND
      # CONFIGURE_COMMAND resets some settings made in CMAKE_CACHE_ARGS and the generator used
      CONFIGURE_COMMAND ${CMAKE_COMMAND} cmake/
          -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=${tensorflow_ENABLE_POSITION_INDEPENDENT_CODE}
          -DCMAKE_BUILD_TYPE:STRING=Release
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
          -Dprotobuf_BUILD_TESTS:BOOL=OFF
          -DZLIB_ROOT=${ZLIB_INSTALL}
          ${PROTOBUF_ADDITIONAL_CMAKE_OPTIONS}
      INSTALL_COMMAND ""
      CMAKE_CACHE_ARGS
          -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=${tensorflow_ENABLE_POSITION_INDEPENDENT_CODE}
          -DCMAKE_BUILD_TYPE:STRING=Release
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
          -Dprotobuf_BUILD_TESTS:BOOL=OFF
          -Dprotobuf_MSVC_STATIC_RUNTIME:BOOL=OFF
          -DZLIB_ROOT:STRING=${ZLIB_INSTALL}
  )

  include_directories(${PROTOBUF_INCLUDE_DIRS})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${protobuf_STATIC_LIBRARIES})

  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES protobuf_build)

endif (systemlib_PROTOBUF)
