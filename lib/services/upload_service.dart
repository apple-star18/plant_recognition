import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';


class UploadService {
  static const String _supabaseUrl = 'https://cwomjbboqlvrqqdkzxfx.supabase.co/functions/v1/plants';

  static String _getBearerToken() {
    final token = dotenv.env['SUPABASE_BEARER_TOKEN'];
    if (token == null) {
      throw Exception('Bearer Token is missing.');
    }
    return 'Bearer $token';
  }

  static bool _isValidFile(File imageFile) {
    final validMimeTypes = ['image/jpeg', 'image/png', 'image/gif'];
    final mimeType = lookupMimeType(imageFile.path);
    if (mimeType == null || !validMimeTypes.contains(mimeType)) {
      print('❌ Invalid file type. Only JPEG, PNG, and GIF are allowed.');
      return false;
    }

    final fileSize = imageFile.lengthSync();
    final maxFileSize = 5 * 1024 * 1024; // Max 5MB
    if (fileSize > maxFileSize) {
      print('❌ File size exceeds the maximum allowed size of 5MB.');
      return false;
    }

    return true;
  }

  static Future<Map<String, dynamic>> upload(File imageFile) async {
    if (imageFile == null || !_isValidFile(imageFile)) {
      return {
        'status': 'error',
        'message': 'Invalid file',
      };
    }

    try {
      final uri = Uri.parse(_supabaseUrl);
      var request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = _getBearerToken();
      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

      var response = await request.send();
      final responseBody = await response.stream.bytesToString(); // Body 읽기
      print('_________: $responseBody ___________');
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ File uploaded successfully.');
        return {
          'status': 'success',
          'message': 'File uploaded successfully.',
          'data': jsonDecode(responseBody)
        };
      } else {
        print('❌ Failed to upload file. Status code: ${response.statusCode}');
        return {
          'status': 'error',
          'message': 'Failed to upload file.',
          'code': response.statusCode,
          'error': jsonDecode(responseBody)
        };
      }
    } catch (e) {
      print('❌ Upload failed: $e');
      return {
        'status': 'error',
        'message': 'Upload failed due to an exception.',
        'exception': e.toString()
      };
    }
  }

}
