import 'dart:io'; // Cần import để bắt SocketException
import 'package:supabase_flutter/supabase_flutter.dart';

// 1. Class gốc
class AppError implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  AppError(this.message, {this.code, this.originalException, this.stackTrace});

  String get userMessage {
    if (code != null) {
      return _mapCodeToUserMessage(code!);
    }
    if (this is ValidationException) return message;
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

class InvalidCredentialsException extends AppError {
  InvalidCredentialsException({super.originalException}) 
    : super('Email hoặc mật khẩu không chính xác', code: 'invalid_credentials');
  
  @override
  String get userMessage => 'Email hoặc mật khẩu không chính xác.';
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
    final errorCode = error.code?.toLowerCase() ?? '';
    
    // 1. Kiểm tra theo mã lỗi (Ưu tiên)
    if (errorCode == 'invalid_credentials' || errorCode == 'invalid_grant') {
      return InvalidCredentialsException(originalException: error);
    }
    
    if (errorCode == 'user_not_found') {
      mappedCode = 'user_not_found';
    }
    else if (errorCode == 'email_not_confirmed' || msg.contains('email not confirmed')) {
      mappedCode = 'email_not_confirmed';
    }
    else if (errorCode == 'user_already_exists' || msg.contains('already registered') || msg.contains('already exists')) {
      mappedCode = 'user_already_exists';
    }
    else if (errorCode == 'signup_disabled') {
       return AppError('Đăng ký tạm thời bị vô hiệu hóa.', code: 'signup_disabled', originalException: error);
    }
    else if (errorCode == 'over_email_send_rate_limit') {
      return AppError('Bạn đã yêu cầu gửi email quá nhanh. Vui lòng thử lại sau ít phút.', code: 'rate_limit', originalException: error);
    }

    // 2. Nếu không có mã lỗi rõ ràng, kiểm tra theo message (Fallback)
    if (mappedCode == null) {
      if (msg.contains('invalid login') || msg.contains('invalid credentials')) {
        return InvalidCredentialsException(originalException: error);
      }
    }

    // Nếu là lỗi Auth thực sự liên quan đến Session/Token bị hết hạn hoặc không hợp lệ
    if (errorCode == 'invalid_token' || errorCode == 'session_not_found' || msg.contains('session expired')) {
       return UnauthorizedException(
        error.message,
        code: errorCode.isNotEmpty ? errorCode : 'unauthorized',
        originalException: error,
      );
    }

    // Mặc định cho các lỗi Auth khác (thường là lỗi đăng ký/đăng nhập)
    // Tránh dùng UnauthorizedException vì nó show "Phiên hết hạn" gây hiểu lầm
    return AppError(
      error.message,
      code: mappedCode ?? (errorCode.isNotEmpty ? errorCode : error.statusCode), 
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