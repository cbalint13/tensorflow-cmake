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
find_path(ABSEIL_CPP_INCLUDE_DIR absl/base/config.h
  HINTS "${ABSEIL_CPP_INCLUDE_DIR_HINTS}"
  PATHS "$ENV{PROGRAMFILES}"
        "$ENV{PROGRAMW6432}"
  PATH_SUFFIXES "")

if(EXISTS "${ABSEIL_CPP_INCLUDE_DIR}" AND NOT "${ABSEIL_CPP_INCLUDE_DIR}" STREQUAL "")

  if(NOT AbseilCpp_FIND_COMPONENTS)
    message(FATAL_ERROR "Please specify components to find for AbseilCpp.")
  endif()

  unset(ABSEIL_CPP_LIBRARIES CACHE)

  foreach(LIBNAME ${AbseilCpp_FIND_COMPONENTS})

    unset(ABSEIL_CPP_LIBRARY CACHE)

    find_library(ABSEIL_CPP_LIBRARY
                 NAMES ${LIBNAME}
                 HINTS ${ABSEIL_CPP_LIBRARIES_DIR_HINTS})

    if(ABSEIL_CPP_LIBRARY)
      list(APPEND ABSEIL_CPP_LIBRARIES ${ABSEIL_CPP_LIBRARY})
    else()
      message(FATAL_ERROR "\n"
        "abseil_cpp library \"${LIBNAME}\" not found in system path.\n"
        "Please provide locations using: -DABSEIL_CPP_LIBRARIES_DIR_HINTS:STRING=\"PATH\"\n")
    endif()

  endforeach()

  unset(LIBNAME CACHE)
  unset(ABSEIL_CPP_LIBRARY CACHE)

  set(ABSEIL_CPP_FOUND TRUE)
  message(STATUS "Found abseil_cpp libraries")

  set(ABSEIL_CPP_INCLUDE_DIR "${ABSEIL_CPP_INCLUDE_DIR}" CACHE PATH "" FORCE)
  mark_as_advanced(ABSEIL_CPP_INCLUDE_DIR)

  set(ABSEIL_CPP_LIBRARIES "${ABSEIL_CPP_LIBRARIES}" CACHE PATH "" FORCE)
  mark_as_advanced(ABSEIL_CPP_LIBRARIES)

else()

  message(FATAL_ERROR "\n"
    "abseil_cpp headers not found in system path.\n"
    "Please provide locations using: -DABSEIL_CPP_INCLUDE_DIR_HINTS:STRING=\"PATH\"\n")

endif()
