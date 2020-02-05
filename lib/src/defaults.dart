import 'package:grpc/grpc.dart';

const String default_host = '127.0.0.1';
const int default_port = 6006;
const Duration default_timeout = Duration(seconds: 30);
const ChannelCredentials default_credentials = ChannelCredentials.insecure();