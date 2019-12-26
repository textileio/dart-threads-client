import 'dart:async';
import 'dart:convert';
import 'package:protobuf/protobuf.dart';
import 'package:uuid/uuid.dart';
import 'package:grpc/grpc.dart';
import 'package:threads_client/src/generated/api.pb.dart';
import 'generated/api.pbgrpc.dart';
import 'models.dart';
import 'utils.dart';
import 'defaults.dart';

class ThreadsClient {
  Uuid uuid;

  ClientChannel channel;
  APIClient stub;
  String host;
  int port;

  ThreadsClient({String host = '127.0.0.1', int port = 6006, Duration timeout = default_timeout, ChannelCredentials credentials = default_credentials}) {
    uuid = Uuid();
    host = host;
    port = port;
    channel = ClientChannel(host,
        port: port,
        options:
            const ChannelOptions(credentials: default_credentials));
    stub = APIClient(channel,
        options: CallOptions(timeout: timeout));
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

  Future<StoreLinks> getStoreLink(String storeID) async {
    var request = GetStoreLinkRequest();
    request.storeID = storeID;
    var output = await stub.getStoreLink(request);
    var response = StoreLinks(
      output.addresses,
      base64.encode(output.followKey),
      base64.encode(output.readKey)
    );
    return response;
  }

  Future<List<Map<String, dynamic>>> modelCreate(String storeID, String modelName, List<Map<String, dynamic>> values) async {
    var request = ModelCreateRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    for (var i=0; i<values.length; i++) {
      values[i]["ID"] = uuid.v4();
      var valString = json.encode(values[i]).toString();
      request.values.add(valString);
    }
    var response = await stub.modelCreate(request);
    List<dynamic> jsn = response.getField(1).map((f) => json.decode(f.toString())).toList();
    return jsn.map((j) => j as Map<String, dynamic>).toList();
  }

  Future<void> modelSave(String storeID, String modelName, List<Map<String, dynamic>> values) async {
    var request = ModelSaveRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    for (var i=0; i<values.length; i++) {
      var valString = json.encode(values[i]).toString();
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
    return json.decode(response.getField(1));
  }

  Future<List<Map<String, dynamic>>> modelFind(String storeID, String modelName, JSONQuery query) async {
    var request = ModelFindRequest();  
    request.storeID = storeID;
    request.modelName = modelName;
    request.queryJSON = utf8.encode(json.encode(query.toJson()));
    var response = await stub.modelFind(request);
    var entities = response.getField(1);
    List<Map<String, dynamic>> fin = [];
    for (var i=0; i<entities.length; i++) {
      fin.add(
        json.decode(utf8.decode(entities[i])) as Map<String, dynamic>
      );
    }
    return fin;
  }

  Stream<ListenResult> createListener(String storeID) {
    // @todo: createListener seems to only handle a storeId here, whereas in js, more. 
    var request = ListenRequest();  
    request.storeID = storeID;
    final typeTransform = new StreamTransformer.fromHandlers(handleData: handleListenData);
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
    await channel.shutdown();
  }
}
