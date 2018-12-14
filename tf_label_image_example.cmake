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
set(tf_label_image_example_srcs
    "${tensorflow_source_dir}/tensorflow/examples/label_image/main.cc"
)

add_executable(tf_label_image_example
    ${tf_label_image_example_srcs}
)

target_link_libraries(tf_label_image_example PUBLIC
    tensorflow
    ${tensorflow_EXTERNAL_LIBRARIES}
)

install(TARGETS tf_label_image_example
        RUNTIME DESTINATION bin
        LIBRARY DESTINATION lib
        ARCHIVE DESTINATION lib)