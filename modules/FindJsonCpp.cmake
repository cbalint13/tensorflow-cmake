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
find_path(JSON_CPP_INCLUDE_DIR json/json.h
  HINTS "${JSON_CPP_INCLUDE_DIR_HINTS}"
  PATHS "$ENV{PROGRAMFILES}"
        "$ENV{PROGRAMW6432}"
  PATH_SUFFIXES "")

if(EXISTS "${JSON_CPP_INCLUDE_DIR}" AND NOT "${JSON_CPP_INCLUDE_DIR}" STREQUAL "")

  file(READ ${JSON_CPP_INCLUDE_DIR}/json/version.h JSON_CPP_VERSION_FILE_CONTENTS)

  # fetch jsoncpp version
  string(REGEX MATCH "define JSONCPP_VERSION_MAJOR * +([0-9]+)"
         JSON_CPP_VERSION_MAJOR "${JSON_CPP_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define JSONCPP_VERSION_MAJOR * +([0-9]+)" "\\1"
         JSON_CPP_VERSION_MAJOR "${JSON_CPP_VERSION_MAJOR}")
  string(REGEX MATCH "define JSONCPP_VERSION_MINOR * +([0-9]+)"
         JSON_CPP_VERSION_MINOR "${JSON_CPP_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define JSONCPP_VERSION_MINOR * +([0-9]+)" "\\1"
         JSON_CPP_VERSION_MINOR "${JSON_CPP_VERSION_MINOR}")
  string(REGEX MATCH "define JSONCPP_VERSION_PATCH * +([0-9]+)"
         JSON_CPP_VERSION_PATCH "${JSON_CPP_VERSION_FILE_CONTENTS}")
  string(REGEX REPLACE "define JSONCPP_VERSION_PATCH * +([0-9]+)" "\\1"
         JSON_CPP_VERSION_PATCH "${JSON_CPP_VERSION_PATCH}")
  if(NOT JSON_CPP_VERSION_MAJOR)
    set(JSON_CPP_VERSION "???")
  else()
    set(JSON_CPP_VERSION "${JSON_CPP_VERSION_MAJOR}.${JSON_CPP_VERSION_MINOR}.${JSON_CPP_VERSION_PATCH}")
  endif()

  unset(JSON_CPP_LIBRARIES CACHE)

  find_library(JSON_CPP_LIBRARY
               NAMES jsoncpp
               HINTS ${JSON_CPP_LIBRARIES_DIR_HINTS})

  if(JSON_CPP_LIBRARY)
    list(APPEND JSON_CPP_LIBRARIES ${JSON_CPP_LIBRARY})
  else()
    message(FATAL_ERROR "\n"
      "json_cpp library \"${LIBNAME}\" not found in system path.\n"
      "Please provide locations using: -DJSON_CPP_LIBRARIES_DIR_HINTS:STRING=\"PATH\"\n")
  endif()

  unset(JSON_CPP_LIBRARY CACHE)

  set(JSON_CPP_FOUND TRUE)
  message(STATUS "Found json_cpp libraries")

  set(JSON_CPP_INCLUDE_DIR "${JSON_CPP_INCLUDE_DIR}" CACHE PATH "" FORCE)
  mark_as_advanced(JSON_CPP_INCLUDE_DIR)

  set(JSON_CPP_LIBRARIES "${JSON_CPP_LIBRARIES}" CACHE PATH "" FORCE)
  mark_as_advanced(JSON_CPP_LIBRARIES)

else()

  message(FATAL_ERROR "\n"
    "json_cpp headers not found in system path.\n"
    "Please provide locations using: -DJSON_CPP_INCLUDE_DIR_HINTS:STRING=\"PATH\"\n")

endif()
