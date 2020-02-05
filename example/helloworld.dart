
import 'package:threads_client/threads_client.dart' as threads;

void main(List<String> args) async {
  final client = threads.Client();
  final store = await client.newStore();
  print('New store $store');
}