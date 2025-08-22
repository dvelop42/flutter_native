import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'native_googleads_platform_interface.dart';

/// An implementation of [NativeGoogleadsPlatform] that uses method channels.
class MethodChannelNativeGoogleads extends NativeGoogleadsPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('native_googleads');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
