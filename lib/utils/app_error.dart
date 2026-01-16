import 'dart:io'; // Cần import để bắt SocketException
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Class gốc
class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  AppError(this.message, {this.code, this.originalException, this.stackTrace});

  /// Thông báo hiển thị cho User (Logic Dart 3)
  String get userMessage {
    // Nếu có code, ưu tiên map code sang tiếng Việt
    if (code != null) {
      return _mapCodeToUserMessage(code!);
    }
    // Nếu là lỗi Validation (lỗi logic form), hiển thị message gốc
    if (this is ValidationException) return message;
    
    // Nếu lỗi lạ (Exception kỹ thuật), không show cho user xem -> show thông báo chung
    return 'Đã có lỗi không mong muốn xảy ra. Vui lòng thử lại.';
  }

  @override
  String toString() => 'AppError[$code]: $message';
  static String _mapCodeToUserMessage(String code) => switch (code) {
    '23505' => 'Dữ liệu này đã tồn tại trong hệ thống.',
    '23503' => 'Dữ liệu liên quan không hợp lệ hoặc đang được sử dụng.',
    '42P01' => 'Lỗi cấu hình hệ thống (Bảng không tồn tại).',
    'PGRST116' => 'Không tìm thấy dữ liệu yêu cầu.', 
    'invalid_credentials' => 'Email hoặc mật khẩu không chính xác.',
    'user_not_found' => 'Tài khoản không tồn tại.',
    'email_not_confirmed' => 'Vui lòng xác nhận email trước khi đăng nhập.',
    'user_already_exists' => 'Email này đã được đăng ký.',
    'otp_expired' => 'Mã xác thực đã hết hạn.',
    'weak_password' => 'Mật khẩu quá yếu.',
    _ => 'Lỗi hệ thống ($code). Vui lòng báo cho admin.',
  };
}

class NetworkException extends AppError {
  NetworkException({super.originalException, super.stackTrace}) : super('Lỗi kết nối mạng', code: 'network_error');
  @override
  String get userMessage => 'Không thể kết nối mạng. Vui lòng kiểm tra đường truyền.';
}

class DatabaseException extends AppError {
  DatabaseException(super.message, {super.code, super.originalException, super.stackTrace});
}

class ValidationException extends AppError {
  ValidationException(super.message);
}

class UnauthorizedException extends AppError {
  UnauthorizedException(super.message, {super.code, super.originalException});
  @override
  String get userMessage => 'Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.';
}

AppError handleException(Object error, [StackTrace? stackTrace]) {
  if (error is AppError) {
    return error; 
  }

  if (error is PostgrestException) {
    return DatabaseException(
      error.message,
      code: error.code,
      originalException: error,
      stackTrace: stackTrace,
    );
  }

  if (error is AuthException) {
    String? mappedCode;
    final msg = error.message.toLowerCase();
    if (msg.contains('invalid login')) {
      mappedCode = 'invalid_credentials';
    }
    else if (msg.contains('user not found')) {
      mappedCode = 'user_not_found';
    }
    else if (msg.contains('email not confirmed')) {
      mappedCode = 'email_not_confirmed';
    }
    else if (msg.contains('already registered')) {
      mappedCode = 'user_already_exists';
    }

    return UnauthorizedException(
      error.message,
      code: mappedCode ?? error.statusCode, 
      originalException: error,
    );
  }

  if (error is SocketException) {
    return NetworkException(originalException: error, stackTrace: stackTrace);
  }
  
  final errorStr = error.toString().toLowerCase();
  if (errorStr.contains('socketexception') || 
      errorStr.contains('connection failed') || 
      errorStr.contains('network is unreachable')) {
    return NetworkException(originalException: error, stackTrace: stackTrace);
  }

  return AppError(
    error.toString(), 
    originalException: error, 
    stackTrace: stackTrace
  );
}