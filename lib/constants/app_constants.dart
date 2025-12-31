import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFF97316); // Orange-500
  static const Color primaryLight = Color(0xFFFB923C); // Orange-400
  static const Color primaryDark = Color(0xFFEA580C); // Orange-600
  
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);
  static const Color info = Color(0xFF3B82F6);
  
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111827); // Gray-900
  static const Color grey = Color(0xFF6B7280);
  static const Color greyLight = Color(0xFFF3F4F6);
  static const Color greyDark = Color(0xFF374151);
  
  // Background colors
  static const Color bgLight = Color(0xFFF8F9FD); // Premium light neutral background
  static const Color bgWhite = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE5E7EB); // Gray-200
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppBorderRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double xxl = 24.0;
  static const double full = 999.0;
}

class AppFontSize {
  static const double xs = 12.0;
  static const double sm = 14.0;
  static const double md = 16.0;
  static const double lg = 18.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

class AppStrings {
  // Auth
  static const String login = 'Đăng Nhập';
  static const String register = 'Đăng Ký';
  static const String email = 'Email';
  static const String password = 'Mật Khẩu';
  static const String confirmPassword = 'Xác Nhận Mật Khẩu';
  static const String fullName = 'Tên Đầy Đủ';
  static const String forgotPassword = 'Quên Mật Khẩu?';
  static const String signIn = 'Đăng Nhập';
  static const String signUp = 'Đăng Ký';
  static const String signOut = 'Đăng Xuất';
  static const String dontHaveAccount = 'Bạn chưa có tài khoản?';
  static const String alreadyHaveAccount = 'Bạn đã có tài khoản?';
  
  // General
  static const String ok = 'OK';
  static const String cancel = 'Hủy';
  static const String save = 'Lưu';
  static const String delete = 'Xóa';
  static const String edit = 'Chỉnh Sửa';
  static const String loading = 'Đang tải...';
  static const String error = 'Lỗi';
  static const String success = 'Thành Công';
}
