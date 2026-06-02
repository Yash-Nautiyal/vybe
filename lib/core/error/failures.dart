class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthFailure extends AppFailure {
  const AuthFailure(super.message);
}

class FirestoreFailure extends AppFailure {
  const FirestoreFailure(super.message);
}

class ApiFailure extends AppFailure {
  const ApiFailure(super.message);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = 'Request timed out. Try again.']);
}

class CacheFailure extends AppFailure {
  const CacheFailure(super.message);
}
