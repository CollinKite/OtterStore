import 'dart:convert';
import 'package:http/http.dart' as http;
import 'app_model.dart';

Future<List<AppModel>> fetchApps() async {
  final response = await http.get(Uri.parse('http://localhost:8000/store/apps'));

  if (response.statusCode == 200) {
    List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((app) => AppModel.fromJson(app)).toList();
  } else {
    throw Exception('Failed to load app catalog');
  }
}
