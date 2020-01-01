import 'dart:async';
import 'dart:convert';

import 'package:protobuf/protobuf.dart';
import 'package:threads_client/threads_client.dart';
import 'package:threads_client_grpc/api.pb.dart';

void handleListenData(ListenReply data, EventSink<ListenResult> sink) {
  final result = ListenResult.fromJson({
    'modelName': data.modelName,
    'entityID': data.entityID,
    'action': data.action.name,
    'entity': JsonCodec().decode(utf8.decode(data.entity))
  });
  sink.add(result);
}

dynamic returnReadTransform() {
  return (GeneratedMessage data, EventSink<ReadTransactionRequest> sink) {
    final request = ReadTransactionRequest();
    switch (data.runtimeType) {
      case ModelFindByIDRequest:
        request.modelFindByIDRequest = data as ModelFindByIDRequest;
        sink.add(request);
        break;
      case ModelFindRequest:
        request.modelFindRequest = data as ModelFindRequest;
        sink.add(request);
        break;
      case ModelHasRequest:
        request.modelHasRequest = data as ModelHasRequest;
        sink.add(request);
        break;
    }
  };
}

dynamic returnWriteTransform() {
  return (GeneratedMessage data, EventSink<WriteTransactionRequest> sink) {
    final request = WriteTransactionRequest();
    switch (data.runtimeType) {
      case ModelFindByIDRequest:
        request.modelFindByIDRequest = data as ModelFindByIDRequest;
        sink.add(request);
        break;
      case ModelFindRequest:
        request.modelFindRequest = data as ModelFindRequest;
        sink.add(request);
        break;
      case ModelHasRequest:
        request.modelHasRequest = data as ModelHasRequest;
        sink.add(request);
        break;
      case ModelCreateRequest:
        request.modelCreateRequest = data as ModelCreateRequest;
        sink.add(request);
        break;
      case ModelDeleteRequest:
        request.modelDeleteRequest = data as ModelDeleteRequest;
        sink.add(request);
        break;
      case ModelSaveRequest:
        request.modelSaveRequest = data as ModelSaveRequest;
        sink.add(request);
        break;
    }
  };
}
