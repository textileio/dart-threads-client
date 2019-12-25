
import 'package:threads_client/src/client.dart';

main(List<String> args) async {
  var client = new Client();
  client.main(args);
  var store = await client.newStore();
  print('New store $store');
  return client;
}