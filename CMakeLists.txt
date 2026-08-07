cmake_minimum_required(VERSION 3.14)
project(BoxedwineGame C CXX OBJC OBJCXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)

# ==============================================================================
# Paths
# ==============================================================================
set(BW_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/Boxedwine)

# ==============================================================================
# Build SDL2 from bundled source for iOS
# ==============================================================================
set(SDL2_DIR ${BW_ROOT}/lib/sdl2)
set(IOS TRUE CACHE BOOL "" FORCE)   # Tell SDL2 we're building for iOS
set(SDL_SHARED OFF CACHE BOOL "" FORCE)
set(SDL_STATIC ON CACHE BOOL "" FORCE)
set(SDL_TEST OFF CACHE BOOL "" FORCE)
set(SDL_HIDAPI OFF CACHE BOOL "" FORCE)
set(SDL_JOYSTICK OFF CACHE BOOL "" FORCE)
set(SDL_HAPTIC OFF CACHE BOOL "" FORCE)
set(SDL_SENSOR OFF CACHE BOOL "" FORCE)

# Ensure OBJC language is enabled globally before SDL2 subdirectory
enable_language(OBJC)
enable_language(OBJCXX)

add_subdirectory(${SDL2_DIR} ${CMAKE_BINARY_DIR}/sdl2-build EXCLUDE_FROM_ALL)
target_compile_options(SDL2-static PRIVATE -Wno-error)

# ==============================================================================
# Gather Boxedwine engine sources
# ==============================================================================

# Core engine
file(GLOB_RECURSE BW_ENGINE_CPP "${BW_ROOT}/source/*.cpp")
file(GLOB_RECURSE BW_ENGINE_C   "${BW_ROOT}/source/*.c")

# Remove UI sources (we use our own native UIKit UI, not imgui)
file(GLOB_RECURSE _UI_SRCS "${BW_ROOT}/source/ui/*.cpp")
if(_UI_SRCS)
    list(REMOVE_ITEM BW_ENGINE_CPP ${_UI_SRCS})
endif()

# Remove test sources
file(GLOB_RECURSE _TEST_SRCS "${BW_ROOT}/source/test/*.cpp")
if(_TEST_SRCS)
    list(REMOVE_ITEM BW_ENGINE_CPP ${_TEST_SRCS})
endif()

# Remove Vulkan sources (not available on iOS)
file(GLOB_RECURSE _VULKAN_SRCS "${BW_ROOT}/source/vulkan/*.cpp")
if(_VULKAN_SRCS)
    list(REMOVE_ITEM BW_ENGINE_CPP ${_VULKAN_SRCS})
endif()

# Remove X11 sources (not used on macOS/iOS — Mac Xcode project excludes these)
file(GLOB_RECURSE _X11_SRCS "${BW_ROOT}/source/x11/*.cpp" "${BW_ROOT}/source/x11/*.c")
if(_X11_SRCS)
    list(REMOVE_ITEM BW_ENGINE_CPP ${_X11_SRCS})
    list(REMOVE_ITEM BW_ENGINE_C ${_X11_SRCS})
endif()

# Platform layers — macOS/iOS (POSIX) + SDL
file(GLOB BW_PLAT_SDL   "${BW_ROOT}/platform/sdl/*.cpp")
file(GLOB BW_PLAT_MAC_CPP "${BW_ROOT}/platform/mac/*.cpp")
list(REMOVE_ITEM BW_PLAT_MAC_CPP "${BW_ROOT}/platform/mac/pixelformat.cpp")
file(GLOB BW_PLAT_MAC_MM  "${BW_ROOT}/platform/mac/*.mm")
list(REMOVE_ITEM BW_PLAT_MAC_MM "${BW_ROOT}/platform/mac/macOpenGL.mm")

# Bundled libraries
file(GLOB_RECURSE BW_LIB_ASMJIT     "${BW_ROOT}/lib/asmjit/src/*.cpp")
file(GLOB BW_LIB_ZLIB       "${BW_ROOT}/lib/zlib/*.c")
file(GLOB BW_LIB_SFLOAT_C   "${BW_ROOT}/lib/softfloat/source/*.c" "${BW_ROOT}/lib/softfloat/source/8086-SSE/*.c")
file(GLOB BW_LIB_SFLOAT_CPP "${BW_ROOT}/lib/softfloat/source/*.cpp" "${BW_ROOT}/lib/softfloat/source/8086-SSE/*.cpp")
file(GLOB         BW_LIB_PUGIXML    "${BW_ROOT}/lib/pugixml/src/*.cpp")
file(GLOB_RECURSE BW_LIB_MESA       "${BW_ROOT}/lib/mesa/src/*.c")

# ==============================================================================
# Our iOS App Sources
# ==============================================================================
set(IOS_APP_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/iOS/AppMain.m
    ${CMAKE_CURRENT_SOURCE_DIR}/iOS/GameHubViewController.m
    ${CMAKE_CURRENT_SOURCE_DIR}/iOS/iOS_JIT_Compiler.c
)

# ==============================================================================
# Build Target
# ==============================================================================
add_executable(BoxedwineGame MACOSX_BUNDLE
    ${BW_ENGINE_CPP}
    ${BW_ENGINE_C}
    ${BW_PLAT_SDL}
    ${BW_PLAT_MAC_CPP}
    ${BW_PLAT_MAC_MM}
    ${BW_LIB_ASMJIT}
    ${BW_LIB_ZLIB}
    ${BW_LIB_SFLOAT_C}
    ${BW_LIB_SFLOAT_CPP}
    ${BW_LIB_PUGIXML}
    ${BW_LIB_MESA}
    ${IOS_APP_SOURCES}
)

