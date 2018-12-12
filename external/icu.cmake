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
if (systemlib_ICU)

  find_package(ICU REQUIRED i18n uc)
  include_directories(${ICU_INCLUDE_DIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${ICU_LIBRARIES})

  message(STATUS "  icu includes: ${ICU_INCLUDE_DIR}")
  message(STATUS "  icu libraries: ${ICU_LIBRARIES}")

  add_custom_target(icu_build)
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES icu_build)

else (systemlib_ICU)

  include (ExternalProject)

  set(icu_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/icu/install)
  set(icu_URL https://github.com/unicode-org/icu/archive/release-62-1.tar.gz)
  set(icu_HASH SHA256=e15ffd84606323cbad5515bf9ecdf8061cc3bf80fb883b9e6aa162e485aa9761)
  set(icu_BUILD ${CMAKE_CURRENT_BINARY_DIR}/icu/src/icu_build)
  set(icu_INSTALL ${CMAKE_CURRENT_BINARY_DIR}/icu/install)

  if(WIN32)
    set(icu_STATIC_LIBRARIES
        ${icu_INSTALL}/lib/libicui18n.lib
        ${icu_INSTALL}/lib/libicuuc.lib)
  else()
    set(icu_STATIC_LIBRARIES
        ${icu_INSTALL}/lib/libicui18n.a
        ${icu_INSTALL}/lib/libicuuc.a)
  endif()

  ExternalProject_Add(icu_build
      PREFIX icu
      URL ${icu_URL}
      URL_HASH ${icu_HASH}
      INSTALL_DIR ${icu_INSTALL}
      DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
      BUILD_COMMAND $(MAKE)
      INSTALL_COMMAND $(MAKE) install
      CONFIGURE_COMMAND
          ${icu_BUILD}/icu4c/source/configure
          --with-pic
          --prefix=${icu_INSTALL}
          --libdir=${icu_INSTALL}/lib
          --enable-static=yes
          --enable-shared=no
  )

  include_directories(${icu_INCLUDE_DIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${icu_STATIC_LIBRARIES})

  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES icu_build)

endif (systemlib_ICU)
