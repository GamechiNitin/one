import 'package:flutter/widgets.dart' show GlobalKey;
import 'package:flutter/material.dart' show ScaffoldMessengerState;
import 'dart:async';

/// A localizable message that blocs can emit without touching BuildContext.
class UiMessage {
  final String key;
  final List<Object> args;
  const UiMessage(this.key, [this.args = const []]);
}

/// App-wide event bus for snackbar messages. Blocs call [show]; the app shell listens.
class UiNotifier {
  final _controller = StreamController<UiMessage>.broadcast();
  Stream<UiMessage> get stream => _controller.stream;
  void show(String key, [List<Object> args = const []]) => _controller.add(UiMessage(key, args));
  void dispose() => _controller.close();
}

/// Key for the root ScaffoldMessenger so snackbars can be shown from anywhere.
final messengerKey = GlobalKey<ScaffoldMessengerState>();
