```
class Person {
  final String ID;
  final String firstName;
  final String lastName;
  final int age;
  Person(this.ID, this.firstName, this.lastName, this.age);
  Person.fromJson(Map<String, dynamic> json)
      : ID = json['ID'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        age = json['age'];

  Map<String, dynamic> toJson() =>
    {
      'ID': ID,
      'firstName': firstName,
      'lastName': lastName,
      'age': age
    };
}

final model = Person('', 'Adam', 'Doe', 24);
try {
  final response = await client.create(dbId, 'Person', [model.toJson()]);
  expect(response.length, 1);
  collectionID = response[0];
  expect(true, true);
} catch (error) {
  expect(error.toString(), '');
}
```
