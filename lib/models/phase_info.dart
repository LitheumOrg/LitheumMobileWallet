import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:fast_base58/fast_base58.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:litheum_wallet/bridge_generated.dart';
import 'package:litheum_wallet/models/app_state.dart';
import 'package:litheum_wallet/models/dispatcher.dart';
import 'package:litheum_wallet/models/logger.dart';

final logger = Logger(LogLevel.trace, stdOutput: kDebugMode);

const _base = 'native';
final _dylibPath = Platform.isWindows ? '$_base.dll' : 'lib$_base.so';
final _dylib = Platform.isIOS
    ? DynamicLibrary.process()
    : Platform.isMacOS
        ? DynamicLibrary.executable()
        : DynamicLibrary.open(_dylibPath);
final NativeImpl _native = NativeImpl(_dylib);

DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

// ID of a "delete" label.
// final deletedLabelId = _native.getDeletedLabelId();

Future<String> _getAppSupportPath() async {
  const appSupportEnv = String.fromEnvironment('LITHEUM_APP_SUPPORT_PATH');
  if (appSupportEnv.isNotEmpty) {
    return appSupportEnv;
  }

  final libDir = await getApplicationSupportDirectory();
  return libDir.path;
}

Future<void> _startNative(AppEventDispatcher dispatcher) async {
  final appSupportDir = await _getAppSupportPath();
  logger.addFileOutput(appSupportDir);

  logger.info("Set up native logs");
  _native.setupLogs().handleError((e) {
    logger.warn("Failed to set up native logs: $e");
  }).listen((logRow) {
    logger.nativeEvent(logRow);
  });

  final deviceName = await _getDeviceName();

  /*final String filesDir;
  if (Platform.isAndroid) {
    // we need to check whether external storage is available
    // https://developer.android.com/training/data-storage/shared
    filesDir = (await getExternalStorageDirectory())!.path;
  } else {
    // consider using getApplicationDocumentsDirectory
    filesDir = await _getAppSupportPath();
  }*/

  logger.info("Set up native module");
  await for (final event in _native.setup(
    // appSupportDir: appSupportDir,
    // filesDir: filesDir,
    deviceName: deviceName,
  )) {
    dispatcher.dispatch(event);
  }
}

/// Specifies what is the current app phase. ==> (this one will be developed later, at the moment we just use PostAccount phase)
/// - PreAccount (no account is set up) - no keypair is stored
/// - PostAccount (has KP)
class DevicePhaseInfo {
  AppEventDispatcher dispatcher;
  // ValueNotifier<PreAccountState?> _preAccount;
  ValueNotifier<AppState?> _appState;
  final bool sdkFatalError;

  DevicePhaseInfo._(this.dispatcher,
      {
        // PreAccountState? preAccount,
      AppState? appState,
      this.sdkFatalError = false})
      : _appState = ValueNotifier(appState);

  // DevicePhaseInfo.preAccount(AppEventDispatcher dispatcher)
  //     : this._(dispatcher);
  DevicePhaseInfo.appState(AppEventDispatcher dispatcher)
      : this._(dispatcher,appState: AppState.build(dispatcher, _native));

  /// Device was connected to a specific KP.
  void onPostAccount() {
    _appState.value = AppState.build(dispatcher, _native);
  }

  // TODO: do clean up here
  Future<void> onClosed() async {
    _appState.value = null;
  }
  ValueListenable<AppState?> get appState => _appState;
}

/// Start native module and configure device phase info.
Future<DevicePhaseInfo> setupDevice(AppEventDispatcher dispatcher) async {
  final completer = Completer<DevicePhaseInfo>();

  void listener(OutputEvent event) {
    // keypair store & walet db is set up, then load into HomeScreen
    // **future-work**: this will be replaced by loading AccountScreen (renaming from HomeScreen)
    //    (separate step: preAccount -> postAccount)
    //    preAccount: no keypair store & wallet db was set, then brought to AccSetupScreen
    //    postAccount: has keypair store & wallet db was set, then brought to AccountScreen
    if (event is OutputEvent_PostAccount) {
      completer
          .complete(DevicePhaseInfo.appState(dispatcher/*, event.accView*/));
    }
  }

  dispatcher.addListener(listener);

  void run() async {
    try {
      await _startNative(dispatcher, );
    } catch (e, st) {
      logger.error('Cannot setup native module: $e $st');
      completer.complete(DevicePhaseInfo._(dispatcher,
          sdkFatalError: true));
    } finally {
      dispatcher.removeListener(listener);
    }
  }

  run();

  return completer.future;
}

Future<String> _getDeviceName() async {
  if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    return '${info.manufacturer} ${info.model}';
  } else if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    return '${info.name} ${info.systemVersion}';
  } else if (Platform.isLinux) {
    return (await deviceInfo.linuxInfo).name;
  } else if (Platform.isMacOS) {
    final info = await deviceInfo.macOsInfo;
    return '${info.computerName} ${info.model}';
  } else if (Platform.isWindows) {
    return (await deviceInfo.windowsInfo).computerName;
  }

  return 'Unknown device';
}
