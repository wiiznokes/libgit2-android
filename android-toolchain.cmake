set(CMAKE_SYSTEM_NAME Android)
set(CMAKE_ANDROID_NDK "${ANDROID_NDK_ROOT}")

SET(CMAKE_C_COMPILER "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/clang")
SET(CMAKE_CXX_COMPILER "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++")
SET(CMAKE_FIND_ROOT_PATH "${CMAKE_ANDROID_NDK}/toolchains/llvm/prebuilt/linux-x86_64/sysroot")
