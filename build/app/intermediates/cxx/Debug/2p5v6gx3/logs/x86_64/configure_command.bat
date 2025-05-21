@echo off
"C:\\Users\\losac\\AppData\\Local\\Android\\sdk\\cmake\\3.22.1\\bin\\cmake.exe" ^
  "-HC:\\Users\\losac\\flutterdev\\flutter_windows_3.29.2-stable\\flutter\\packages\\flutter_tools\\gradle\\src\\main\\groovy" ^
  "-DCMAKE_SYSTEM_NAME=Android" ^
  "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON" ^
  "-DCMAKE_SYSTEM_VERSION=23" ^
  "-DANDROID_PLATFORM=android-23" ^
  "-DANDROID_ABI=x86_64" ^
  "-DCMAKE_ANDROID_ARCH_ABI=x86_64" ^
  "-DANDROID_NDK=C:\\Users\\losac\\AppData\\Local\\Android\\Sdk\\ndk\\29.0.13113456" ^
  "-DCMAKE_ANDROID_NDK=C:\\Users\\losac\\AppData\\Local\\Android\\Sdk\\ndk\\29.0.13113456" ^
  "-DCMAKE_TOOLCHAIN_FILE=C:\\Users\\losac\\AppData\\Local\\Android\\Sdk\\ndk\\29.0.13113456\\build\\cmake\\android.toolchain.cmake" ^
  "-DCMAKE_MAKE_PROGRAM=C:\\Users\\losac\\AppData\\Local\\Android\\sdk\\cmake\\3.22.1\\bin\\ninja.exe" ^
  "-DCMAKE_LIBRARY_OUTPUT_DIRECTORY=C:\\Users\\losac\\OneDrive\\Archivos 2016\\Documentos\\Escuela\\movil\\MiFinansas\\build\\app\\intermediates\\cxx\\Debug\\2p5v6gx3\\obj\\x86_64" ^
  "-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=C:\\Users\\losac\\OneDrive\\Archivos 2016\\Documentos\\Escuela\\movil\\MiFinansas\\build\\app\\intermediates\\cxx\\Debug\\2p5v6gx3\\obj\\x86_64" ^
  "-DCMAKE_BUILD_TYPE=Debug" ^
  "-BC:\\Users\\losac\\OneDrive\\Archivos 2016\\Documentos\\Escuela\\movil\\MiFinansas\\android\\app\\.cxx\\Debug\\2p5v6gx3\\x86_64" ^
  -GNinja ^
  -Wno-dev ^
  --no-warn-unused-cli
