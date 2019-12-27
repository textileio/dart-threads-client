
import 'package:threads_client/threads_client.dart';

void main(List<String> args) async {
  final client = ThreadsClient();
  final store = await client.newStore();
  print('New store $store');
}