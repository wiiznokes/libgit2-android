#/bin/bash

set -e


export ANDROID_ABI=arm64-v8a
export ANDROID_API=34

export LIBGI2_DIR=$(pwd)
export OPENSSL_DIR=${LIBGI2_DIR}/openssl
export LIBSSH2_DIR=${LIBGI2_DIR}/libssh2

export ANDROID_NDK_ROOT=${LIBGI2_DIR}/android-ndk-r26b

export JNI_LIBS_PATH=./../app/src/main/jniLibs/${ANDROID_ABI}/


install_ndk() {
    wget https://dl.google.com/android/repository/android-ndk-r26b-linux.zip
    sudo unzip ./android-ndk-r26b-linux.zip
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

    make clean
    ./Configure $ANDROID_ABI_OPENSSL -D__ANDROID_API__=$ANDROID_API
    make
    cd ..
}

build_libssh2() {
    cd $LIBSSH2_DIR
    make clean
    rm -r build
    mkdir build && cd build
    cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=${LIBGI2_DIR}/android-toolchain.cmake \
    -DCMAKE_SYSTEM_VERSION=${ANDROID_API} \
    -DCMAKE_ANDROID_ARCH_ABI=${ANDROID_ABI} \
    -DOPENSSL_INCLUDE_DIR=${OPENSSL_DIR}/include \
    -DOPENSSL_CRYPTO_LIBRARY=${OPENSSL_DIR}/libcrypto.so \
    -DOPENSSL_SSL_LIBRARY=${OPENSSL_DIR}/libssl.so
    cmake --build .
}




build_libgit2() {
    cd $LIBGI2_DIR
    make clean
    rm -r build
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
    cmake --build .
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

all () {

    build_openssl
    build_libssh2
    build_libgit2
    copy_libs $JNI_LIBS_PATH
}