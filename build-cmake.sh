#!/bin/sh

rm -rf BUILD
mkdir BUILD

pushd BUILD

cmake .. \
      -Dsystemlib_ALL=ON \
      -DCMAKE_SKIP_RPATH=ON \
      -Dtensorflow_BUILD_SHARED_LIB=ON \
      -Dtensorflow_ENABLE_POSITION_INDEPENDENT_CODE=ON \
      -Dtensorflow_ENABLE_GPU=ON \
      -DCUDA_ARCH_NAME="Auto" \
      -Dtensorflow_WITH_PYTHON3=ON \
      -DCUDA_PROPAGATE_HOST_FLAGS=OFF \
      -DCUDA_HOST_COMPILER="/usr/bin/cuda-gcc" \
      -DCUDA_NVCC_FLAGS="--expt-relaxed-constexpr --compiler-options -fPIC --shared -shared -I/home/cbalint/rpmbuild/SOURCES/tensorflow/" \
      -Dtensorflow_CUDNN_INCLUDE="/usr/local/cuda/include"

popd

###
### small workarounds (TOFIX)
###

mkdir -p BUILD/cuda
ln -sf /usr/local/cuda/include  BUILD/cuda/include

mkdir -p BUILD/include
ln -sf /usr/include/json BUILD/include/json

mkdir -p BUILD/third_party
ln -sf /usr/include/nccl BUILD/third_party/nccl
