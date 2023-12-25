# libgit2-android

# Add this repo to your project

```
git submodule add --depth 1 --branch patch-android -- https://github.com/wiiznokes/libgit2-android
```

# Build

```
sudo apt install build-essential unzip cmake

git submodule init
git submodule update


source ./build.sh

export ANDROID_API=34
export ANDROID_ABI=arm64-v8a
export LIBGI2_DIR=path_to_this_repo

install_ndk
build_openssl
build_libssh2
build_libgit2
copy_libs $output_path
```

```
ls ./app/src/main/jniLibs/arm64-v8a/
libcrypto.so  libgit2.so  libssh2.so  libssl.so
```


# Supported ANDROID_ABI

- arm64-v8a
- armeabi-v7a
- x86
- x86_64


Can you write a bash script that take a variable $ANDROID_ABI
and set a variable ANDROID_ABI_OPENSSL like this :

$ANDROID_ABI -> $ANDROID_ABI_OPENSSL
- arm64-v8a -> android-arm64
- armeabi-v7a -> android-arm
- x86 -> android-x86
- x86_64 -> android-x86_64

export ANDROID_ABI=x86_64