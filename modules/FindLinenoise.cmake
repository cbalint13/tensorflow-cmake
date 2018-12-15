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
find_path(LINENOISE_INCLUDE_DIR linenoise.h
  HINTS "${LINENOISE_INCLUDE_DIR_HINTS}"
  PATHS "$ENV{PROGRAMFILES}"
        "$ENV{PROGRAMW6432}"
  PATH_SUFFIXES "")

if(EXISTS "${LINENOISE_INCLUDE_DIR}" AND NOT "${LINENOISE_INCLUDE_DIR}" STREQUAL "")

  unset(LINENOISE_LIBRARIES CACHE)

  find_library(LINENOISE_LIBRARY
               NAMES linenoise
               HINTS ${LINENOISE_LIBRARIES_DIR_HINTS})

  if(LINENOISE_LIBRARY)
    list(APPEND LINENOISE_LIBRARIES ${LINENOISE_LIBRARY})
  else()
    message(FATAL_ERROR "\n"
      "linenoise library \"${LIBNAME}\" not found in system path.\n"
      "Please provide locations using: -DLINENOISE_LIBRARIES_DIR_HINTS:STRING=\"PATH\"\n")
  endif()

  unset(LINENOISE_LIBRARY CACHE)

  set(LINENOISE_FOUND TRUE)
  message(STATUS "Found linenoise libraries")

  set(LINENOISE_INCLUDE_DIR "${LINENOISE_INCLUDE_DIR}" CACHE PATH "" FORCE)
  mark_as_advanced(LINENOISE_INCLUDE_DIR)

  set(LINENOISE_LIBRARIES "${LINENOISE_LIBRARIES}" CACHE PATH "" FORCE)
  mark_as_advanced(LINENOISE_LIBRARIES)

else()

  message(FATAL_ERROR "\n"
    "linenoise headers not found in system path.\n"
    "Please provide locations using: -DLINENOISE_INCLUDE_DIR_HINTS:STRING=\"PATH\"\n")

endif()
