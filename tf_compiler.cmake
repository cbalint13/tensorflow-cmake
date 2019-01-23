# Copyright 2019 The TensorFlow Authors. All Rights Reserved.
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

########################################################
# tf_gen_op_wrapper_cc executables
########################################################

# create directory for ops generated files
#set(compiler_ops_target_dir ${CMAKE_CURRENT_BINARY_DIR}/tensorflow/compiler/tf2xla/cc/ops)
#add_custom_target(create_compiler_ops_header_dir
#    COMMAND ${CMAKE_COMMAND} -E make_directory ${compiler_ops_target_dir}
#)
#set(tf_compiler_ops_generated_files)
#add_executable(xla_ops_gen_cc
#        $<TARGET_OBJECTS:tf_cc_op_gen_main>
#        "${tensorflow_source_dir}/tensorflow/compiler/jit/ops/xla_ops.cc"
#        $<TARGET_OBJECTS:tf_core_lib>
#        $<TARGET_OBJECTS:tf_core_framework>
#        $<TARGET_OBJECTS:tf_protos_cc>
#)
#target_link_libraries(xla_ops_gen_cc PRIVATE
#        ${tensorflow_EXTERNAL_LIBRARIES}
#)
#set(compiler_ops_include_internal 0)
#
#    if(NOT EXISTS "${compiler_ops_target_dir}/xla_jit_ops.h" OR
#       NOT EXISTS "${compiler_ops_target_dir}/xla_jit_ops.cc" OR
#       NOT EXISTS "${compiler_ops_target_dir}/xla_jit_ops_internal.h" OR
#       NOT EXISTS "${compiler_ops_target_dir}/xla_jit_ops_internal.cc")
#      add_custom_command(
#          OUTPUT ${compiler_ops_target_dir}/xla_jit_ops.h
#                 ${compiler_ops_target_dir}/xla_jit_ops.cc
#                 ${compiler_ops_target_dir}/xla_jit_ops_internal.h
#                 ${compiler_ops_target_dir}/xla_jit_ops_internal.cc
#          COMMAND xla_ops_gen_cc ${compiler_ops_target_dir}/xla_jit_ops.h ${compiler_ops_target_dir}/xla_jit_ops.cc ${compiler_ops_include_internal} ${tensorflow_source_dir}/tensorflow/core/api_def/base_api
#          DEPENDS xla_ops_gen_cc create_compiler_ops_header_dir
#      )
#    endif()
#
#    list(APPEND tf_compiler_ops_generated_files ${compiler_ops_target_dir}/xla_jit_ops.h)
#    list(APPEND tf_compiler_ops_generated_files ${compiler_ops_target_dir}/xla_jit_ops.cc)
#    list(APPEND tf_compiler_ops_generated_files ${compiler_ops_target_dir}/xla_jit_ops_internal.h)
#    list(APPEND tf_compiler_ops_generated_files ${compiler_ops_target_dir}/xla_jit_ops_internal.cc)

########################################################
# tf_compiler library
########################################################

if(tensorflow_ENABLE_EXPERIMENTAL)
  file(GLOB_RECURSE tf_compiler_srcs
      "${tensorflow_source_dir}/tensorflow/compiler/aot/*.h"
      "${tensorflow_source_dir}/tensorflow/compiler/aot/*.cc"
      "${tensorflow_source_dir}/tensorflow/compiler/jit/*.h"
      "${tensorflow_source_dir}/tensorflow/compiler/jit/*.cc"
      "${tensorflow_source_dir}/tensorflow/compiler/xla/*.h"
      "${tensorflow_source_dir}/tensorflow/compiler/xla/*.cc"
      "${tensorflow_source_dir}/tensorflow/compiler/xrt/*.h"
      "${tensorflow_source_dir}/tensorflow/compiler/xrt/*.cc"
      "${tensorflow_source_dir}/tensorflow/compiler/tf2xla/*.h"
      "${tensorflow_source_dir}/tensorflow/compiler/tf2xla/*.cc"
  )
else()
  set(tf_compiler_srcs
      "${tensorflow_source_dir}/tensorflow/compiler/xla/parse_flags_from_env.cc"
      "${tensorflow_source_dir}/tensorflow/compiler/xla/parse_flags_from_env.h"
  )
endif()

file(GLOB_RECURSE tf_compiler_srcs_exclude
    "${tensorflow_source_dir}/tensorflow/compiler/*/python/*"
    "${tensorflow_source_dir}/tensorflow/compiler/*/*_main.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/jit/ops/*"
    "${tensorflow_source_dir}/tensorflow/compiler/jit/node_matchers.*"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/tests/*"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/tools/*computation*"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/tools/show_*.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/tools/*_to_*.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/tools/interactive_graphviz.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/service/hlo_matchers.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/service/graphviz_example.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/service/sample_harness.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/service/grpc_service_main.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/rpc/grpc_service.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xla/rpc/grpc_stub.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/tf2tensorrt/utils/test_utils.*"
)
list(REMOVE_ITEM tf_compiler_srcs ${tf_compiler_srcs_exclude})


file(GLOB_RECURSE tf_compiler_test_srcs
    "${tensorflow_source_dir}/tensorflow/compiler/*test*.h"
    "${tensorflow_source_dir}/tensorflow/compiler/*test*.cc"
)
list(REMOVE_ITEM tf_compiler_srcs ${tf_compiler_test_srcs})

add_library(tf_compiler OBJECT ${tf_compiler_srcs} ${tf_compiler_ops_generated_files})

add_dependencies(tf_compiler tf_core_ops)
