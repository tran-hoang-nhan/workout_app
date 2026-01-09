/// Định nghĩa các class và hàm xử lý lỗi chung cho toàn app
library;

import 'package:supabase_flutter/supabase_flutter.dart';

class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  AppError(this.message, {this.code, this.originalException, this.stackTrace});

  /// Thông báo lỗi thân thiện để hiển thị lên UI
  String get userMessage {
    if (code != null) {
      return _mapCodeToMessage(code!);
    }
    return message;
  }

  @override
  String toString() => 'AppError[$code]: $message';

  static String _mapCodeToMessage(String code) {
    switch (code) {
      // Supabase / Postgrest Errors
      case '23505': return 'Dữ liệu đã tồn tại trong hệ thống.';
      case '23503': return 'Dữ liệu liên quan không tồn tại hoặc đang được sử dụng.';
      case '42P01': return 'Lỗi hệ thống database (Table not found).';
      
      // Auth Errors
      case 'invalid_credentials': return 'Email hoặc mật khẩu không chính xác.';
      case 'user_not_found': return 'Người dùng không tồn tại.';
      case 'email_not_confirmed': return 'Vui lòng xác nhận email trước khi đăng nhập.';
      case 'user_already_exists': return 'Email này đã được đăng ký.';
      case 'invalid_grant': return 'Thông tin đăng nhập không hợp lệ hoặc đã hết hạn.';
      
      default: return 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';
    }
  }
}

class NetworkException extends AppError {
  NetworkException(super.message, {super.code, super.originalException, super.stackTrace});
  @override
  String get userMessage => 'Không thể kết nối mạng. Vui lòng kiểm tra lại đường truyền.';
}

class DatabaseException extends AppError {
  DatabaseException(super.message, {super.code, super.originalException, super.stackTrace});
}

class ValidationException extends AppError {
  ValidationException(super.message, {super.code, super.originalException, super.stackTrace});
  @override
  String get userMessage => message; // Validation thường đã là message thân thiện
}

class UnauthorizedException extends AppError {
  UnauthorizedException(super.message, {super.code, super.originalException, super.stackTrace});
  @override
  String get userMessage => 'Phiên làm việc hết hạn hoặc không có quyền truy cập.';
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
    // AuthException có thể có message là technical, dùng code hoặc message thô
    return UnauthorizedException(
      error.message,
      code: error.message.contains('Invalid login credentials') ? 'invalid_credentials' : null,
      originalException: error,
      stackTrace: stackTrace,
    );
  }

  // Generic mapping
  final errorStr = error.toString().toLowerCase();
  if (errorStr.contains('socketexception') || 
      errorStr.contains('network') || 
      errorStr.contains('connection failed')) {
    return NetworkException('Network error', originalException: error, stackTrace: stackTrace);
  }

  if (errorStr.contains('timeout')) {
    return AppError('Yêu cầu quá hạn. Vui lòng thử lại.', code: 'timeout', originalException: error, stackTrace: stackTrace);
  }

  return AppError(error.toString(), stackTrace: stackTrace);
}

