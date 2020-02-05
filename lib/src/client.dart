import 'dart:async';
import 'dart:convert';
import 'package:protobuf/protobuf.dart';
import 'package:uuid/uuid.dart';
import 'package:grpc/grpc.dart';
import 'package:threads_client_grpc/api.pbgrpc.dart';
import 'package:threads_client_grpc/api.pb.dart';
import 'config.dart';
import 'models.dart';
import 'utils.dart';

class Client {
  Uuid uuid;

  ClientChannel channel;
  APIClient stub;
  String host;
  int port;

  Client({Config config}) {
    uuid = Uuid();
    if (config == null) {
      config = Config();
    }
    host = config.host;
    port = config.port;
    channel = ClientChannel(host,
        port: port,
        options:
          ChannelOptions(credentials: config.credentials));
        stub = APIClient(
          channel,
          options: config.getCallOptions()
        );
  }

  Future<String> newStore() async {
    final store = await stub.newStore(NewStoreRequest());
    return store.getField(1);
  }

  Future<void> registerSchema({String storeID, String name, String schema}) async {
    final request = RegisterSchemaRequest();  
    request.storeID = storeID;
    request.name = name;
    request.schema = schema;
    await stub.registerSchema(request);
    return;
  }

  Future<void> start(String storeID) async {
    final request = StartRequest();
    request.storeID = storeID;
    await stub.start(request);
    return;
  }

  Future<void> startFromAddress({String storeID, String address, String followKey, String readKey}) async {
    final request = StartFromAddressRequest();  
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

  Future<StoreLinks> getStoreLink(String storeID) async {
    final request = GetStoreLinkRequest();
    request.storeID = storeID;
    final output = await stub.getStoreLink(request);
    final response = StoreLinks(
      output.addresses,
      base64.encode(output.followKey),
      base64.encode(output.readKey)
    );
    return response;
  }

  Future<List<Map<String,dynamic>>> modelCreate(String storeID, String modelName, List<Map<String, dynamic>> values) async {
    final request = ModelCreateRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    for (var i=0; i<values.length; i++) {
      values[i]['ID'] = uuid.v4();
      final valString = json.encode(values[i]).toString();
      request.values.add(valString);
    }
    final response = await stub.modelCreate(request);
    final entities = response.entities;

    return List<Map<String,dynamic>>.from(entities.map((e) => json.decode(e)));
  }

  Future<void> modelSave(String storeID, String modelName, List<Map<String, dynamic>> values) async {
    final request = ModelSaveRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    for (var i=0; i<values.length; i++) {
      final valString = json.encode(values[i]).toString();
      request.values.add(valString);
    }
    await stub.modelSave(request);
    return;
  }

  Future<void> modelDelete(String storeID, String modelName, List<String> entityIDs) async {
    final request = ModelDeleteRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    for (var i=0; i<entityIDs.length; i++) {
      request.entityIDs.add(entityIDs[i]);
    }
    await stub.modelDelete(request);
    return;
  }

  Future<bool> modelHas(String storeID, String modelName, List<String> entityIDs) async {
    final request = ModelHasRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    for (var i=0; i<entityIDs.length; i++) {
      request.entityIDs.add(entityIDs[i]);
    }
    final response = await stub.modelHas(request);
    return response.getField(1);
  }

  Future<Map<String, dynamic>> modelFindById(String storeID, String modelName, String entityID) async {
    final request = ModelFindByIDRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    request.entityID = entityID;
    final response = await stub.modelFindByID(request);
    return json.decode(response.getField(1));
  }

  Future<List<Map<String, dynamic>>> modelFind(String storeID, String modelName, JSONQuery query) async {
    final request = ModelFindRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    request.queryJSON = utf8.encode(json.encode(query.toJson()));
    final response = await stub.modelFind(request);
    return List<Map<String, dynamic>>.from(
      response.entities.map((et) => json.decode(utf8.decode(et)))
    );
  }

  Stream<ListenResult> createListener(String storeID) {
    // @todo: createListener seems to only handle a storeId here, whereas in js, more. 
    final request = ListenRequest();  
    request.storeID = storeID;
    final typeTransform = StreamTransformer.fromHandlers(handleData: handleListenData);
    final stream = stub.listen(request).transform(typeTransform);
    return stream;
  }
  
  ResponseStream<ReadTransactionReply> readTransaction(StreamController<GeneratedMessage> writer) {
    // Create transation input stream
    final controller = StreamController<ReadTransactionRequest>();

    // Transform user inputs to TransactionRequests
    final transform = returnReadTransform();
    writer.stream.transform(transform).pipe(controller);

    // Register stream and get listener
    final listener = stub.readTransaction(controller.stream);

    return listener;
  }

  ResponseStream<WriteTransactionReply> writeTransaction(StreamController<GeneratedMessage> writer) {
    // Create transation input stream
    final controller = StreamController<WriteTransactionRequest>();

    // Transform user inputs to TransactionRequests
    final transform = returnWriteTransform();
    writer.stream.transform(transform).pipe(controller);

    // Register stream and get listener
    final listener = stub.writeTransaction(controller.stream);

    return listener;
  }

  Future<void> shutdown() async {
    await channel.terminate();
  }
}
