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
if (systemlib_JPEG)

  find_package(JPEG REQUIRED)
  include_directories(${JPEG_INCLUDE_DIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${JPEG_LIBRARIES})

  message(STATUS "  jpeg includes: ${JPEG_INCLUDE_DIR}")
  message(STATUS "  jpeg libraries: ${JPEG_LIBRARIES}")

  add_custom_target(jpeg_build)
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES jpeg_build)

else (systemlib_JPEG)

  include (ExternalProject)

  set(jpeg_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/jpeg/install)
  set(jpeg_URL https://github.com/libjpeg-turbo/libjpeg-turbo/archive/2.0.0.tar.gz)
  set(jpeg_HASH SHA256=f892fff427ab3adffc289363eac26d197ce3ccacefe5f5822377348a8166069b)
  set(jpeg_BUILD ${CMAKE_CURRENT_BINARY_DIR}/jpeg/src/jpeg_build-build)
  set(jpeg_INSTALL ${CMAKE_CURRENT_BINARY_DIR}/jpeg/install)

  if(WIN32)
    set(jpeg_STATIC_LIBRARIES ${jpeg_BUILD}/libjpeg.lib)
  else()
    set(jpeg_STATIC_LIBRARIES ${jpeg_BUILD}/libjpeg.a)
  endif()

  ExternalProject_Add(jpeg_build
      PREFIX jpeg
      URL ${jpeg_URL}
      URL_HASH ${jpeg_HASH}
      INSTALL_DIR ${jpeg_INSTALL}
      DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
      BUILD_COMMAND $(MAKE)
      INSTALL_COMMAND $(MAKE) install
      CMAKE_CACHE_ARGS
          -DCMAKE_BUILD_TYPE:STRING=Release
          -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
          -DCMAKE_INSTALL_PREFIX:STRING=${jpeg_INSTALL}
  )

  include_directories(${jpeg_INCLUDE_DIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${jpeg_STATIC_LIBRARIES})

  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES jpeg_build)

endif (systemlib_JPEG)
