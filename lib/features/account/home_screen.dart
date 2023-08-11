import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:litheum_wallet/models/app_state.dart';
import 'package:litheum_wallet/routes.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();

    return Scaffold(
      body: _HomeContent(state),
    );
  }
}

class _HomeContent extends StatefulWidget {
  final AppState state;
  const _HomeContent(this.state, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeContentState();
}

enum _SetupPhase {
  initial,
  ready,
  done,
}

class _HomeContentState extends State<_HomeContent> {
  var _phase = _SetupPhase.initial;

  @override
  Widget build(BuildContext context) {
    if (_phase == _SetupPhase.ready) {
      return _WalletHomeContent(
        onSubmit: (name) {
          setState(() {
            _phase = _SetupPhase.done;
          });
          //TODO: call to widget.state.sendTransaction() here
        },
      );
    }

    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 80),
          Text(
            'Welcome to Litheum Wallet!',
            style: textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 50),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _phase = _SetupPhase.ready;
              });
            },
            icon: const Icon(Icons.create),
            label: const Text(''),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _phase = _SetupPhase.ready;
              });
            },
            icon: const Icon(Icons.link),
            label: const Text(''),
          ),
        ],
      ),
    );
  }
}

class _WalletHomeContent extends StatefulWidget {
  final void Function(String) onSubmit;

  const _WalletHomeContent({super.key, required this.onSubmit});

  @override
  State<StatefulWidget> createState() => _WalletHomeContentState();
}

class _WalletHomeContentState extends State<_WalletHomeContent> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
  }
}