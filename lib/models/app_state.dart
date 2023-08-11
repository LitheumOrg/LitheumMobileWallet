import 'package:fast_base58/fast_base58.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:litheum_wallet/bridge_generated.dart';
import 'package:litheum_wallet/models/dispatcher.dart';

import 'package:litheum_wallet/bridge_definitions.dart';

class AppState {
  final AppEventDispatcher dispatcher;
  final Native native;
  final KeyPairStore keypairStore;

  AppState._(this.keypairStore, this.dispatcher, this.native);

  static AppState build(AppEventDispatcher dispatcher, Native native) {
    final keypairStore = KeyPairStore(dispatcher, native);
    return AppState._(keypairStore, dispatcher, native);
  }

  syncFromNet() {
    // native.forceSync()
  }
  // String getCurrentDeviceId() {
  //   return native.getCurrentDeviceId();
  // }
}

class KeyPairStore extends ChangeNotifier {
  final AppEventDispatcher _dispatcher;
  final Native _native;
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  KeyPairStore(this._dispatcher, this._native) {
    _dispatcher.addListener<OutputEvent_KeypairStoreLoaded>((event) {
      _load();
    });

    _load();
  }

  void _load() async {
    var keypair = await storage.read(key: 'keypair_store');
    if (keypair == null) {
      Uint8List slice = await _native.generateKeypair();
      /*final test = Base58Encode(slice);
      print('encrypted_key from Rust: $slice');
      print('Base58Encode keypair_store: $test');
      final test1 = Base58Decode(test);
      print('Base58Decode keypair_store: $test1');*/
      await storage.write(
          // key: 'keypair', value: keypair.buffer.asByteData() as String);
          key: 'keypair_store',
          value: Base58Encode(slice));
      // address = api.getAddress(slice: slice);
    } else {
      // print('keypair_store 1: $keypair');
      // final test = Base58Decode(keypair);
      // print('Base58Decode keypair_store: $test');
      final slice = Uint8List.fromList(Base58Decode(keypair));
      debugPrint('origianl slice: $slice');
      // address =
      //     api.getAddress(slice: Uint8List.fromList(Base58Decode(keypair)));
    }

    notifyListeners();
  }
}