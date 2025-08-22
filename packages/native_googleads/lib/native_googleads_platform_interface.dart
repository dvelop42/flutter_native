import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'native_googleads_method_channel.dart';

abstract class NativeGoogleadsPlatform extends PlatformInterface {
  /// Constructs a NativeGoogleadsPlatform.
  NativeGoogleadsPlatform() : super(token: _token);

  static final Object _token = Object();

  static NativeGoogleadsPlatform _instance = MethodChannelNativeGoogleads();

  /// The default instance of [NativeGoogleadsPlatform] to use.
  ///
  /// Defaults to [MethodChannelNativeGoogleads].
  static NativeGoogleadsPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [NativeGoogleadsPlatform] when
  /// they register themselves.
  static set instance(NativeGoogleadsPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
