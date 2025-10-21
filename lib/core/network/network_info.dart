import 'package:connectivity_plus/connectivity_plus.dart';

//Revisar conexión a internet
abstract class NetworkInfo {
  Future<bool> get isConnected;
}


class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  NetworkInfoImpl(this.connectivity);

  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
