import 'package:firebase_core/firebase_core.dart';

import 'exception.dart';
import 'failures.dart';
import 'messages/execption_messages.dart';

AppFailure mapToFailure(Object error) {
  if (error is AppFailure) return error;

  if (error is NetworkException) {
    return const NetworkFailure(AppExceptionMessages.noInternet);
  }

  if (error is TimeoutException) {
    return const TimeoutFailure(AppExceptionMessages.requestTimedOut);
  }

  if (error is FirebaseException) {
    return _failureFromFirebase(error);
  }

  return FirestoreFailure(AppExceptionMessages.unexpectedError);
}

AppFailure _failureFromFirebase(FirebaseException exception) {
  switch (exception.code) {
    case 'unavailable':
    case 'network-request-failed':
      return const NetworkFailure(AppExceptionMessages.noInternet);
    case 'deadline-exceeded':
      return const TimeoutFailure(AppExceptionMessages.requestTimedOut);
    default:
      return FirestoreFailure(
        AppExceptionMessages.messageForCode(exception.code),
      );
  }
}
