import 'dart:async';
import 'dart:convert';
import 'package:protobuf/protobuf.dart';
import 'package:threads_client/threads_client.dart';
import 'package:uuid/uuid.dart';
import 'package:grpc/grpc.dart';
import 'package:threads_client_grpc/api.pbgrpc.dart';
import 'package:threads_client_grpc/api.pb.dart';
import 'config.dart';
import 'models.dart';
import 'utils.dart';

/// API Client to the remote Thread daemon
/// {@category API}
/// 
/// {@example example/helloworld.dart}
class Client {
  APIClient _stub;
  ClientChannel _channel;
  String _host;
  int _port;
  Uuid _uuid;

  /// Create a new Client with given config
  Client({Config config}) {
    _uuid = Uuid();
    if (config == null) {
      config = Config();
    }
    _host = config.host;
    _port = config.port;
    _channel = ClientChannel(_host,
        port: _port,
        options:
          ChannelOptions(credentials: config.credentials));
        _stub = APIClient(
          _channel,
          options: config.getCallOptions()
        );
  }

  /// Create a new DB with provided Credentials
  /// 
  /// {@example example/helloworld.dart}
  Future<void> newDB(String dbID) async {
    final request = NewDBRequest();
    request.dbID = base64.decode(dbID);
    await _stub.newDB(request);
    return;
  }

  /// Create a new collection in the DB
  Future<void> newCollection({String dbID, String name, String schema}) async {
    final request = NewCollectionRequest();
    request.dbID = base64.decode(dbID);
    final collection = Collection(name, schema);
    request.config = collection.getConfig();
    await _stub.newCollection(request);
    return;
  }

  /// Join a DB from a remote address
  Future<void> newDBFromAddr({String address, String key, List<Collection> collections}) async {
    final request = NewDBFromAddrRequest();
    request.addr = base64.decode(address);
    if (key != null) {
      request.key = base64.decode(key);
    }
    request.collections.addAll(
      collections.map((c) => c.getConfig())
    );
    await _stub.newDBFromAddr(request);
    return;
  }

  /// Get the DB's address & key information
  Future<Info> getDBInfo(String dbID) async {
    final request = GetDBInfoRequest();
    request.dbID = base64.decode(dbID);
    final output = await _stub.getDBInfo(request);
    final response = Info(
      output.addrs.map((addr) => base64.encode(addr)).toList(),
      base64.encode(output.key)
    );
    return response;
  }

  /// Create a new instance(s) in the collection
  /// 
  /// {@example example/create.dart}
  Future<List<String>> create(String dbID, String collectionName, List<Map<String, dynamic>> values) async {
    final request = CreateRequest();  
    request.dbID = base64.decode(dbID);
    request.collectionName = collectionName;
    for (var i=0; i<values.length; i++) {
      if (!values[i].containsKey('ID')) {
        values[i]['ID'] = _uuid.v4();
      }
      final valString = json.encode(values[i]).toString();
      request.instances.add(utf8.encode(valString));
    }
    final response = await _stub.create(request);
    return response.instanceIDs;
  }

  /// Save changes to an existing instance
  Future<void> save(String dbID, String collectionName, List<Map<String, dynamic>> values) async {
    final request = SaveRequest();  
    request.dbID = base64.decode(dbID);
    request.collectionName = collectionName;
    for (var i=0; i<values.length; i++) {
      final valString = json.encode(values[i]).toString();
      request.instances.add(utf8.encode(valString));
    }
    await _stub.save(request);
    return;
  }

  /// Delete an existing instance
  Future<void> delete(String dbID, String collectionName, List<String> instanceIDs) async {
    final request = DeleteRequest();  
    request.dbID = base64.decode(dbID);
    request.collectionName = collectionName;
    for (var i=0; i<instanceIDs.length; i++) {
      request.instanceIDs.add(instanceIDs[i]);
    }
    await _stub.delete(request);
    return;
  }

  /// Check if an instance exists in the given collection
  Future<bool> has(String dbID, String collectionName, List<String> instanceIDs) async {
    final request = HasRequest();  
    request.dbID = base64.decode(dbID);
    request.collectionName = collectionName;
    for (var i=0; i<instanceIDs.length; i++) {
      request.instanceIDs.add(instanceIDs[i]);
    }
    final response = await _stub.has(request);
    return response.getField(1);
  }

  /// Find and return an instance by ID
  Future<Map<String, dynamic>> findById(String dbID, String collectionName, String instanceID) async {
    final request = FindByIDRequest();  
    request.dbID = base64.decode(dbID);
    request.collectionName = collectionName;
    request.instanceID = instanceID;
    final response = await _stub.findByID(request);
    final jsn = json.decode(utf8.decode(response.getField(1)));
    return jsn;
  }

  /// Find any matching instance IDs by query
  Future<List<Map<String, dynamic>>> find(String dbID, String collectionName, Query query) async {
    final request = FindRequest();  
    request.dbID = base64.decode(dbID);
    request.collectionName = collectionName;
    request.queryJSON = utf8.encode(json.encode(query.toJson()));
    final response = await _stub.find(request);
    return List<Map<String, dynamic>>.from(
      response.instances.map((et) => json.decode(utf8.decode(et)))
    );
  }

  /// Create an update stream
  Stream<ListenResult> createListener(String dbID) {
    // @todo: createListener seems to only handle a db ID here, whereas in js, more. 
    final request = ListenRequest();  
    request.dbID = base64.decode(dbID);
    final typeTransform = StreamTransformer.fromHandlers(handleData: handleListenData);
    final stream = _stub.listen(request).transform(typeTransform);
    return stream;
  }
  
  /// Create a read transaction steam
  ResponseStream<ReadTransactionReply> readTransaction(StreamController<GeneratedMessage> writer) {
    // Create transation input stream
    final controller = StreamController<ReadTransactionRequest>();

    // Transform user inputs to TransactionRequests
    final transform = returnReadTransform();
    writer.stream.transform(transform).pipe(controller);

    // Register stream and get listener
    final listener = _stub.readTransaction(controller.stream);

    return listener;
  }

  /// Create a write transaction stream
  ResponseStream<WriteTransactionReply> writeTransaction(StreamController<GeneratedMessage> writer) {
    // Create transation input stream
    final controller = StreamController<WriteTransactionRequest>();

    // Transform user inputs to TransactionRequests
    final transform = returnWriteTransform();
    writer.stream.transform(transform).pipe(controller);

    // Register stream and get listener
    final listener = _stub.writeTransaction(controller.stream);

    return listener;
  }

  /// Shut down the connection
  Future<void> shutdown() async {
    await _channel.terminate();
  }
}
