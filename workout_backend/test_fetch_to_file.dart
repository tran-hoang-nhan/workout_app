import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() async {
  try {
    final res = await http.get(Uri.parse('http://localhost:8080/api/workouts'));
    if (res.statusCode == 200) {
      final list = json.decode(res.body) as List;
      final buffer = StringBuffer();
      for (var item in list) {
        buffer.writeln('ID: ${item['id']}');
        buffer.writeln('Title: ${item['title']}');
        buffer.writeln('Desc: ${item['description']}');
        buffer.writeln('---');
      }
      File('workouts_debug.txt').writeAsStringSync(buffer.toString());
      print('Written to workouts_debug.txt');
    } else {
      print('Error: ${res.statusCode}');
    }
  } catch (e) {
    print('Exception: $e');
  }
}
