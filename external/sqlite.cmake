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
if (systemlib_SQLITE)

  find_package(PkgConfig)
  pkg_search_module(SQLITE REQUIRED sqlite3)
  include_directories(${SQLITE_INCLUDEDIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${SQLITE_LIBRARIES})
  list(APPEND ADD_LINK_DIRECTORY ${SQLITE_LIBDIR})
  list(APPEND ADD_CFLAGS ${SQLITE_CFLAGS_OTHER})

  message(STATUS "Found sqlite3 (\"${SQLITE_VERSION}\") external")
  message(STATUS "  sqlite3 includes: ${SQLITE_INCLUDEDIR}")
  message(STATUS "  sqlite3 libraries: ${SQLITE_LIBRARIES}")

  add_custom_target(sqlite_build)
  add_custom_target(sqlite_copy_headers_to_destination)
  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES sqlite_copy_headers_to_destination)

else (systemlib_SQLITE)

  include (ExternalProject)

  set(sqlite_INCLUDE_DIR ${CMAKE_CURRENT_BINARY_DIR}/external/sqlite)
  set(sqlite_URL https://mirror.bazel.build/www.sqlite.org/2018/sqlite-amalgamation-3230100.zip)
  set(sqlite_HASH SHA256=4239a1f69e5721d07d9a374eb84d594225229e54be4ee628da2995f4315d8dfc)
  set(sqlite_BUILD ${CMAKE_CURRENT_BINARY_DIR}/sqlite/src/sqlite_build)
  set(sqlite_INSTALL ${CMAKE_CURRENT_BINARY_DIR}/sqlite/install)

  if(WIN32)
    set(sqlite_STATIC_LIBRARIES ${sqlite_INSTALL}/lib/sqlite.lib)
  else()
    set(sqlite_STATIC_LIBRARIES ${sqlite_INSTALL}/lib/libsqlite.a)
  endif()

  set(sqlite_HEADERS
      "${sqlite_BUILD}/sqlite3.h"
      "${sqlite_BUILD}/sqlite3ext.h"
  )

  if (WIN32)
      ExternalProject_Add(sqlite_build
          PREFIX sqlite
          URL ${sqlite_URL}
          URL_HASH ${sqlite_HASH}
          BUILD_BYPRODUCTS ${sqlite_STATIC_LIBRARIES}
          PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_SOURCE_DIR}/patches/sqlite/CMakeLists.txt ${sqlite_BUILD}
          INSTALL_DIR ${sqlite_INSTALL}
          DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
          CMAKE_CACHE_ARGS
              -DCMAKE_BUILD_TYPE:STRING=Release
              -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
              -DCMAKE_INSTALL_PREFIX:STRING=${sqlite_INSTALL}
      )

  else()
      ExternalProject_Add(sqlite
          PREFIX sqlite
          URL ${sqlite_URL}
          URL_HASH ${sqlite_HASH}
          PATCH_COMMAND ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_SOURCE_DIR}/patches/sqlite/CMakeLists.txt ${sqlite_BUILD}
          INSTALL_DIR ${sqlite_INSTALL}
          DOWNLOAD_DIR "${DOWNLOAD_LOCATION}"
          CMAKE_CACHE_ARGS
              -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=${tensorflow_ENABLE_POSITION_INDEPENDENT_CODE}
              -DCMAKE_BUILD_TYPE:STRING=Release
              -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
              -DCMAKE_INSTALL_PREFIX:STRING=${sqlite_INSTALL}
      )

  endif()

  # put sqlite includes in the directory where they are expected
  add_custom_target(sqlite_create_destination_dir
      COMMAND ${CMAKE_COMMAND} -E make_directory ${sqlite_INCLUDE_DIR}
      DEPENDS sqlite_build)

  add_custom_target(sqlite_copy_headers_to_destination
      DEPENDS sqlite_create_destination_dir)

  foreach(header_file ${sqlite_HEADERS})
      add_custom_command(TARGET sqlite_copy_headers_to_destination PRE_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy_if_different ${header_file} ${sqlite_INCLUDE_DIR})
  endforeach()

  include_directories(${sqlite_INCLUDE_DIR})
  list(APPEND tensorflow_EXTERNAL_LIBRARIES ${sqlite_STATIC_LIBRARIES})

  list(APPEND tensorflow_EXTERNAL_DEPENDENCIES sqlite_copy_headers_to_destination)

endif (systemlib_SQLITE)
