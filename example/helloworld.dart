
import 'package:threads_client/threads_client.dart';

main(List<String> args) async {
  var client = new Client();
  client.main(args);
  var store = await client.newStore();
  print('New store $store');
}