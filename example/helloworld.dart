
import 'package:threads_client/threads_client.dart' as threads;

void main(List<String> args) async {
  final client = threads.Client();
  final dbId = 'bafk7ayo2xuuafgx6ubbcn2lro3s7oixgujdda6shv4';
  await client.newDB(dbId);
}