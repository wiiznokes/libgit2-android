#/bin/bash

# build libgit2
#
# ANDROID_ABI: arm64-v8a, armeabi-v7a, x86, x86_64
# ANDROID_API: 34
# BUILD_ALL: 0 or 1

set -xe

ANDROID_ABI=${ANDROID_ABI:-"arm64-v8a"}
ANDROID_API=${ANDROID_API:-34}
BUILD_ALL=${BUILD_ALL:-0}
NDK_VERSION=${NDK_VERSION:-"r27c"}
INSTALL_NDK=${INSTALL_NDK:-0}
CLEAN=${CLEAN:-0}

LIBGI2_DIR=${LIBGI2_DIR:-"$(pwd)"}
OPENSSL_DIR="${LIBGI2_DIR}/openssl"
LIBSSH2_DIR="${LIBGI2_DIR}/libssh2"

export ANDROID_NDK_ROOT=${ANDROID_NDK_ROOT:-"${LIBGI2_DIR}/android-ndk-${NDK_VERSION}"}
JNI_LIBS_PATH=${JNI_LIBS_PATH:-"../src/main/jniLibs/${ANDROID_ABI}"}

install_ndk() {
    wget "https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux.zip" > /dev/null 2>&1
    unzip ./android-ndk-${NDK_VERSION}-linux.zip > /dev/null 2>&1
}

build_openssl() {
    cd $OPENSSL_DIR
    PATH=$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

    case $ANDROID_ABI in
        "arm64-v8a")
            ANDROID_ABI_OPENSSL="android-arm64"
            ;;
        "armeabi-v7a")
            ANDROID_ABI_OPENSSL="android-arm"
            ;;
        "x86")
            ANDROID_ABI_OPENSSL="android-x86"
            ;;
        "x86_64")
            ANDROID_ABI_OPENSSL="android-x86_64"
            ;;
        *)
        echo "Erreur : Architecture non reconnue"
        return 1
        ;;
    esac

    ./Configure $ANDROID_ABI_OPENSSL -D__ANDROID_API__=$ANDROID_API
    make > /dev/null
}

build_libssh2() {
    cd $LIBSSH2_DIR
    mkdir build && cd build
    cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=${LIBGI2_DIR}/android-toolchain.cmake \
    -DCMAKE_SYSTEM_VERSION=${ANDROID_API} \
    -DCMAKE_ANDROID_ARCH_ABI=${ANDROID_ABI} \
    -DOPENSSL_INCLUDE_DIR=${OPENSSL_DIR}/include \
    -DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_DIR}/libcrypto.so \
    -DOPENSSL_SSL_LIBRARY=${OPENSSL_DIR}/libssl.so
    cmake --build . > /dev/null
}




build_libgit2() {
    cd $LIBGI2_DIR
    mkdir build && cd build
    find .. -name 'CMakeLists.txt' -exec sed -i 's|C_STANDARD 90|C_STANDARD 99|' {} \;
    cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=${LIBGI2_DIR}/android-toolchain.cmake \
    -DCMAKE_SYSTEM_VERSION=${ANDROID_API} \
    -DCMAKE_ANDROID_ARCH_ABI=${ANDROID_ABI} \
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
    cmake --build . > /dev/null
}

copy_libs() {
    cd $LIBGI2_DIR
    mkdir -p $1

    cp ${OPENSSL_DIR}/libcrypto.so $1
    echo "libcrypto.so copied to $1"

    cp ${OPENSSL_DIR}/libssl.so $1
    echo "libssl.so copied to $1"

    cp ${LIBSSH2_DIR}/build/src/libssh2.so $1
    echo "libssh2.so copied to $1"

    cp ${LIBGI2_DIR}/build/libgit2.so $1
    echo "libgit2.so copied to $1"
}

clean() {
    cd $OPENSSL_DIR
    make clean
    
    cd $LIBSSH2_DIR
    rm -r build
    
    cd $LIBGI2_DIR
    rm -r build
}


if [ "$BUILD_ALL" -eq 1 ]; then

    if [ "$INSTALL_NDK" -eq 1 ]; then
        install_ndk
    fi

    if [ "$CLEAN" -eq 1 ]; then
        clean
    fi

    build_openssl
    build_libssh2
    build_libgit2
    copy_libs $JNI_LIBS_PATH
fi