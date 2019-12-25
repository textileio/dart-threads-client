import 'dart:async';
import 'dart:convert';
import 'package:threads_client/src/client.dart';
import 'package:test/test.dart';


const personSchema = {
  '\$id': 'https://example.com/person.schema.json',
  '\$schema': 'http://json-schema.org/draft-07/schema#',
  'title': 'Person',
  'type': 'object',
  'required': ['ID'],
  'properties': {
    'ID': {
      'type': 'string',
      'description': "The entity's id.",
    },
    'firstName': {
      'type': 'string',
      'description': "The person's first name.",
    },
    'lastName': {
      'type': 'string',
      'description': "The person's last name.",
    },
    'age': {
      'description': 'Age in years which must be equal to or greater than zero.',
      'type': 'integer',
      'minimum': 0,
    },
  },
};

main() {
  Client client;
  String store;
  String address;
  String followKey;
  String readKey;
  setUp(() {
    client = new Client();
    client.main(null);
  });
  tearDown(() async {
    await client.shutdown();
  });
  test("create & start store", () async {
    store = await client.newStore();
    await client.start(store);
    expect(store.length, 36);
  });
  test("register schema", () async {
    var jsonData = JsonCodec().encode(personSchema);
    var jsonString = jsonData.toString();
    await client.registerSchema(storeID: store, name: 'Person', schema: jsonString);
    expect(true, true);
  });
  test("register schema", () async {
    var jsonData = JsonCodec().encode(personSchema);
    var jsonString = jsonData.toString();
    try {
      await client.registerSchema(storeID: store, name: 'Person', schema: jsonString);
      expect(true, true);
    } catch (error) {
      // allow pass if schema exists
      expect(error.toString(), "gRPC Error (2, already registered model)");
    }
  });
  test("get store link", () async {
    var link = await client.getStoreLink(store);
    expect(link.containsKey("1"), true);
    expect(link.containsKey("2"), true);
    expect(link.containsKey("3"), true);
    print(link);
    address = link["1"][0].toString();
    followKey = link["2"].toString();
    print(followKey);
    readKey = link["3"].toString();
    print(readKey);
  });
  test("start from address", () async {
    try {
      await client.startFromAddress(storeID: store, address: address, followKey: followKey, readKey: readKey);
      expect(true, true);
    } catch (error) {
      // fail if error
      expect(error.toString(), "");
    }
  });
  test("create model", () async {
    try {
      await client.startFromAddress(storeID: store, address: address, followKey: followKey, readKey: readKey);
      expect(true, true);
    } catch (error) {
      // fail if error
      expect(error.toString(), "");
    }
  });
}
