import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UploadService {
  static const _apiKey = 'ksmJq3beg8X70mIprzPEBtJs9hoeRGG7f388aLbHaMpwz8HZyK'; // <-- 여기에 진짜 API 키 넣기
  static const _endpoint = 'https://api.plant.id/v3/identification';

  static Future<Map<String, dynamic>?> upload(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final requestBody = {
        "images": [base64Image],
        "similar_images": true,
        "health": "auto",  // 건강 상태 분석
        "classification_level": "species",  // 종 수준까지 분류
      };

      print("📤 Sending to Plant.id: ${jsonEncode(requestBody)}");

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Api-Key': _apiKey,
        },
        body: jsonEncode(requestBody),
      );

      print("✅ Status: ${response.statusCode}");
      print("✅ Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
         final decodedBody = jsonDecode(response.body);
         final plantName = getTopPlantName(decodedBody);
         print("🌿 Plant Name: $plantName");
         final searchResult = await searchPlantByName(plantName);
         print("🌿 Search Result: $searchResult");
         final accessToken = getFirstEntityAccessToken(searchResult);
         print("🌿 Access Token: $accessToken");
         final detailsResult = await fetchPlantDetails(accessToken);
         print("🌿 Details Result: $detailsResult");
        return detailsResult;
      } else {
        print("❌ Upload failed: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Exception during upload: $e");
      return null;
    }
  }

  static Future<Map<String, dynamic>> fetchPlantDetails(String accessToken) async {
    final url =
        'https://plant.id/api/v3/kb/plants/$accessToken?details=common_names,url,description,taxonomy,rank,gbif_id,inaturalist_id,image,synonyms,edible_parts,watering,propagation_methods&language=en';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Api-Key': 'ksmJq3beg8X70mIprzPEBtJs9hoeRGG7f388aLbHaMpwz8HZyK',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load plant details: ${response.statusCode}');
    }
  }

  static String getTopPlantName(Map<String, dynamic> responseJson) {
    final suggestions = responseJson['result']['classification']['suggestions'] as List;
    if (suggestions.isEmpty) throw Exception('No suggestions found');

    suggestions.sort((a, b) => (b['probability'] as num).compareTo(a['probability'] as num));
    return suggestions.first['name'];
  }

  static String getFirstEntityAccessToken(Map<String, dynamic> json) {
    final entities = json['entities'] as List<dynamic>;
    if (entities.isEmpty) {
      throw Exception('엔티티가 존재하지 않습니다.');
    }

    final firstEntity = entities.first as Map<String, dynamic>;
    return firstEntity['access_token'] as String;
  }


  static Future<Map<String, dynamic>> searchPlantByName(String name) async {
    final url = 'https://plant.id/api/v3/kb/plants/name_search?q=${Uri.encodeComponent(name)}';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Api-Key': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to search plant by name: ${response.statusCode}');
    }
  }

  static String getFirstEntityName(Map<String, dynamic> json) {
    final entities = json['entities'] as List<dynamic>;
    if (entities.isEmpty) {
      throw Exception('엔티티가 존재하지 않습니다.');
    }

    final firstEntity = entities.first as Map<String, dynamic>;
    return firstEntity['entity_name'] as String;
  }
}
