import 'dart:async';
import 'dart:convert';

import 'package:protobuf/protobuf.dart';
import 'package:threads_client/threads_client.dart';
import 'package:threads_client_grpc/api.pb.dart';

void handleListenData(ListenReply data, EventSink<ListenResult> sink) {
  final result = ListenResult.fromJson({
    'collectionName': data.collectionName,
    'instanceID': data.instanceID,
    'action': data.action.name,
    'instance': JsonCodec().decode(utf8.decode(data.instance))
  });
  sink.add(result);
}

dynamic returnReadTransform() {
  return (GeneratedMessage data, EventSink<ReadTransactionRequest> sink) {
    final request = ReadTransactionRequest();
    switch (data.runtimeType) {
      case FindByIDRequest:
        request.findByIDRequest = data as FindByIDRequest;
        sink.add(request);
        break;
      case FindRequest:
        request.findRequest = data as FindRequest;
        sink.add(request);
        break;
      case HasRequest:
        request.hasRequest = data as HasRequest;
        sink.add(request);
        break;
    }
  };
}

dynamic returnWriteTransform() {
  return (GeneratedMessage data, EventSink<WriteTransactionRequest> sink) {
    final request = WriteTransactionRequest();
    switch (data.runtimeType) {
      case FindByIDRequest:
        request.findByIDRequest = data as FindByIDRequest;
        sink.add(request);
        break;
      case FindRequest:
        request.findRequest = data as FindRequest;
        sink.add(request);
        break;
      case HasRequest:
        request.hasRequest = data as HasRequest;
        sink.add(request);
        break;
      case CreateRequest:
        request.createRequest = data as CreateRequest;
        sink.add(request);
        break;
      case DeleteRequest:
        request.deleteRequest = data as DeleteRequest;
        sink.add(request);
        break;
      case SaveRequest:
        request.saveRequest = data as SaveRequest;
        sink.add(request);
        break;
    }
  };
}
