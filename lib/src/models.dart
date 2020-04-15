
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'package:threads_client_grpc/api.pbgrpc.dart';
import 'package:threads_client_grpc/api.pb.dart';

/// A collection object
/// {@category Data Types}
class Collection {
  /// The name of the collection
  final String name;
  /// The JSON string of the schema
  final String schema;
  Collection._(this.name, this.schema);
  factory Collection(String name, String schema) {
    return Collection._(name, schema);
  }
  /// The JSON encoded Collection object
  Collection.fromJson(Map<String, dynamic> values)
    : name = values['name'],
      schema = values['schema'];

  /// Create Collection object from JSON
  Map<String, dynamic> toJson() =>
    Map<String, dynamic>.from({
      'name': name,
      'schema': schema
    });
  // Internal method
  CollectionConfig getConfig() {
    final config = CollectionConfig();
    config.name = name;
    config.schema = utf8.encode(schema);
    return config;
  }
}

/// DB Info containing available addresses and keys
/// {@category Data Types}
class Info {
  final List<String> addresses;
  final String key;
  Info._(this.addresses, this.key);
  factory Info(List<String> addresses, String key) {
    return Info._(addresses, key);
  }
  Info.fromJson(Map<String, dynamic> values)
    : addresses = List<String>.from(values['addresses']),
      key = values['key'];

  Map<String, dynamic> toJson() =>
    Map<String, dynamic>.from({
      'addresses': addresses,
      'key': key
    });

  Uint8List decodeKey() {
    return base64.decode(key);
  }
}

/// A new result from a Thread update listener
/// {@category Data Types}
class ListenResult {
  /// The name of the collection updated
  String collectionName;
  /// The name of the instanceID updated
  String instanceID;
  /// The update action name
  String action;
  /// The new value of the instance if any
  Map<String, dynamic> instance;
  /// Internal method
  ListenResult(this.collectionName, this.instanceID, this.action, this.instance);
  /// Internal method
  ListenResult.fromJson(Map<String, dynamic> values)
    : collectionName = values['collectionName'],
      instanceID = values['instanceID'],
      action = values['action'],
      instance = Map<String, dynamic>.from(values['instance']);
  /// Convert the result object to JSON
  Map<String, dynamic> toJson() =>
    Map<String, dynamic>.from({
      'collectionName': collectionName,
      'instanceID': instanceID,
      'action': action,
      'instance': instance
    });
}

/// Define a Thread query using JSON (fromJson)
/// {@category Data Types}
class Query {
  List<_QueryCriterion> ands;
  List<Query> ors;
  _QuerySort sort;
  Query({this.ands, this.ors, this.sort});

  /// Initialize a Query object from a JSON object
  Query.fromJson(Map<String, dynamic> query)
    : ands = query.containsKey('ands') ? _createJSONCriterionList(query['ands']): null,
      ors = query.containsKey('ors') ? _createJSONQueryList(query['ors']): null,
      sort = query.containsKey('sort') ? _QuerySort.fromJson(query['sort']): null;

  /// Get JSON back out of your Auery object
  Map<String, dynamic> toJson() {
    final result = Map<String, dynamic>.from({});
    if (ands != null) {
      result['ands'] = List<Map<String, dynamic>>.from(ands.map((an) => an.toJson()));
    }
    if (ors != null) {
      result['ors'] = List<Map<String, dynamic>>.from(ors.map((or) => or.toJson()));
    }
    if (sort != null) {
      result['sort'] = sort.toJson();
    }
    return Map<String, dynamic>.from(result);
  }
}

/// ThreadID represents a self-describing Thread identifier.
/// It is formed by a version, a variant, and a random number of a given length.
/// {@category Data Types}
class ThreadID {
  List<int> _bytes;
  ThreadID(List<int> _bytes);
  
  /// fromRandom creates a new random ID object.
  /// variant is the Thread variant to use. @see Variant
  /// size is the size of the random component to use. Defaults to 32 bytes.
  ThreadID.fromRandom({int version = 0x01, int variant = 0x55, int size = 32}) {
    // two 8 bytes (max) numbers plus random bytes
    final bytes = [version, variant];
    bytes.addAll(List<int>.generate(size, (i) => Random().nextInt(256)));
    _bytes = bytes;
  }

  /// toBytes returns the byte representation of an ID.
  List<int> toBytes() {
    return _bytes;
  }

  /// toString returns the (multibase encoded) string representation of an ID.
  String toString() {
    return base64.encode(_bytes);
  }
}

class _QueryValue {
  String string;
  bool boolean;
  Float number;
  _QueryValue({this.string, this.boolean, this.number});

  _QueryValue.fromJson(Map<String, dynamic> values)
    : string = values.containsKey('string') ? values['string'] as String : null,
      boolean = values.containsKey('boolean') ? values['boolean'] as bool : null,
      number = values.containsKey('number') ? values['number'] as Float : null;

  Map<String, dynamic> toJson() {
    final result = {};
    if (string != null) {
      result['string'] = string;
    }
    if (boolean != null) {
      result['boolean'] = boolean;
    }
    if (number != null) {
      result['number'] = number;
    }
    return Map<String, dynamic>.from(result);
  }
}

class _QuerySort {
  String fieldPath;
  bool desc;
  _QuerySort(this.fieldPath, this.desc);
  _QuerySort.fromJson(Map<String, dynamic> settings)
    : fieldPath = settings['fieldPath'] as String,
      desc = settings['desc'] as bool;
  Map<String, dynamic> toJson() =>
    Map<String, dynamic>.from({
      'fieldPath': fieldPath,
      'desc': desc
    });
}

// @todo: probably should just be an enum
int _convertOperation (String op) {
  switch (op.toLowerCase()) {
    case 'eq':
      return 0;
    case 'ne':
      return 1;
    case 'gt':
      return 2;
    case 'lt':
      return 3;
    case 'ge':
      return 4;
    case 'le':
      return 5;
    default:
      return 0;
  }
}

class _QueryCriterion {
  String fieldPath;
  int operation;
  _QueryValue value;
  Query query;
  _QueryCriterion({this.fieldPath, this.operation, this.value, this.query});

  _QueryCriterion.fromJson(Map<String, dynamic> criterion)
    : fieldPath = criterion.containsKey('fieldPath') ? criterion['fieldPath'] as String : null,
      operation = criterion.containsKey('operation') ? _convertOperation(criterion['operation'] as String) : null,
      value = criterion.containsKey('value') ? _QueryValue.fromJson(criterion['value']) : null,
      query = criterion.containsKey('query') ? Query.fromJson(criterion['query']) : null;
  Map<String, dynamic> toJson() {
    final result = {
      'fieldPath': fieldPath,
      'operation': operation
    };
    if (value != null) {
      result['value'] = value.toJson();
    }
    if (query != null) {
      result['query'] = query.toJson();
    }
    return Map<String, dynamic>.from(result);
  }
    
}

List<_QueryCriterion> _createJSONCriterionList (List<dynamic> input) {
  final results = [];
  for (var i=0; i<input.length; i++) {
    results.add(
      _QueryCriterion.fromJson(Map<String, dynamic>.from(input[i]))
    );
  }
  return List<_QueryCriterion>.from(results);
}

List<Query> _createJSONQueryList (List<dynamic> input) {
  final results = [];
  for (var i=0; i<input.length; i++) {
    results.add(
      Query.fromJson(Map<String, dynamic>.from(input[i]))
    );
  }
  return List<Query>.from(results);
}
