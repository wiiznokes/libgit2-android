set(CMAKE_SYSTEM_NAME Android)
#set(ANDROID_NDK_ROOT /opt/android-ndk-r26b)

SET(CMAKE_C_COMPILER "${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/clang")
SET(CMAKE_CXX_COMPILER "${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin/clang++")
SET(CMAKE_FIND_ROOT_PATH "${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/sysroot")
