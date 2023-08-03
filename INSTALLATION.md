# Installation Detail
1. All of us is using Linux, therefore I will point directly to [this installation link](https://docs.flutter.dev/get-started/install/linux). 
In the official docs, there are 2 choices, but i recommended [installing manually](https://docs.flutter.dev/get-started/install/linux#install-flutter-manually) (`snapd` option is not recommended for Arch Linux, it's not stable yet).

    After installed successfully, you will need to add `flutter` to your `PATH` and activate it to use `flutter` & `dart` commands. Linux uses the Bash shell by default, so edit `$HOME/.bashrc`. If you are using a different shell (zsh, tmux, etc...), the file path and filename will be different on your machine.
    for e.g. in my case:
    ```bash 
    export PATH="$PATH:/home/thaodt/projects/flutter/bin"
    ```

2. Run `flutter doctor` (a **super useful** command!! DONT MISS IT!)
    ```bash
    $ flutter doctor -v
    ```
- This command checks your environment and displays a report to the terminal window. The Dart SDK is bundled with Flutter; it is not necessary to install Dart separately. 
- Please notice the RED check marks, you may need to install or further tasks to perform (shown in **bold** text).

- You may need to install Android Studio to use Android Emulator.
Just go to our https://aur.archlinux.org/packages/android-studio, clone & make build it (`makepkg -si`).

- Next install [`cargo-ndk`](https://github.com/bbqsrc/cargo-ndk#installing), add rust target cross compilation.

- Install NDK side-by-side with Android Studio, follow [this guide](http://cjycode.com/flutter_rust_bridge/template/setup_android.html#android_ndk).

- Finally for Android setup, you will need to [put its path](http://cjycode.com/flutter_rust_bridge/template/setup_android.html#android_ndk-gradle-property) in one of the `gradle.properties`, e.g.:
```
echo "ANDROID_NDK=(path to NDK)" >> ~/.gradle/gradle.properties
```
You may want to update that path in `LitheumMobileWallet/android/gradle.properties`, im putting my path (`ANDROID_NDK`) in that file.

- Add your NDK path to your `PATH` and activate it: `export ANDROID_NDK_HOME=/home/thaodt/Android/Sdk/ndk` (replace by your local path).

- Rerun `flutter doctor -v` again to see all green checks.

- [Optional] Install codegen & `just` cmd helper (a modern command runner alternative to `Make`), following [this guide](http://cjycode.com/flutter_rust_bridge/template/generate_install.html).

Please see my sample output for `flutter doctor -v` once all green checks:
```bash
[✓] Flutter (Channel stable, 3.10.6, on Arch Linux 6.4.7-arch1-2, locale en_US.UTF-8)
    • Flutter version 3.10.6 on channel stable at /home/thaodt/projects/flutter
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision f468f3366c (3 weeks ago), 2023-07-12 15:19:05 -0700
    • Engine revision cdbeda788a
    • Dart version 3.0.6
    • DevTools version 2.23.1

[✓] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
    • Android SDK at /home/thaodt/Android/Sdk
    • Platform android-34, build-tools 34.0.0
    • Java binary at: /opt/android-studio/jbr/bin/java
    • Java version OpenJDK Runtime Environment (build 17.0.6+0-17.0.6b829.9-10027231)
    • All Android licenses accepted.

[✓] Chrome - develop for the web
    • CHROME_EXECUTABLE = /usr/bin/google-chrome-stable

[✓] Linux toolchain - develop for Linux desktop
    • clang version 15.0.7
    • cmake version 3.27.1
    • ninja version 1.11.1
    • pkg-config version 1.8.1

[✓] Android Studio (version 2022.3)
    • Android Studio at /opt/android-studio
    • Flutter plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/9212-flutter
    • Dart plugin can be installed from:
      🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 17.0.6+0-17.0.6b829.9-10027231)

[✓] Connected device (2 available)
    • Linux (desktop) • linux  • linux-x64      • Arch Linux 6.4.7-arch1-2
    • Chrome (web)    • chrome • web-javascript • Google Chrome 114.0.5735.198

[✓] Network resources
    • All expected network resources are available.

• No issues found!
```

If your setup environment is ready, go to [`How-to`](/README.md#how-to) section in `README` to run the app.

## Project Structure
This project should be available if you create a new Flutter project by command `flutter init`, but i made use of the template from author.
Just a bit different from the original flutter project initialization, you will see `native` dir. Its our Rust code, `api.rs` is pub ffi fns which we want to export for Dart code.

`flutter_rust_brigde` dependency package helped us generated `bridge_generated.rs` & `LitheumMobileWallet/lib/bridge_generated.dart`.

So all `lib` files is DART code & `native` is our RUST code. 

As long as we don't touch GUI code on android/ios app, it's fine to use vscode or any editors/IDEs.

Another good news, Package's author is very active. 
He almost replied/supported within 10 mins, so if any queries, we can ping/create issue in his github repository.
