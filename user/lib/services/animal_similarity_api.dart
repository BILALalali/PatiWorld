import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

/// API Service for Animal Similarity AI Model
class AnimalSimilarityAPI {
  // API Configuration - Auto-detect platform
  // Note: Port 5001 is used because 5000 is often taken by AirPlay on macOS
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5001';
    }
    
    // iOS Simulator uses localhost
    if (Platform.isIOS) {
      return 'http://127.0.0.1:5001';
    }
    
    // Android Emulator uses 10.0.2.2
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5001';
    }
    
    // Default for other platforms
    return 'http://127.0.0.1:5001';
  }
  
  // For manual override, uncomment and set your IP:
  // static const String _baseUrl = 'http://192.168.1.100:5000'; // Real device IP
  
  static const String _apiVersion = '/api/v1';
  static const Duration _timeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
  };
  
  /// Health check endpoint
  static Future<ApiResponse> checkHealth() async {
    try {
      final url = '$_baseUrl$_apiVersion/health';
      print('🏥 Checking AI API health at: $url');
      print('   Platform: ${Platform.isIOS ? "iOS" : Platform.isAndroid ? "Android" : "Other"}');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      ).timeout(_timeout);
      
      final result = ApiResponse.fromJson(response);
      if (result.success) {
        print('✅ AI API is healthy and ready!');
        if (result.data != null) {
          print('   Model loaded: ${result.data['model_loaded'] ?? 'unknown'}');
          print('   Database loaded: ${result.data['database_loaded'] ?? 'unknown'}');
        }
      } else {
        print('⚠️ AI API health check failed: ${result.error}');
        print('   Status code: ${result.statusCode}');
        print('   💡 Solution: Run "python api_server.py" in model_project folder');
      }
      return result;
    } catch (e, stackTrace) {
      print('❌ AI API health check error: $e');
      print('   URL: $_baseUrl$_apiVersion/health');
      print('   Stack trace: $stackTrace');
      print('   💡 Make sure Flask API Server is running at $_baseUrl');
      print('   💡 Run: cd user/model_project && python api_server.py');
      return ApiResponse.error('Health check failed: $e');
    }
  }
  
  /// Search for similar animals using AI
  static Future<ApiResponse> searchSimilarImage(
    File imageFile, {
    int topK = 10,
    double threshold = 0.6,
    String? animalType,
    String? breed,
    String? city,
  }) async {
    try {
      final url = '$_baseUrl$_apiVersion/search';
      print('📡 Sending request to: $url');
      
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );
      
      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ));
      
      // Add parameters
      request.fields['top_k'] = topK.toString();
      request.fields['threshold'] = threshold.toString();
      if (animalType != null) {
        request.fields['animal_type'] = animalType;
      }
      if (breed != null) {
        request.fields['breed'] = breed;
      }
      if (city != null) {
        request.fields['city'] = city;
      }
      
      // Send request
      var streamedResponse = await request.send().timeout(_timeout);
      var response = await http.Response.fromStream(streamedResponse);
      
      final result = ApiResponse.fromJson(response);
      if (result.success) {
        print('✅ AI search successful!');
      } else {
        print('⚠️ AI search failed: ${result.error}');
      }
      return result;
    } catch (e) {
      print('❌ AI search error: $e');
      print('   URL: $_baseUrl$_apiVersion/search');
      print('   Make sure Flask API Server is running!');
      return ApiResponse.error('Search failed: $e');
    }
  }
  
  /// Get statistics
  static Future<ApiResponse> getStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_apiVersion/stats'),
        headers: _headers,
      ).timeout(_timeout);
      
      return ApiResponse.fromJson(response);
    } catch (e) {
      return ApiResponse.error('Failed to get statistics: $e');
    }
  }
}

/// API Response Model
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;
  final String? message;
  final int? statusCode;
  
  ApiResponse({
    required this.success,
    this.data,
    this.error,
    this.message,
    this.statusCode,
  });
  
  factory ApiResponse.fromJson(http.Response response) {
    // Log response details for debugging
    print('📥 Response status: ${response.statusCode}');
    print('📥 Response body length: ${response.body.length}');
    if (response.body.length < 200) {
      print('📥 Response body: ${response.body}');
    }
    
    // Check for empty response
    if (response.body.isEmpty || response.body.trim().isEmpty) {
      print('⚠️ Empty response body received');
      return ApiResponse(
        success: false,
        error: 'Empty response from server. Is Flask API Server running?',
        statusCode: response.statusCode,
      );
    }
    
    // Check for error status codes
    if (response.statusCode >= 400) {
      String errorMsg = 'Server error (${response.statusCode})';
      if (response.statusCode == 403) {
        errorMsg = 'Forbidden (403). Check CORS settings or server configuration.';
      } else if (response.statusCode == 404) {
        errorMsg = 'Not found (404). Check API endpoint URL.';
      } else if (response.statusCode == 500) {
        errorMsg = 'Internal server error (500). Check Flask server logs.';
      }
      
      print('❌ HTTP Error: $errorMsg');
      print('   Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
      
      return ApiResponse(
        success: false,
        error: errorMsg,
        statusCode: response.statusCode,
      );
    }
    
    try {
      final jsonData = json.decode(response.body);
      
      return ApiResponse(
        success: jsonData['success'] ?? (response.statusCode == 200),
        data: jsonData,
        error: jsonData['error'],
        message: jsonData['message'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      print('❌ JSON Parse Error: $e');
      print('   Response body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
      return ApiResponse(
        success: false,
        error: 'Invalid JSON response: $e',
        statusCode: response.statusCode,
      );
    }
  }
  
  factory ApiResponse.error(String errorMessage) {
    return ApiResponse(
      success: false,
      error: errorMessage,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'error': error,
      'message': message,
      'statusCode': statusCode,
    };
  }
  
  @override
  String toString() {
    return 'ApiResponse(success: $success, error: $error, message: $message)';
  }
}

/// Animal Match from Supabase
class SupabaseAnimalMatch {
  final String lostPetId;
  final String name;
  final String type;
  final String description;
  final String city;
  final String? imageUrl;
  final String? contactNumber;
  final String? whatsappNumber;
  final double aiSimilarity;
  final String aiConfidence;
  final String aiBreed;
  final String matchReason;
  
  SupabaseAnimalMatch({
    required this.lostPetId,
    required this.name,
    required this.type,
    required this.description,
    required this.city,
    this.imageUrl,
    this.contactNumber,
    this.whatsappNumber,
    required this.aiSimilarity,
    required this.aiConfidence,
    required this.aiBreed,
    required this.matchReason,
  });
  
  factory SupabaseAnimalMatch.fromJson(Map<String, dynamic> json) {
    return SupabaseAnimalMatch(
      lostPetId: json['lost_pet_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      imageUrl: json['image_url']?.toString(),
      contactNumber: json['contact_number']?.toString(),
      whatsappNumber: json['whatsapp_number']?.toString(),
      aiSimilarity: (json['ai_similarity'] ?? 0.0).toDouble(),
      aiConfidence: json['ai_confidence']?.toString() ?? 'DÜŞÜK',
      aiBreed: json['ai_breed']?.toString() ?? '',
      matchReason: json['match_reason']?.toString() ?? 'AI Match',
    );
  }
}
