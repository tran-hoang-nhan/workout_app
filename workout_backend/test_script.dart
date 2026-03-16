import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

Future<void> main() async {
  try {
    final res = await http.put(
      Uri.parse('http://localhost:8080/api/health'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': '3e89bd4c-6f02-47a0-bcc2-4672996b1d32',
        'age': 25,
        'weight': 70.0,
        'height': 170.0,
        'activity_level': 'sedentary',
        'goal': 'maintain',
        'diet_type': 'Balanced',
        'water_intake': 2000,
        'injuries': <String>[],
        'medical_conditions': <String>[],
        'allergies': <String>[],
      }),
    );
    stdout
      ..writeln(res.statusCode)
      ..writeln(res.body);
  } catch (e) {
    stdout.writeln(e);
  }
}
