import 'dart:async';
import 'package:grpc/grpc.dart';
import 'defaults.dart';

class Config {
  String host;
  int port;
  Duration timeout;
  ChannelCredentials credentials;
  Map<String, String> callOptionsMetaData;
  List<FutureOr<void> Function(Map<String, String>, String)> callOptionProviders;
  CallOptions callOptions;
  Config ({this.host = default_host, this.port = default_port, this.timeout = default_timeout, this.credentials = default_credentials, this.callOptionProviders, this.callOptionsMetaData, this.callOptions});
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
