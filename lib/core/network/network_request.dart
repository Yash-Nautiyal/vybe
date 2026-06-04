import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/core/error/exception.dart';
import 'package:vybe/core/network/network_info.dart';

class NetworkRequest {
  const NetworkRequest(this._networkInfo);

  final NetworkInfo _networkInfo;

  static const Duration defaultTimeout = Duration(seconds: 20);

  Future<T> run<T>({
    required Future<T> Function() request,
    Duration timeout = defaultTimeout,
    bool requireConnection = true,
  }) async {
    if (requireConnection && !await _networkInfo.isConnected) {
      throw NetworkException();
    }

    try {
      return await request().timeout(
        timeout,
        onTimeout: () => throw TimeoutException(),
      );
    } on NetworkException {
      rethrow;
    } on TimeoutException {
      rethrow;
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    } on SocketException {
      throw NetworkException();
    }
  }

  static Exception _mapFirebaseException(FirebaseException exception) {
    switch (exception.code) {
      case 'unavailable':
      case 'network-request-failed':
        return NetworkException();
      case 'deadline-exceeded':
        return TimeoutException();
      default:
        return exception;
    }
  }
}
