git clone --depth 1 https://github.com/range3/tsdivider.git
cd tsdivider

mkdir build && cd build

cmake \
    -DCMAKE_INSTALL_PREFIX="/opt/tsdivider" \
    -DCMAKE_BUILD_TYPE=Release ..

make -j$(proc)
make install

cd ..
rm -r build