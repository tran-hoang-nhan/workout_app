/// Định nghĩa các class và hàm xử lý lỗi chung cho toàn app
library;

import 'package:supabase_flutter/supabase_flutter.dart';

class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

   AppError(this.message, {this.code, this.originalException, this.stackTrace});

  @override
  String toString() => 'AppError[$code]: $message';
}

class NetworkException extends AppError {
  NetworkException(super.message, {super.code, super.originalException, super.stackTrace});
}

class DatabaseException extends AppError {
  DatabaseException(super.message, {super.code, super.originalException, super.stackTrace});
}

class ValidationException extends AppError {
  ValidationException(super.message, {super.code, super.originalException, super.stackTrace});
}

class UnauthorizedException extends AppError {
  UnauthorizedException(super.message, {super.code, super.originalException, super.stackTrace});
}

class ServerException extends AppError {
  ServerException(super.message, {super.code, super.originalException, super.stackTrace});
}

AppError handleException(Object error, [StackTrace? stackTrace]) {
  if (error is AppError) return error;
  
  // Supabase specific errors
  if (error is PostgrestException) {
    return DatabaseException(
      error.message,
      code: error.code,
      originalException: error,
      stackTrace: stackTrace,
    );
  }
  
  if (error is AuthException) {
    return UnauthorizedException(
      error.message,
      code: error.statusCode,
      originalException: error,
      stackTrace: stackTrace,
    );
  }

  // Generic mapping
  final errorStr = error.toString();
  if (errorStr.contains('SocketException') || errorStr.contains('Network')) {
    return NetworkException('Lỗi kết nối mạng. Vui lòng kiểm tra lại.', originalException: error, stackTrace: stackTrace);
  }

  return AppError(errorStr, stackTrace: stackTrace);
}

