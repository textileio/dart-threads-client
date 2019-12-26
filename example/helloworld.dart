
import 'package:threads_client/threads_client.dart';

main(List<String> args) async {
  var client = new ThreadsClient();
  var store = await client.newStore();
  print('New store $store');
}