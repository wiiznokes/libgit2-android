#/bin/bash

set -e

rm -f ./../app/src/main/jniLibs/arm64-v8a/libgit2.so
cp ./build/libgit2.so ./../app/src/main/jniLibs/arm64-v8a/