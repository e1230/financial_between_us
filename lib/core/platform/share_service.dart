import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'share_service.g.dart';

/// Opens the Android share sheet.
abstract interface class ShareService {
  /// Shares [text] as plain text through the system chooser.
  Future<void> shareText(String text);
}

/// [ShareService] over the `fbu/share` channel, handled by `MainActivity`
/// with an `ACTION_SEND` intent.
// DECISIÓN: a small platform channel instead of `share_plus`, so the app
// does not need another package for a single plain-text intent.
class MethodChannelShareService implements ShareService {
  const MethodChannelShareService([this._channel = channel]);

  final MethodChannel _channel;

  static const MethodChannel channel = MethodChannel('fbu/share');
  static const String shareTextMethod = 'shareText';
  static const String textArgument = 'text';

  @override
  Future<void> shareText(String text) =>
      _channel.invokeMethod<void>(shareTextMethod, {textArgument: text});
}

@Riverpod(keepAlive: true)
ShareService shareService(Ref ref) => const MethodChannelShareService();
