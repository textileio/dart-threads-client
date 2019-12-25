import 'dart:async';
import 'dart:convert';
import 'package:grpc/grpc.dart';
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

  Future<void> start(String storeID) async {
    var request = StartRequest();
    request.storeID = storeID;
    await stub.start(request);
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

  Future<Map<String, dynamic>> getStoreLink(String storeID) async {
    var request = GetStoreLinkRequest();
    request.storeID = storeID;
    var response = await stub.getStoreLink(request);
    // @todo: improve response type
    return response.writeToJsonMap();
  }

  // @todo: Add each of the required methods
  // @todo: modelCreate
  // @todo: modelSave
  // @todo: modelDelete
  // @todo: modelHas
  // @todo: modelFind
  // @todo: modelFindByID
  // @todo: readTransaction
  // @todo: writeTransaction
  // @todo: listen

  Future<void> shutdown() async {
    await channel.shutdown();
  }
}