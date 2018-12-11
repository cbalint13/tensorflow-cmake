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
if (systemlib_GRPC)

  find_package(gRPC 1.15.0 REQUIRED grpc grpc++ gpr address_sorting)

  # extract include path
  if(TARGET gRPC::grpc)
    get_target_property(GRPC_INCLUDE_DIRS gRPC::grpc INTERFACE_INCLUDE_DIRECTORIES)
  endif()
  # manual define
  # buggy grpc cmake (ambigous IMPORTED_LINK_INTERFACE_LIBRARIES_*)
  set(GRPC_LIBRARIES "grpc" "grpc++" "gpr" "address_sorting")

  include_directories(${GRPC_INCLUDE_DIRS})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${GRPC_LIBRARIES})

  # find grpc_cpp_plugin path
  find_path(GRPC_BUILD grpc_cpp_plugin)

  message(STATUS "Found gRPC external")
  message(STATUS "  grpc includes: ${GRPC_INCLUDE_DIRS}")
  message(STATUS "  grpc libraries: ${GRPC_LIBRARIES}")
  message(STATUS "  grpc plugin path: ${GRPC_BUILD}/grpc_cpp_plugin")

  add_custom_target(grpc_build)
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES grpc_build)

else (systemlib_GRPC)

  include (ExternalProject)

  set(GRPC_INCLUDE_DIRS ${CMAKE_CURRENT_BINARY_DIR}/grpc/src/grpc/include)
  set(GRPC_URL https://github.com/grpc/grpc.git)
  set(GRPC_BUILD ${CMAKE_CURRENT_BINARY_DIR}/grpc/src/grpc_build)
  set(GRPC_TAG d184fa229d75d336aedea0041bd59cb93e7e267f)

  if(WIN32)
    # We use unsecure gRPC because boringssl does not build on windows
    set(grpc_TARGET grpc++_unsecure)
    set(grpc_DEPENDS protobuf_build zlib_build )
    set(grpc_SSL_PROVIDER NONE)
    if(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
      set(grpc_STATIC_LIBRARIES
          ${GRPC_BUILD}/Release/grpc++_unsecure.lib
          ${GRPC_BUILD}/Release/grpc_unsecure.lib
          ${GRPC_BUILD}/Release/gpr.lib)
    else()
      set(grpc_STATIC_LIBRARIES
          ${GRPC_BUILD}/grpc++_unsecure.lib
          ${GRPC_BUILD}/grpc_unsecure.lib
          ${GRPC_BUILD}/gpr.lib)
    endif()
  else()
    set(grpc_TARGET grpc++)
    set(grpc_DEPENDS boringssl protobuf_build zlib_build)
    set(grpc_SSL_PROVIDER module)
    set(grpc_STATIC_LIBRARIES
        ${GRPC_BUILD}/libgrpc++.a
        ${GRPC_BUILD}/libgrpc.a
        ${GRPC_BUILD}/libaddress_sorting.a
        ${GRPC_BUILD}/third_party/cares/cares/lib/libcares.a
        ${GRPC_BUILD}/libgpr.a)
  endif()

  add_definitions(-DGRPC_ARES=0)

  ExternalProject_Add(grpc_build
      PREFIX grpc
      DEPENDS ${grpc_DEPENDS}
      GIT_REPOSITORY ${GRPC_URL}
      GIT_TAG ${GRPC_TAG}
      DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
      BUILD_IN_SOURCE 1
      BUILD_BYPRODUCTS ${grpc_STATIC_LIBRARIES}
      BUILD_COMMAND ${CMAKE_COMMAND} --build . --config Release --target ${grpc_TARGET}
      COMMAND ${CMAKE_COMMAND} --build . --config Release --target grpc_cpp_plugin
      INSTALL_COMMAND ""
      CMAKE_CACHE_ARGS
          -DCMAKE_BUILD_TYPE:STRING=Release
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
          -DPROTOBUF_INCLUDE_DIRS:STRING=${PROTOBUF_INCLUDE_DIRS}
          -DPROTOBUF_LIBRARIES:STRING=${protobuf_STATIC_LIBRARIES}
          -DZLIB_ROOT:STRING=${ZLIB_INSTALL}
          -DgRPC_SSL_PROVIDER:STRING=${grpc_SSL_PROVIDER}
  )

  # grpc/src/core/ext/census/tracing.c depends on the existence of openssl/rand.h.
  ExternalProject_Add_Step(grpc_build copy_rand
      COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_SOURCE_DIR}/patches/grpc/rand.h ${GRPC_BUILD}/include/openssl/rand.h
      DEPENDEES patch
      DEPENDERS build
  )

  include_directories(${GRPC_INCLUDE_DIRS})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${grpc_STATIC_LIBRARIES})

  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES grpc_build)

endif (systemlib_GRPC)
