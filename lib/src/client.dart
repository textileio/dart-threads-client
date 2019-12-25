import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'package:grpc/grpc.dart';
import 'package:threads_client/src/generated/api.pb.dart';
import 'generated/api.pbgrpc.dart';
import 'generated/api.pb.dart';

class Client {
  ClientChannel channel;
  APIClient stub;
  Uuid uuid = Uuid();

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
    if (storeID != null) {
      request.storeID = storeID;
    }
    if (address != null) {
      request.address = address;
    }
    if (followKey != null) {
      request.followKey = base64.decode(followKey);
    }
    if (readKey != null) {
      request.readKey = base64.decode(readKey);
    }
    await stub.startFromAddress(request);
    return;
  }

  Future<Map<String, dynamic>> getStoreLink(String storeID) async {
    var request = GetStoreLinkRequest();
    request.storeID = storeID;
    var response = await stub.getStoreLink(request);
    // @todo: improve response type
    return response.writeToJsonMap();
  }

  Future<List<Map<String, dynamic>>> modelCreate(String storeID, String modelName, List<Map<String, dynamic>> values) async {
    var request = ModelCreateRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    for (var i=0; i<values.length; i++) {
      values[i]["ID"] = uuid.v4();
      var valString = JsonCodec().encode(values[i]).toString();
      request.values.add(valString);
    }
    var response = await stub.modelCreate(request);
    List<dynamic> jsn = response.getField(1).map((f) => JsonCodec().decode(f.toString())).toList();
    return jsn.map((j) => j as Map<String, dynamic>).toList();
  }

  Future<void> modelSave(String storeID, String modelName, List<Map<String, dynamic>> values) async {
    var request = ModelSaveRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    for (var i=0; i<values.length; i++) {
      var valString = JsonCodec().encode(values[i]).toString();
      request.values.add(valString);
    }
    await stub.modelSave(request);
    return;
  }

  Future<void> modelDelete(String storeID, String modelName, List<String> entityIDs) async {
    var request = ModelDeleteRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    for (var i=0; i<entityIDs.length; i++) {
      request.entityIDs.add(entityIDs[i]);
    }
    await stub.modelDelete(request);
    return;
  }

  Future<bool> modelHas(String storeID, String modelName, List<String> entityIDs) async {
    var request = ModelHasRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    for (var i=0; i<entityIDs.length; i++) {
      request.entityIDs.add(entityIDs[i]);
    }
    final response = await stub.modelHas(request);
    return response.getField(1);
  }


  Future<Map<String, dynamic>> modelFindById(String storeID, String modelName, String entityID) async {
    var request = ModelFindByIDRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    request.entityID = entityID;
    var response = await stub.modelFindByID(request);
    return JsonCodec().decode(response.getField(1));
  }

  // Future<Map<String, dynamic>> modelFind(String storeID, String modelName, Map<String, dynamic> queryJSON) async {
  //   var request = ModelFindRequest();  
  //   request.storeID = storeID;
  //   request.modelName = modelName;
  //   request.queryJSON = base64.decode(JsonCodec().encode(queryJSON).toString());
  //   var response = await stub.modelFind(request);
  //   print(response);
  //   return JsonCodec().decode(response.getField(1));
  // }

  // @todo: Add each of the required methods
  // @todo: modelFind
  // @todo: readTransaction
  // @todo: writeTransaction
  // @todo: listen

  Future<void> shutdown() async {
    await channel.shutdown();
  }
}