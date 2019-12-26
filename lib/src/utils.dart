import 'dart:async';
import 'dart:convert';

import 'package:threads_client/threads_client.dart';
import 'package:threads_client/src/generated/api.pb.dart';

void handleListenData(ListenReply data, EventSink<ListenResult> sink) {
  ListenResult result = ListenResult.fromJson({
    "modelName": data.modelName,
    "entityID": data.entityID,
    "action": data.action.name,
    "entity": JsonCodec().decode(utf8.decode(data.entity))
  });
  sink.add(result);
}

returnReadTransform<T>() {
  final func = (T data, EventSink<ReadTransactionRequest> sink) {
    var request = ReadTransactionRequest();
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
  return func;
}
