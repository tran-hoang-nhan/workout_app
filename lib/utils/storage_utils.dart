import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

String? convertToPublicUrl(
  SupabaseClient supabase,
  String? url,
  String bucketName, {
  String Function(String bucket, String path)? publicUrlResolver,
}) {
  if (url == null || url.isEmpty) return null;
  final trimmed = url.trim();
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  try {
    final cleanPath = trimmed.startsWith('/') ? trimmed.substring(1) : trimmed;
    final publicUrl = publicUrlResolver != null
        ? publicUrlResolver(bucketName, cleanPath)
        : supabase.storage.from(bucketName).getPublicUrl(cleanPath);
    debugPrint('[StorageUtils] $trimmed -> $publicUrl');
    return publicUrl;
  } catch (e) {
    debugPrint('[StorageUtils] error: $e, url=$url, bucket=$bucketName');
    return trimmed;
  }
}

Map<String, dynamic> processExerciseJson(
  SupabaseClient supabase,
  Map<String, dynamic> json, {
  String bucketName = 'exercises',
  String Function(String bucket, String path)? publicUrlResolver,
}) {
  final processed = Map<String, dynamic>.from(json);
  if (processed['animation_url'] != null) {
    processed['animation_url'] = convertToPublicUrl(
      supabase,
      processed['animation_url'] as String?,
      bucketName,
      publicUrlResolver: publicUrlResolver,
    );
  }
  if (processed['thumbnail_url'] != null) {
    processed['thumbnail_url'] = convertToPublicUrl(
      supabase,
      processed['thumbnail_url'] as String?,
      bucketName,
      publicUrlResolver: publicUrlResolver,
    );
  }
  return processed;
}
