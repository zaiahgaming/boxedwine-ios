cmake_minimum_required(VERSION 3.14)
project(BoxedwineGame C CXX OBJC OBJCXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Configure iOS Bundle metadata & Game category for iOS Game Mode
set(CMAKE_XCODE_ATTRIBUTE_LSApplicationCategoryType "public.app-category.games")
set(CMAKE_XCODE_ATTRIBUTE_INFOPLIST_FILE "${CMAKE_CURRENT_SOURCE_DIR}/iOS/Info.plist")
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS "${CMAKE_CURRENT_SOURCE_DIR}/iOS/BoxedwineApp.entitlements")

include_directories(
    ${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/include
    ${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/source
    ${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/platform/sdl
    ${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/lib
    ${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/lib/simde
    ${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/lib/asmjit
    ${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/lib/zlib
    ${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/lib/softfloat
    ${CMAKE_CURRENT_SOURCE_DIR}/iOS
)

file(GLOB_RECURSE BOXEDWINE_SOURCES
    "${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/source/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/platform/sdl/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/lib/softfloat/*.cpp"
    "${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/lib/softfloat/*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine/lib/zlib/*.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/iOS/*.m"
    "${CMAKE_CURRENT_SOURCE_DIR}/iOS/*.c"
)

add_executable(BoxedwineGame WIN32 MACOSX_BUNDLE
    ${BOXEDWINE_SOURCES}
)

# Link iOS Native Frameworks (UIKit, AVFoundation, AudioToolbox, Foundation, CoreGraphics)
target_link_libraries(BoxedwineGame PRIVATE
    "-framework UIKit"
    "-framework AVFoundation"
    "-framework AudioToolbox"
    "-framework Foundation"
    "-framework CoreGraphics"
)

target_compile_options(BoxedwineGame PRIVATE
    -O3
    -ffast-math
    -flto
    -DBOXEDWINE_IOS
    -DBOXEDWINE_SDL
    -DBOXEDWINE_MULTI_THREADED
    -DBOXEDWINE_JIT
    -DBOXEDWINE_JIT_ARMV8
    -DASMJIT_STATIC
)

set_target_properties(BoxedwineGame PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.boxedwine.emulator.game"
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/iOS/Info.plist"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2" # iPhone & iPad
    XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
)
