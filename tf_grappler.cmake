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
########################################################
# tf_grappler library
########################################################
file(GLOB_RECURSE tf_grappler_srcs
    "${tensorflow_source_dir}/tensorflow/core/grappler/*.h"
    "${tensorflow_source_dir}/tensorflow/core/grappler/*.cc"
    "${tensorflow_source_dir}/tensorflow/core/grappler/*/*.h"
    "${tensorflow_source_dir}/tensorflow/core/grappler/*/*.cc"
)

file(GLOB_RECURSE tf_grappler_test_srcs
    "${tensorflow_source_dir}/tensorflow/core/grappler/*test*.cc"
    "${tensorflow_source_dir}/tensorflow/core/grappler/*/*test*.cc"
)
list(REMOVE_ITEM tf_grappler_srcs ${tf_grappler_test_srcs})


file(GLOB_RECURSE tf_grappler_gpu_srcs
    "${tensorflow_source_dir}/tensorflow/core/grappler/devices.h"
    "${tensorflow_source_dir}/tensorflow/core/grappler/devices.cc"
)
list(REMOVE_ITEM tf_grappler_srcs ${tf_grappler_gpu_srcs})

if (tensorflow_ENABLE_GPU)
  list(APPEND tf_grappler_srcs ${tf_grappler_gpu_srcs})
endif()

add_library(tf_grappler OBJECT ${tf_grappler_srcs})

add_dependencies(tf_grappler tf_core_cpu tf_cc_ops)
