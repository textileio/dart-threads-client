
import 'package:threads_client/src/client.dart';

main(List<String> args) async {
  var client = new Client();
  client.main(args);
  await client.newStore();
  return client;
}