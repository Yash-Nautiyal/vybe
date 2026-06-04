import 'network_info.dart';

class AppNetwork {
  AppNetwork._();

  static final NetworkInfo instance = NetworkInfoImpl();
}
