import 'dart:async';
import 'package:grpc/grpc.dart';
import 'defaults.dart';

/// Configuration for connecting to the remote Thread API
/// 
/// {@category Data Types}
class Config {
  /// host is the local or remote URL of the Thread API (default: 127.0.0.1).
  String host;
  /// port is the server port (default: 6006).
  int port;
  /// timeout is the Duration before any network request times out (default: 30 seconds).
  Duration timeout;
  /// advanced gRPC use only
  ChannelCredentials credentials;
  /// advanced gRPC use only
  Map<String, String> callOptionsMetaData;
    /// advanced gRPC use only
  List<FutureOr<void> Function(Map<String, String>, String)> callOptionProviders;
  CallOptions callOptions;
  Config ({this.host = default_host, this.port = default_port, this.timeout = default_timeout, this.credentials = default_credentials, this.callOptionProviders, this.callOptionsMetaData, this.callOptions});
  /// advanced gRPC use only
  CallOptions getCallOptions() {
    if (callOptions != null) {
      return callOptions;
    }
    return CallOptions(
      metadata: callOptionsMetaData,
      timeout: timeout,
      providers: callOptionProviders
    );
  }
}
