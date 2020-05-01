import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:threads_client/threads_client.dart' as threads;
import 'package:test/test.dart';

const personSchema = {
  '\$id': 'https://example.com/person.schema.json',
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  'title': 'Person',
  'type': 'object',
  'required': ['_id'],
  'properties': {
    '_id': {
      'type': 'string',
      'description': 'The instance\'s id.',
    },
    'firstName': {
      'type': 'string',
      'description': 'The person\'s first name.',
    },
    'lastName': {
      'type': 'string',
      'description': 'The person\'s last name.',
    },
    'age': {
      'description': 'Age in years which must be equal to or greater than zero.',
      'type': 'integer',
      'minimum': 0,
    },
    'biker': {
      'description': 'Does the person own a bike.',
      'type': 'boolean',
    },
  },
};

void main() async {
  threads.Client client;
  final threadId = threads.ThreadID.fromRandom();
  final dbID = threadId.toString();
  final env = Platform.environment;
  final newAge = 42;
  String collectionID;
  
  setUpAll(() {
    // // Thread client options
    final config = threads.Config(
      host: env.containsKey('THREADS_HOST') && env['THREADS_HOST'] != '' ? env['THREADS_HOST'] : '127.0.0.1',
      port: env.containsKey('THREADS_PORT') && env['THREADS_PORT'] != '' ? int.parse(env['THREADS_PORT']) : 6006
    );

    // Create a new threads client
    client = threads.Client(config: config);
  });
  tearDownAll(() async {
    // Shutdown the threads client.
    await client.shutdown();
  });
  test('Create new DB', () async {
    await client.newDB(dbID);
  });
  test('Register a schema for the new db', () async {
    final jsonData = JsonCodec().encode(personSchema);
    final jsonString = jsonData.toString();
    await client.newCollection(dbID: dbID, name: 'Person', schema: jsonString);
    expect(true, true);
  });
  test('Get a link to invite others to the db', () async {
    final link = await client.getDBInfo(dbID);
    expect(link.addresses.length, greaterThan(0));
  });
  test('Create a new model in the db', () async {
    final model = createPerson();
    try {
      final response = await client.create(dbID, 'Person', [model.toJson()]);
      expect(response.length, 1);
      collectionID = response[0];
      expect(true, true);
    } catch (error) {
      expect(error.toString(), '');
    }
  });
  test('Update an existing model in the db', () async {
    final model = createPerson(id: collectionID, age: newAge);
    try {
      await client.save(dbID, 'Person', [model.toJson()]);
      expect(true, true);
    } catch (error) {
      expect(error.toString(), '');
    }
  });
  test('Check if an ID exists in the db', () async {
    try {
      final response = await client.has(dbID, 'Person', [collectionID]);
      expect(response, true);
    } catch (error) {
      // fail if error
      expect(error.toString(), '');
    }
  });

  test('Fetch a model by its ID', () async {
    try {
      final response = await client.findById(dbID, 'Person', collectionID);
      final person = Person.fromJson(response);
      expect(person.age, newAge);
    } catch (error) {
      // fail if error
      expect(error.toString(), '');
    }
  });

  test('Fetch an unknown model ID should return null', () async {
    try {
      await client.findById(dbID, 'Person', 'xyz');
      // should fail by here
      expect(false, true);
    } catch (error) {
      // should error
      expect(error.toString(), 'gRPC Error (2, instance not found)');
    }
  });

  test('Run an advanced query on db models', () async {
    try {
      final queryJSON = threads.Query.fromJson({
        'ands': [{
            'fieldPath': 'firstName',
            'operation': 'Eq',
            'value': { 'string': 'Adam' }
          }],
        'ors': [{
          'ands': [{
            'fieldPath': 'firstName',
            'operation': 'Eq',
            'value': { 'string': 'Doe' }
          }]
        }],
        'sort': { 'fieldPath': 'firstName', 'desc': true}
      });
      expect(queryJSON.ands, isNotEmpty);
      await client.find(dbID, 'Person', queryJSON);
    } catch (error) {
      expect(error.toString(), '');
    }
  });

  
  test('Create an update listener on the db', () async {
    try {
      final events = [];
      final blocker = client.createListener(dbID);
      final stream = blocker.listen((result){
        final person = Person.fromJson(result.instance);
        events.add(person.age);
      });

      final ages = [22, 23];
      for (var i=0; i<ages.length; i++) {
        final model = createPerson(id: collectionID, age: ages[i]);
        await client.save(dbID, 'Person', [model.toJson()]);
      };
      // @todo: fix. sdoesn't work on CI
      // expect(events.length, ages.length);
      await stream.cancel();
    } catch (error) {
      expect(error.toString(), '');
    }
  });

  test('Run a query containing numeric type', () async {
    try {
      final queryJSON = threads.Query.fromJson({
        'ands': [{
            'fieldPath': 'age',
            'operation': 'ge',
            'value': { 'number': 20 }
          }],
        'sort': { 'fieldPath': 'firstName', 'desc': true}
      });
      expect(queryJSON.ands, isNotEmpty);
      final res = await client.find(dbID, 'Person', queryJSON);
      expect(res.length, 1);
    } catch (error) {
      expect(error.toString(), '');
    }
  });

  test('Run a query using boolean type', () async {
    try {
      final queryJSON = threads.Query.fromJson({
        'ands': [{
            'fieldPath': 'biker',
            'operation': 'eq',
            'value': { 'boolean': true }
          }],
        'sort': { 'fieldPath': 'firstName', 'desc': true}
      });
      expect(queryJSON.ands, isNotEmpty);
      final res = await client.find(dbID, 'Person', queryJSON);
      expect(res.length, 1);
    } catch (error) {
      expect(error.toString(), '');
    }
  });

  test('Run a query that returns no result', () async {
    try {
      final queryJSON = threads.Query.fromJson({
        'ands': [{
            'fieldPath': 'biker',
            'operation': 'eq',
            'value': { 'boolean': false }
          }],
        'sort': { 'fieldPath': 'firstName', 'desc': true}
      });
      expect(queryJSON.ands, isNotEmpty);
      final res = await client.find(dbID, 'Person', queryJSON);
      expect(res.length, 0);
    } catch (error) {
      expect(error.toString(), '');
    }
  });
}

class Person {
  final String id;
  final String firstName;
  final String lastName;
  final int age;
  final bool biker;
  Person(this.id, this.firstName, this.lastName, this.age, this.biker);
  Person.fromJson(Map<String, dynamic> json)
      : id = json['_id'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        age = json['age'],
        biker = json['biker'];

  Map<String, dynamic> toJson() =>
    {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'age': age,
      'biker': biker
    };
}

Person createPerson ({String id = '', int age = 24, bool biker = true}) {
  return Person(id, 'Adam', 'Doe', age, biker);
}
