import 'dart:io';

import 'package:flutter/material.dart';
import 'package:litheum_wallet/features/account/home_screen.dart';
// import 'package:litheum_wallet/features/account_setup/account_screen.dart';
// import 'package:litheum_wallet/features/import/export_screen.dart';
// import 'package:litheum_wallet/features/import/import_screen.dart';
// import 'package:litheum_wallet/features/logs/log_screen.dart';
// import 'package:litheum_wallet/features/transactions/transactions_screen.dart';

/// A statically typed list of routes
class LitheumRoutes {
  static final GlobalKey<NavigatorState> rootNav = GlobalKey();
  static final GlobalKey<NavigatorState> dialogNav = GlobalKey();

  // Unauthenticated routes
  static const index = '/';

  // Authenticated routes
  static const transactions = '/transactions';
  static const logs = '/logs';
  static const logout = '/logout';

  /// Navigate to the previous page
  static void goBack() {
    if (dialogNav.currentState?.canPop() ?? false) {
      // If we are inside a dialog then use dialog's navigator
      dialogNav.currentState!.pop();
    } else {
      // If we reached the first dialog page or outside the dialog then use root navigator
      rootNav.currentState!.pop();
    }
  }
}

Widget Function(BuildContext context)? _pageBuilder(RouteSettings settings) {
  switch (settings.name) {
    // Unauthenticated routes
    // case LitheumRoutes.accountSetup:
    //   return (context) => const AccountSetupPage();

    // Authenticated routes
    case LitheumRoutes.index:
      return (context) => const HomePage();

    ////////////////// future-features /////////////////////
    // Account
    // case LitheumRoutes.acc:
    //   return (context) => const AccountPage();

    // Transactions
    // case LitheumRoutes.transactions:
    //   return (context) => const TransactionsPage();

    // Misc
    // case LitheumRoutes.logs:
    //   return (context) => const LogViewPage();
    // case LitheumRoutes.importKey
    //   return (context) => const ImportPage();
    // case LitheumRoutes.exportKey:
    //   return (context) => const ExportPage();
    // case LitheumRoutes.logout:
    //   return (context) => const LogOutPage();
    default:
      return null;
  }
}

Route<T>? rootOnGenerateRoute<T>(RouteSettings settings) {
  final pageBuilder = _pageBuilder(settings);
  if (pageBuilder == null) {
    return null;
  }

  return MaterialPageRoute(builder: pageBuilder, settings: settings);
}

Route<T>? _dialogOnGenerateRoute<T>(RouteSettings settings) {
  final pageBuilder = _pageBuilder(settings);
  if (pageBuilder == null) {
    return null;
  }

  // We don't use MaterialPageRoute inside dialogs because of animation glitches.
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
        pageBuilder(context),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

/// Open a dialog with a navigator. Pages will be able to navigate inside an open dialog.
Future<T?> showDialogNav<T>({
  required BuildContext context,
  required String initialRoute,
  required Widget Function(BuildContext context, Widget child) builder,
}) {
  final screenSize = MediaQuery.of(context).size;
  if (screenSize.width < 700) {
    // For mobiles we just navigate to the page
    // There is a bit of trickery here needed to support context injections.
    final settings = RouteSettings(name: initialRoute);
    final pageBuilder = _pageBuilder(settings)!;
    final route = MaterialPageRoute<T>(
      builder: (context) => builder(context, pageBuilder(context)),
      settings: settings,
    );

    return Navigator.push(context, route);
  }

  final dialogHeight = MediaQuery.of(context).size.height;
  final child = Dialog(
    child: SizedBox(
      width: 500,
      height: dialogHeight,
      child: Navigator(
        key: LitheumRoutes.dialogNav,
        initialRoute: initialRoute,
        onGenerateInitialRoutes: (state, initialRoute) {
          final route =
              _dialogOnGenerateRoute(RouteSettings(name: initialRoute))!;
          return [route];
        },
        onGenerateRoute: _dialogOnGenerateRoute,
      ),
    ),
  );

  return showDialog<T>(
    context: context,
    builder: (context) => builder(context, child),
  );
}
