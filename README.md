# Custom repo

# Add this repo to your project
```
git submodule add --depth 1 --branch patch-android -- https://github.com/wiiznokes/libgit2-android
```

# Build
```
sudo apt install build-essential unzip cmake
source ./build.sh
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
