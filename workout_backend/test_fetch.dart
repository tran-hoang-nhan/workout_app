import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final res = await http.get(Uri.parse('http://localhost:8080/api/workouts'));
  if (res.statusCode == 200) {
    final list = json.decode(res.body) as List;
    for (var item in list) {
      print('ID: ${item['id']} | Title: ${item['title']} | Desc: ${item['description']}');
    }
  } else {
    print('Error: ${res.statusCode}');
  }
}
