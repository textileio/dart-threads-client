
import 'dart:ffi';

class StoreLinks {
  final List<String> addresses;
  final String followKey;
  final String readKey;
  StoreLinks._(this.addresses, this.followKey, this.readKey);
  factory StoreLinks(List<String> addresses, String followKey, String readKey) {
    return new StoreLinks._(addresses, followKey, readKey);
  }
  StoreLinks.fromJson(Map<String, dynamic> values)
    : addresses = values['addresses'] as List<String>,
      followKey = values['followKey'] as String,
      readKey = values['readKey'] as String;

  Map<String, dynamic> toJson() =>
  {
    'addresses': addresses,
    'followKey': followKey,
    'readKey': readKey
  };
}

class ListenResult {
  String modelName;
  String entityID;
  String action;
  Map<String, dynamic> entity;
  ListenResult(this.modelName, this.entityID, this.action, this.entity);
  ListenResult.fromJson(Map<String, dynamic> values)
    : modelName = values['modelName'] as String,
      entityID = values['entityID'] as String,
      action = values['action'] as String,
      entity = values['entity'] as Map<String, dynamic>;

  Map<String, dynamic> toJson() =>
  {
    'modelName': modelName,
    'entityID': entityID,
    'action': action,
    'entity': entity
  };
}

class JSONValue {
  String string;
  bool boolean;
  Float number;
  JSONValue({this.string, this.boolean, this.number});

  JSONValue.fromJson(Map<String, dynamic> values)
    : string = values.containsKey('string') ? values['string'] as String : null,
      boolean = values.containsKey('boolean') ? values['boolean'] as bool : null,
      number = values.containsKey('number') ? values['number'] as Float : null;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    if (string != null) {
      result['string'] = string;
    }
    if (boolean != null) {
      result['boolean'] = boolean;
    }
    if (number != null) {
      result['number'] = number;
    }
    return result;
  }
}

class JSONSort {
  String fieldPath;
  bool desc;
  JSONSort(this.fieldPath, this.desc);
  JSONSort.fromJson(Map<String, dynamic> settings)
    : fieldPath = settings['fieldPath'] as String,
      desc = settings['desc'] as bool;
  Map<String, dynamic> toJson() =>
    {
      'fieldPath': fieldPath,
      'desc': desc
    };
}

// @todo: probably should just be an enum
int convertOperation (String op) {
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

class JSONCriterion {
  String fieldPath;
  int operation;
  JSONValue value;
  JSONQuery query;
  JSONCriterion({this.fieldPath, this.operation, this.value, this.query});

  JSONCriterion.fromJson(Map<String, dynamic> criterion)
    : fieldPath = criterion.containsKey('fieldPath') ? criterion['fieldPath'] as String : null,
      operation = criterion.containsKey('operation') ? convertOperation(criterion['operation'] as String) : null,
      value = criterion.containsKey('value') ? JSONValue.fromJson(criterion['value']) : null,
      query = criterion.containsKey('query') ? JSONQuery.fromJson(criterion['query']) : null;
  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'fieldPath': fieldPath,
      'operation': operation
    };
    if (value != null) {
      result['value'] = value.toJson();
    }
    if (query != null) {
      result['query'] = query.toJson();
    }
    return result;
  }
    
}

createJSONCriterionList (List<dynamic> input) {
  List<JSONCriterion> results = [];
  for (var i=0; i<input.length; i++) {
    results.add(
      JSONCriterion.fromJson(input[i] as Map<String, dynamic>)
    );
  }
  return results;
}

createJSONQueryList (List<dynamic> input) {
  List<JSONQuery> results = [];
  for (var i=0; i<input.length; i++) {
    results.add(
      JSONQuery.fromJson(input[i] as Map<String, dynamic>)
    );
  }
  return results;
}

class JSONQuery {
  List<JSONCriterion> ands;
  List<JSONQuery> ors;
  JSONSort sort;
  JSONQuery({this.ands, this.ors, this.sort});

  JSONQuery.fromJson(Map<String, dynamic> query)
    : ands = query.containsKey('ands') ? createJSONCriterionList(query['ands']): null,
      ors = query.containsKey('ors') ? createJSONQueryList(query['ors']): null,
      sort = query.containsKey('sort') ? JSONSort.fromJson(query['sort']): null;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    if (ands != null) {
      result['ands'] = ands.map((an) => an.toJson()).toList();
    }
    if (ors != null) {
      result['ors'] = ors.map((or) => or.toJson()).toList();
    }
    if (sort != null) {
      result['sort'] = sort.toJson();
    }
    return result;
  }
}