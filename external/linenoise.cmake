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
if (systemlib_LINENOISE)

  find_package(Linenoise REQUIRED)
  include_directories(${LINENOISE_INCLUDE_DIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${LINENOISE_LIBRARIES})

  message(STATUS "  linenoise includes: ${LINENOISE_INCLUDE_DIR}")
  message(STATUS "  linenoise libraries: ${LINENOISE_LIBRARIES}")

  add_custom_target(linenoise_build)
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES linenoise_build)

else (systemlib_LINENOISE)

  include (ExternalProject)

  # We parse the current Eigen version and archive hash from the bazel configuration
  file(STRINGS ${PROJECT_SOURCE_DIR}/../../workspace.bzl workspace_contents)
  foreach(line ${workspace_contents})
      string(REGEX MATCH ".*\"(https://github.com/antirez/linenoise/archive/[^\"]*tar.gz)\"" has_url ${line})
      if(has_url)
          set(linenoise_URL ${CMAKE_MATCH_1})
          break()
      endif()
  endforeach()

  set(linenoise_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/linenoise/install)
  set(linenoise_BUILD ${CMAKE_CURRENT_BINARY_DIR}/linenoise/src/linenoise_build)
  set(linenoise_INSTALL ${CMAKE_CURRENT_BINARY_DIR}/linenoise/install)

  if(WIN32)
    set(linenoise_STATIC_LIBRARIES
        ${linenoise_INSTALL}/lib/liblinenoise.lib)
  else()
    set(linenoise_STATIC_LIBRARIES
        ${linenoise_INSTALL}/lib/liblinenoise.a)
  endif()

  ExternalProject_Add(linenoise_build
      PREFIX linenoise
      URL ${linenoise_URL}
      URL_HASH ${linenoise_HASH}
      INSTALL_DIR ${linenoise_INSTALL}
      DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
      BUILD_COMMAND $(MAKE)
      INSTALL_COMMAND $(MAKE) install
      CONFIGURE_COMMAND
          ${linenoise_BUILD}/linenoise4c/source/configure
          --with-pic
          --prefix=${linenoise_INSTALL}
          --libdir=${linenoise_INSTALL}/lib
          --enable-static=yes
          --enable-shared=no
  )

  include_directories(${linenoise_INCLUDE_DIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${linenoise_STATIC_LIBRARIES})

  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES linenoise_build)

endif (systemlib_LINENOISE)
