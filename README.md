# Custom repo

# Build
```
sudo apt install build-essential unzip cmake
source ./build.sh
install_ndk
build_openssl
build_libssh2
build_libgit2
copy_libs $output_path
```

To create submodules
```
git submodule add --depth 1 --branch master -- https://github.com/openssl/openssl
git submodule add --depth 1 --branch master -- https://github.com/libssh2/libssh2
```

