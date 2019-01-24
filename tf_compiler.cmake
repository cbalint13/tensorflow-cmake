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

file(GLOB compiler_ops_gen_targets
    "${tensorflow_source_dir}/tensorflow/compiler/jit/ops/xla_ops.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/tf2xla/ops/xla_ops.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/tf2tensorrt/ops/get_serialized_resource_op.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/tf2tensorrt/ops/trt_engine_op.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xrt/ops/xrt_compile_ops.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xrt/ops/xrt_execute_op.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/xrt/ops/xrt_state_ops.cc"
)

set(tf_compiler_ops_generated_files)
foreach(compiler_ops_gen_target ${compiler_ops_gen_targets})

    # basic names
    get_filename_component(compiler_ops_gen_path "${compiler_ops_gen_target}" DIRECTORY)
    get_filename_component(compiler_ops_gen_file "${compiler_ops_gen_target}" NAME)
    get_filename_component(compiler_ops_gen_name "${compiler_ops_gen_target}" NAME_WE)

    # composite unique name
    get_filename_component(compiler_ops_gen_short "${compiler_ops_gen_path}" DIRECTORY)
    get_filename_component(compiler_ops_gen_short "${compiler_ops_gen_short}" NAME)

    set(compiler_ops_gen_label "${compiler_ops_gen_name}_${compiler_ops_gen_short}")

    string(REPLACE "${tensorflow_source_dir}/" "" compiler_ops_target_dir "${compiler_ops_gen_path}")
    string(REPLACE "/ops" "/cc/ops" compiler_ops_target_dir "${compiler_ops_target_dir}")

    file(GLOB tf_${compiler_ops_gen_label}_srcs "${compiler_ops_gen_target}")

    set(compiler_ops_include_internal 0)
    if(${compiler_ops_gen_label} STREQUAL "xla_ops_jit")
        set(compiler_ops_include_internal 1)
    endif()

    add_library(tf_${compiler_ops_gen_label} OBJECT ${tf_${compiler_ops_gen_label}_srcs})
    add_dependencies(tf_${compiler_ops_gen_label} tf_core_framework)

    add_executable(${compiler_ops_gen_label}_gen_cc
        $<TARGET_OBJECTS:tf_cc_op_gen_main>
        $<TARGET_OBJECTS:tf_${compiler_ops_gen_label}>
        $<TARGET_OBJECTS:tf_core_lib>
        $<TARGET_OBJECTS:tf_core_framework>
        $<TARGET_OBJECTS:tf_protos_cc>
    )
    target_link_libraries(${compiler_ops_gen_label}_gen_cc PRIVATE
        ${tensorflow_EXTERNAL_LIBRARIES}
    )

    set(compiler_ops_target_dir ${CMAKE_CURRENT_BINARY_DIR}/${compiler_ops_target_dir})

    add_custom_target(${compiler_ops_gen_label}_header_dir
        COMMAND ${CMAKE_COMMAND} -E make_directory ${compiler_ops_target_dir}
    )

    if(NOT EXISTS "${compiler_ops_target_dir}/${compiler_ops_gen_name}.h" OR
       NOT EXISTS "${compiler_ops_target_dir}/${compiler_ops_gen_name}.cc" OR
       NOT EXISTS "${compiler_ops_target_dir}/${compiler_ops_gen_name}_internal.h" OR
       NOT EXISTS "${compiler_ops_target_dir}/${compiler_ops_gen_name}_internal.cc")
    add_custom_command(
          OUTPUT ${compiler_ops_target_dir}/${compiler_ops_gen_name}.h
                 ${compiler_ops_target_dir}/${compiler_ops_gen_name}.cc
                 ${compiler_ops_target_dir}/${compiler_ops_gen_name}_internal.h
                 ${compiler_ops_target_dir}/${compiler_ops_gen_name}_internal.cc
          COMMAND ${compiler_ops_gen_label}_gen_cc ${compiler_ops_target_dir}/${compiler_ops_gen_name}.h ${compiler_ops_target_dir}/${compiler_ops_gen_name}.cc ${compiler_ops_include_internal} ${tensorflow_source_dir}/tensorflow/core/api_def/base_api
          DEPENDS ${compiler_ops_gen_label}_gen_cc ${compiler_ops_gen_label}_header_dir
    )
    endif()

    list(APPEND tf_compiler_ops_generated_files ${compiler_ops_target_dir}/${compiler_ops_gen_name}.h)
    list(APPEND tf_compiler_ops_generated_files ${compiler_ops_target_dir}/${compiler_ops_gen_name}.cc)
    list(APPEND tf_compiler_ops_generated_files ${compiler_ops_target_dir}/${compiler_ops_gen_name}_internal.h)
    list(APPEND tf_compiler_ops_generated_files ${compiler_ops_target_dir}/${compiler_ops_gen_name}_internal.cc)
endforeach()

########################################################
# tf_compiler library
########################################################

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
    "${tensorflow_source_dir}/tensorflow/compiler/tf2tensorrt/*.h"
    "${tensorflow_source_dir}/tensorflow/compiler/tf2tensorrt/*.cc"
)

file(GLOB_RECURSE tf_compiler_srcs_exclude
    "${tensorflow_source_dir}/tensorflow/compiler/*/python/*"
    "${tensorflow_source_dir}/tensorflow/compiler/*/*_main.cc"
    "${tensorflow_source_dir}/tensorflow/compiler/jit/node_matchers.cc"
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
    "${tensorflow_source_dir}/tensorflow/compiler/*/tests/*"
)
list(REMOVE_ITEM tf_compiler_srcs ${tf_compiler_test_srcs})

add_library(tf_compiler OBJECT ${tf_compiler_srcs} ${tf_compiler_ops_generated_files})

add_dependencies(tf_compiler tf_core_ops)