# ==============================================================================
# Include Directories
# ==============================================================================
target_include_directories(BoxedwineGame PRIVATE
    ${BW_ROOT}/include
    ${BW_ROOT}/source
    ${BW_ROOT}/source/util
    ${BW_ROOT}/source/io
    ${BW_ROOT}/source/kernel
    ${BW_ROOT}/source/kernel/proc
    ${BW_ROOT}/source/kernel/loader
    ${BW_ROOT}/source/kernel/devs
    ${BW_ROOT}/source/emulation/cpu
    ${BW_ROOT}/source/emulation/cpu/common
    ${BW_ROOT}/source/emulation/cpu/x64
    ${BW_ROOT}/source/emulation/cpu/armv8bt
    ${BW_ROOT}/source/emulation/softmmu
    ${BW_ROOT}/source/emulation/hardmmu
    ${BW_ROOT}/source/opengl
    ${BW_ROOT}/source/sdl
    ${BW_ROOT}/platform/sdl
    ${BW_ROOT}/platform/mac
    ${BW_ROOT}/lib
    ${BW_ROOT}/lib/simde
    ${BW_ROOT}/lib/asmjit/src
    ${BW_ROOT}/lib/zlib
    ${BW_ROOT}/lib/softfloat/source/include
    ${BW_ROOT}/lib/softfloat/source/8086-SSE
    ${BW_ROOT}/lib/pugixml/src
    ${BW_ROOT}/lib/glew/include
    ${BW_ROOT}/lib/mesa/include
    ${SDL2_DIR}/include
    ${CMAKE_BINARY_DIR}/sdl2-build/include
    ${CMAKE_CURRENT_SOURCE_DIR}/iOS
)

# ==============================================================================
# Preprocessor Defines
# Matches the official Boxedwine Xcode project for ARM64, adapted for iOS
# ==============================================================================
target_compile_definitions(BoxedwineGame PRIVATE
    SIMDE_NO_NATIVE
    BOXEDWINE_64
    BOXEDWINE_ZLIB
    BOXEDWINE_POSIX
    BOXEDWINE_MAC_JIT            # ARM64 JIT via MAP_JIT
    BOXEDWINE_DISABLE_UI         # No imgui — our UIKit is the frontend
    BOXEDWINE_IOS                # Our own iOS marker
    BOXEDWINE_OPENGL_OSMESA      # Software OpenGL via mesa
    GLAPI=extern                 # Fix missing GLAPI on iOS
    GLAPIENTRY=                  # Fix missing GLAPIENTRY on iOS
    BOXEDWINE_CORE_AUDIO         # CoreAudio on iOS
    ASMJIT_STATIC
    ASMJIT_NO_X86                # ARM64 only
    __MACOSX_CORE__
    SDL2=1
    SDL_MAIN_HANDLED             # We provide our own main()
)

# ==============================================================================
# Link Libraries
# ==============================================================================
target_link_libraries(BoxedwineGame PRIVATE
    SDL2-static
    "-framework UIKit"
    "-framework AVFoundation"
    "-framework AudioToolbox"
    "-framework Foundation"
    "-framework CoreGraphics"
    "-framework CoreAudio"
    "-framework AudioUnit"
    "-framework Metal"
    "-framework QuartzCore"
    "-framework GameController"
    "-framework CoreHaptics"
    "-framework CoreMotion"
    "-framework CoreServices"
    "-framework OpenGLES"
    "-framework CoreFoundation"
    "-framework Security"
    "-framework CoreVideo"
)

# ==============================================================================
# Compiler Flags
# ==============================================================================
target_compile_options(BoxedwineGame PRIVATE
    -O2
    -Wno-deprecated-declarations
    -Wno-shorten-64-to-32
    -Wno-nullability-completeness
    -Wno-unused-variable
    -Wno-unused-function
    -Wno-sign-compare
    -Wno-reorder
    -Wno-missing-braces
)

# ObjC files need ARC
set_source_files_properties(
    ${CMAKE_CURRENT_SOURCE_DIR}/iOS/AppMain.m
    ${CMAKE_CURRENT_SOURCE_DIR}/iOS/GameHubViewController.m
    PROPERTIES COMPILE_FLAGS "-fobjc-arc"
)

# ==============================================================================
# Bundle Configuration
# ==============================================================================
set(MACOSX_BUNDLE_GUI_IDENTIFIER "com.boxedwine.emulator.game")

set_target_properties(BoxedwineGame PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.boxedwine.emulator.game"
    MACOSX_BUNDLE_BUNDLE_NAME "Boxedwine Game"
    MACOSX_BUNDLE_BUNDLE_VERSION "1"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0.0"
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_CURRENT_SOURCE_DIR}/iOS/Info.plist"
    XCODE_ATTRIBUTE_TARGETED_DEVICE_FAMILY "1,2"
    XCODE_ATTRIBUTE_ENABLE_BITCODE "NO"
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.boxedwine.emulator.game"
    XCODE_ATTRIBUTE_CODE_SIGN_ENTITLEMENTS "${CMAKE_CURRENT_SOURCE_DIR}/iOS/BoxedwineApp.entitlements"
    XCODE_ATTRIBUTE_INFOPLIST_FILE "${CMAKE_CURRENT_SOURCE_DIR}/iOS/Info.plist"
    XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS "@executable_path/Frameworks"
    XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++20"
)
