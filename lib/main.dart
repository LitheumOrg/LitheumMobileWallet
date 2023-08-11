import 'dart:typed_data';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:litheum_wallet/routes.dart';
import 'package:provider/provider.dart';

import 'package:litheum_wallet/models/dispatcher.dart';
import 'package:litheum_wallet/models/phase_info.dart';
import 'package:litheum_wallet/models/app_state.dart';
import 'ffi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final info = await setupDevice(AppEventDispatcher());
  runApp(LitheumApp(info: info));
}

class LitheumApp extends StatefulWidget {
  final DevicePhaseInfo info;
  const LitheumApp({super.key, required this.info});

  @override
  State<StatefulWidget> createState() => _LitheumAppState();
}

class _LitheumAppState extends State<LitheumApp> {
  @override
  void initState() {
    super.initState();
    widget.info.dispatcher.addListener(_eventListener);
  }

  @override
  void dispose() {
    super.dispose();
    widget.info.dispatcher.removeListener(_eventListener);
  }

  void _eventListener(OutputEvent event) async {
    if (event is OutputEvent_PostAccount) {
      if (widget.info.appState.value == null) {
        widget.info.onPostAccount();

        // Replace all routes with a home page
        LitheumRoutes.rootNav.currentState!
            .pushNamedAndRemoveUntil(LitheumRoutes.index, (route) => false);
      }
    } else if (event is OutputEvent_Close) {
      await widget.info.onClosed();

      // Replace all routes with a index page
      LitheumRoutes.rootNav.currentState!
          .pushNamedAndRemoveUntil(LitheumRoutes.index, (route) => false);
    }
  }

  Widget _injectProviders({required Widget child}) {
    return MultiProvider(providers: [
      // ValueListenableProvider.value(value: widget.info.preAccount),
      ValueListenableProvider.value(value: widget.info.appState),
      // ChangeNotifierProvider.value(value: widget.info.account),
    ], child: child);
  }

  @override
  Widget build(BuildContext context) {
    String initialRoute = LitheumRoutes.index;
    if (widget.info.appState.value != null) {
      initialRoute = LitheumRoutes.index;
    }

    return _injectProviders(
      child: MaterialApp(
        title: 'Litheum Wallet',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xff7a7d3d),
            // secondary: const Color(0xFFFFC107),
          ),
          useMaterial3: true,
        ),
        initialRoute: initialRoute,
        navigatorKey: LitheumRoutes.rootNav,
        onGenerateInitialRoutes: (initialRoute) {
          final route = rootOnGenerateRoute(RouteSettings(name: initialRoute))!;
          return [route];
        },
        onGenerateRoute: rootOnGenerateRoute,
      ),
    );
  }
}

