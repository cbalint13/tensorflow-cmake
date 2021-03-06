# Copyright 2018 The TensorFlow Authors. All Rights Reserved.
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
if (systemlib_ABSEIL_CPP)

  find_package(AbseilCpp REQUIRED
               absl_base
               absl_int128
               absl_strings
               absl_dynamic_annotations
               absl_internal_spinlock_wait
               absl_internal_malloc_internal
               absl_internal_throw_delegate
               absl_internal_hashtablez_sampler
               str_format_internal
               absl_bad_optional_access
               absl_hash
               absl_internal_city
               absl_synchronization
               absl_variant
               absl_raw_hash_set)

  include_directories(${ABSEIL_CPP_INCLUDE_DIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${ABSEIL_CPP_LIBRARIES})

  message(STATUS "  abseil_cpp includes: ${ABSEIL_CPP_INCLUDE_DIR}")
  message(STATUS "  abseil_cpp libraries: ${ABSEIL_CPP_LIBRARIES}")

  add_custom_target(abseil_cpp_build)
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES abseil_cpp_build)

else (systemlib_ABSEIL_CPP)

  include (ExternalProject)

  set(abseil_cpp_INCLUDE_DIR ${CMAKE_BINARY_DIR}/abseil_cpp/src/abseil_cpp_build)
  set(abseil_cpp_URL https://github.com/abseil/abseil-cpp/archive/f197d7c72a54064cfde5a2058f1513a4a0ee36fb.tar.gz)
  set(abseil_cpp_HASH SHA256=3ad76de484192b2d5afd49d90492b5ed0bc59eb1a4e8e0deecc7a2a077a90251)
  set(abseil_cpp_BUILD ${CMAKE_BINARY_DIR}/abseil_cpp/src/abseil_cpp_build)

  if(WIN32)
    if(${CMAKE_GENERATOR} MATCHES "Visual Studio.*")
      set(abseil_cpp_STATIC_LIBRARIES
          ${abseil_cpp_BUILD}/absl/base/Release/absl_base.lib
          ${abseil_cpp_BUILD}/absl/base/Release/absl_internal_spinlock_wait.lib
          ${abseil_cpp_BUILD}/absl/base/Release/absl_dynamic_annotations.lib
          ${abseil_cpp_BUILD}/absl/base/Release/absl_internal_malloc_internal.lib
          ${abseil_cpp_BUILD}/absl/base/Release/absl_internal_throw_delegate.lib
          ${abseil_cpp_BUILD}/absl/numeric/Release/absl_int128.lib
          ${abseil_cpp_BUILD}/absl/strings/Release/absl_strings.lib
          ${abseil_cpp_BUILD}/absl/strings/Release/str_format_internal.lib
          ${abseil_cpp_BUILD}/absl/types/Release/absl_bad_optional_access.lib)
    else()
      set(abseil_cpp_STATIC_LIBRARIES
          ${abseil_cpp_BUILD}/absl/base/absl_base.lib
          ${abseil_cpp_BUILD}/absl/base/absl_internal_spinlock_wait.lib
          ${abseil_cpp_BUILD}/absl/base/absl_dynamic_annotations.lib
          ${abseil_cpp_BUILD}/absl/base/absl_internal_malloc_internal.lib
          ${abseil_cpp_BUILD}/absl/base/absl_internal_throw_delegate.lib
          ${abseil_cpp_BUILD}/absl/numeric/absl_int128.lib
          ${abseil_cpp_BUILD}/absl/strings/absl_strings.lib
          ${abseil_cpp_BUILD}/absl/strings/str_format_internal.lib
          ${abseil_cpp_BUILD}/absl/types/absl_bad_optional_access.lib)
    endif()
  else()
    set(abseil_cpp_STATIC_LIBRARIES
        ${abseil_cpp_BUILD}/absl/base/libabsl_base.a
        ${abseil_cpp_BUILD}/absl/base/libabsl_internal_spinlock_wait.a
        ${abseil_cpp_BUILD}/absl/base/libabsl_dynamic_annotations.a
        ${abseil_cpp_BUILD}/absl/base/libabsl_internal_malloc_internal.a
        ${abseil_cpp_BUILD}/absl/base/libabsl_internal_throw_delegate.a
        ${abseil_cpp_BUILD}/absl/numeric/libabsl_int128.a
        ${abseil_cpp_BUILD}/absl/strings/libabsl_strings.a
        ${abseil_cpp_BUILD}/absl/strings/libstr_format_internal.a
        ${abseil_cpp_BUILD}/absl/types/libabsl_bad_optional_access.a)
  endif()

  ExternalProject_Add(abseil_cpp_build
      PREFIX abseil_cpp
      URL ${abseil_cpp_URL}
      URL_HASH ${abseil_cpp_HASH}
      DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
      BUILD_IN_SOURCE 1
      BUILD_BYPRODUCTS ${abseil_cpp_STATIC_LIBRARIES}
      BUILD_COMMAND ${CMAKE_COMMAND} --build . --config Release
      COMMAND ${CMAKE_COMMAND} --build . --config Release
      INSTALL_COMMAND ""
      CMAKE_CACHE_ARGS
          -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=${tensorflow_ENABLE_POSITION_INDEPENDENT_CODE}
          -DCMAKE_BUILD_TYPE:STRING=Release
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
  )

  include_directories(${abseil_cpp_INCLUDE_DIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${abseil_cpp_STATIC_LIBRARIES})

  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES abseil_cpp_build)

endif (systemlib_ABSEIL_CPP)
