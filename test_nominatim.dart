import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?format=json&lat=20.5937&lon=78.9629&addressdetails=1');
  final response = await http.get(url, headers: {'User-Agent': 'ShareMeal/1.0'});
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    print('Address: ${data['display_name']}');
    if (data['address'] != null) {
      final addr = data['address'];
      print('City: ${addr['city'] ?? addr['town'] ?? addr['village']}');
      print('State: ${addr['state']}');
      print('Country: ${addr['country']}');
    }
  } else {
    print('Failed: ${response.statusCode}');
  }
}