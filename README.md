# litheum_wallet

This repository serves as a Mobile Wallet for Litheum Network.

## Pre-requisites

To begin, ensure that you have a working installation of the following items:
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Rust language](https://rustup.rs/)
- Appropriate [Rust targets](https://rust-lang.github.io/rustup/cross-compilation.html) for cross-compiling to your device
- For Android targets:
    - Install [cargo-ndk](https://github.com/bbqsrc/cargo-ndk#installing)
    - Install Android NDK, then put its path in one of the `gradle.properties`, e.g.:

```
echo "ANDROID_NDK=.." >> ~/.gradle/gradle.properties
```

- On our linux platform, we can make use of the Android setup to test app on Android Simulator. Following [this guide](http://cjycode.com/flutter_rust_bridge/template/setup_android.html)
- Install codegen & `just` cmd helper (a modern command runner alternative to `Make`), following [this guide](http://cjycode.com/flutter_rust_bridge/template/generate_install.html).
- If you want to play around with iOS/macOS setup, do [this](http://cjycode.com/flutter_rust_bridge/template/setup_ios.html) on your VM. 
- Checking out the [INSTALLATION.md](INSTALLATION.md) for more details.

## How-to run the app
After you all set with dev environment, if anytime you made a change on rust code in `native` dir, remember to run the list of commands below so that it re-generates new build/generated bridge files for us:
```
$ flutter clean
$ dart pub get
$ flutter pub get
$ just
$ flutter run
```
If you got some errors like below after run `just` command:
```
[SEVERE] : Header /tmp/.tmp7hjISB.h: Total errors/warnings: 1.
[SEVERE] :     /tmp/.tmp7hjISB.h:1:10: fatal error: 'stdbool.h' file not found [Lexical or Preprocessor Issue]
```
The error maybe caused by the missing `stdbool.h` / `stdarg.h` file even though you already installed clang, cmake, ninja, etc... on your linux machine. To fix it, you will need to add the path to `stdbool.h` file to your `PATH` and activate it:
```bash
export CPATH="$(clang -v 2>&1 | grep "Selected GCC installation" | rev | cut -d' ' -f1 | rev)/include"
```
It's better if you add that line to your `~/.bashrc` / `~/.zshrc` file (or any other shell you're using) to activate it permanently.


## IMPORTANT NOTES
- don't uncomment the package dependencies on our `native/Cargo.toml`, just replace by your local project dir instead.
At the moment, our repo is still private. If we use the git repo, it will lead to some permission errors when we run `flutter run`:
```
CMake Error at cmake_install.cmake:66 (file):
  file INSTALL cannot copy file
  "/home/thaodt/projects/LitheumOrg/LitheumMobileWallet/build/linux/x64/debug/intermediates_do_not_run/litheum_wallet"
  to "/usr/local/litheum_wallet": Permission denied.
```
i think will need to update `rust.cmake` in `linux/rust.cmake`, but lets do it later.