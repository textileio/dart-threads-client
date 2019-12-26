import 'package:grpc/grpc.dart';

const Duration default_timeout = Duration(seconds: 30);
const ChannelCredentials default_credentials = ChannelCredentials.insecure();