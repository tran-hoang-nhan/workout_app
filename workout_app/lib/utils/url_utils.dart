import 'dart:io';
import 'package:flutter/foundation.dart';

class UrlUtils {
  /// The host to use for local backend requests.
  static String get host {
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    return 'http://localhost:8080';
  }

  /// Sanitizes a URL by:
  /// 1. Prepending host if the URL is a relative path (starts with /).
  /// 2. Replacing 'localhost' with '10.0.2.2' for Android emulators.
  static String sanitize(String url) {
    if (url.isEmpty) return url;

    // Handle relative URLs
    if (url.startsWith('/')) {
      return '$host$url';
    }

    // Handle absolute URLs with localhost
    if (!kIsWeb && Platform.isAndroid) {
      if (url.contains('localhost')) {
        url = url.replaceAll('localhost', '10.0.2.2');
      }
      if (url.contains('127.0.0.1')) {
        url = url.replaceAll('127.0.0.1', '10.0.2.2');
      }
    }

    return url;
  }
}
