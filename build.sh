#/bin/bash

LIBGI2_DIR=$(pwd)
OPENSSL_DIR=${LIBGI2_DIR}/openssl
LIBSSH2_DIR=${LIBGI2_DIR}/libssh2


install_ndk() {
    wget https://dl.google.com/android/repository/android-ndk-r26b-linux.zip
    sudo unzip ./android-ndk-r26b-linux.zip -d /opt
}

build_openssl() {
    cd $OPENSSL_DIR
    export ANDROID_NDK_ROOT=/opt/android-ndk-r26b/
    PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
    ./Configure android-arm64 -D__ANDROID_API__=34
    make
    cd ..
}

build_libssh2() {
    cd $LIBSSH2_DIR
    mkdir build && cd build
    cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=${LIBGI2_DIR}/android-toolchain.cmake \
    -DOPENSSL_INCLUDE_DIR=${OPENSSL_DIR}/include \
    -DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_DIR}/libcrypto.so \
    -DOPENSSL_SSL_LIBRARY=${OPENSSL_DIR}/libssl.so
    cmake --build .
}




build_libgit2() {
    cd $LIBGI2_DIR
    mkdir build && cd build
    find .. -name 'CMakeLists.txt' -exec sed -i 's|C_STANDARD 90|C_STANDARD 99|' {} \;
    cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=${LIBGI2_DIR}/android-toolchain.cmake \
    -DOPENSSL_INCLUDE_DIR=${OPENSSL_DIR}/include \
    -DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_DIR}/libcrypto.so \
    -DOPENSSL_SSL_LIBRARY=${OPENSSL_DIR}/libssl.so \
    -DBUILD_SHARED_LIBS=ON \
    -DGIT_OPENSSL_DYNAMIC=true \
    -DBUILD_CLI=OFF \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_TESTS=OFF \
    -DCMAKE_C_FLAGS="-Wno-int-conversion -Wno-implicit-function-declaration" \
    -DUSE_SSH=ON \
    -DLIBSSH2_LIBRARY=${LIBSSH2_DIR}/build/src/libssh2.so \
    -DLIBSSH2_INCLUDE_DIR=${LIBSSH2_DIR}/include
    cmake --build .
}

copy_libs() {
    cd $LIBGI2_DIR
    cp ${OPENSSL_DIR}/libcrypto.so $1
    cp ${OPENSSL_DIR}/libssl.so $1
    cp ${LIBSSH2_DIR}/build/src/libssh2.so $1
    cp ${LIBGI2_DIR}/build/libgit2.so $1
}