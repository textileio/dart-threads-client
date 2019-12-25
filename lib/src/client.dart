import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:grpc/grpc.dart';
import 'package:threads_client/src/generated/api.pb.dart';
import 'package:threads_client/src/generated/api.pb.dart';
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

  Future<String> newStore() async {
    var store = await stub.newStore(NewStoreRequest());
    return store.getField(1);
  }

  Future<void> registerSchema({String storeID, String name, String schema}) async {
    var request = RegisterSchemaRequest();  
    request.storeID = storeID;
    request.name = name;
    request.schema = schema;
    await stub.registerSchema(request);
    return;
  }

  Future<void> start() async {
    await stub.start(StartRequest());
    return;
  }

  Future<void> startFromAddress({String storeID, String address, String followKey, String readKey}) async {
    var request = StartFromAddressRequest();  
    request.storeID = storeID;
    request.address = address;
    if (followKey != null) {
      var encoded = Utf8Codec().encode(followKey);
      request.followKey = encoded;
    }
    if (readKey != null) {
      var encoded = Utf8Codec().encode(readKey);
      request.readKey = encoded;
    }
    return;
  }

  // @todo: Add each of the required methods
  // @todo: getStoreLink
  // @todo: modelCreate
  // @todo: modelSave
  // @todo: see api.pbgrpc.dart for full list.

  Future<void> shutdown() async {
    await channel.shutdown();
  }
}