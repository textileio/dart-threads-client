import 'dart:async';
import 'package:grpc/grpc.dart';
import 'generated/api.pbgrpc.dart';
import 'generated/api.pb.dart';

class Client {
  ClientChannel channel;
  APIClient stub;

  Future<void> main(List<String> args) async {
    // @todo use args for non-default ip/port/timeout
    channel = ClientChannel('127.0.0.1',
        port: 6006,
        options:
            const ChannelOptions(credentials: ChannelCredentials.insecure()));
    stub = APIClient(channel,
        options: CallOptions(timeout: Duration(seconds: 30)));
  }

  Future<void> newStore() async {
    var store = await stub.newStore(NewStoreRequest());
    print('New store: $store');
  }

  // @todo: Add each of the required methods
  // @todo: registerSchema
  // @todo: start
  // @todo: startFromAddress
  // @todo: getStoreLink
  // @todo: modelCreate
  // @todo: modelSave
  // @todo: see api.pbgrpc.dart for full list.

  Future<void> shutdown() async {
    await channel.shutdown();
  }
}