/*
Flutter için Profesyonel API Servisi
%100 Çalışır ve Optimize Edilmiş
*/

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

class AnimalSimilarityAPI {
  // API Configuration
  static const String _baseUrl = 'http://10.0.2.2:5000'; // Emulator için
  // static const String _baseUrl = 'http://192.168.1.100:5000'; // Gerçek cihaz için
  
  static const String _apiVersion = '/api/v1';
  static const Duration _timeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> _headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };
  
  // Health Check
  static Future<ApiResponse> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_apiVersion/health'),
        headers: _headers,
      ).timeout(_timeout);
      
      return ApiResponse.fromJson(response);
    } catch (e) {
      return ApiResponse.error('Health check failed: $e');
    }
  }
  
  // Upload and Search
  static Future<ApiResponse> searchSimilarImage(
    File imageFile, {
    int topK = 10,
    double threshold = 0.6,
    String minConfidence = 'ORTA',
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_apiVersion/search'),
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
      request.fields['min_confidence'] = minConfidence;
      
      // Send request
      var streamedResponse = await request.send().timeout(_timeout);
      var response = await http.Response.fromStream(streamedResponse);
      
      return ApiResponse.fromJson(response);
    } catch (e) {
      return ApiResponse.error('Search failed: $e');
    }
  }
  
  // Batch Search
  static Future<ApiResponse> batchSearch(List<File> imageFiles) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_apiVersion/search/batch'),
      );
      
      // Add all images
      for (var file in imageFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'images[]',
          file.path,
          filename: path.basename(file.path),
        ));
      }
      
      var streamedResponse = await request.send().timeout(_timeout);
      var response = await http.Response.fromStream(streamedResponse);
      
      return ApiResponse.fromJson(response);
    } catch (e) {
      return ApiResponse.error('Batch search failed: $e');
    }
  }
  
  // Get Statistics
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
  
  // Add New Animal
  static Future<ApiResponse> addNewAnimal({
    required File imageFile,
    required String animalType,
    required String breed,
    String? description,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl$_apiVersion/add'),
      );
      
      // Add image
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ));
      
      // Add form data
      request.fields['animal_type'] = animalType;
      request.fields['breed'] = breed;
      if (description != null) {
        request.fields['description'] = description;
      }
      
      var streamedResponse = await request.send().timeout(_timeout);
      var response = await http.Response.fromStream(streamedResponse);
      
      return ApiResponse.fromJson(response);
    } catch (e) {
      return ApiResponse.error('Failed to add animal: $e');
    }
  }
  
  // Get Image URL
  static String getImageUrl(String filename) {
    return '$_baseUrl$_apiVersion/images/$filename';
  }
  
  // Download Image
  static Future<Uint8List?> downloadImage(String filename) async {
    try {
      final response = await http.get(
        Uri.parse(getImageUrl(filename)),
      ).timeout(_timeout);
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Download failed: $e');
      }
      return null;
    }
  }
}

// API Response Model
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
    try {
      final jsonData = json.decode(response.body);
      
      return ApiResponse(
        success: jsonData['success'] ?? false,
        data: jsonData,
        error: jsonData['error'],
        message: jsonData['message'],
        statusCode: response.statusCode,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        error: 'Invalid response format: $e',
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

// Animal Match Model
class AnimalMatch {
  final int id;
  final String animalType;
  final String breed;
  final double similarity;
  final String confidence;
  final String matchQuality;
  final String imageName;
  final String imagePath;
  final String scorePercentage;
  
  AnimalMatch({
    required this.id,
    required this.animalType,
    required this.breed,
    required this.similarity,
    required this.confidence,
    required this.matchQuality,
    required this.imageName,
    required this.imagePath,
    required this.scorePercentage,
  });
  
  factory AnimalMatch.fromJson(Map<String, dynamic> json) {
    return AnimalMatch(
      id: json['id'] ?? 0,
      animalType: json['animal_type'] ?? 'Unknown',
      breed: json['breed'] ?? 'Unknown',
      similarity: (json['similarity'] ?? 0.0).toDouble(),
      confidence: json['confidence'] ?? 'LOW',
      matchQuality: json['match_quality'] ?? 'UNKNOWN',
      imageName: json['image_name'] ?? '',
      imagePath: json['image_path'] ?? '',
      scorePercentage: json['score_percentage'] ?? '0%',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'animalType': animalType,
      'breed': breed,
      'similarity': similarity,
      'confidence': confidence,
      'matchQuality': matchQuality,
      'imageName': imageName,
      'imagePath': imagePath,
      'scorePercentage': scorePercentage,
    };
  }
}

// Database Statistics Model
class DatabaseStatistics {
  final int totalImages;
  final int featureDimension;
  final Map<String, int> animalsByType;
  final Map<String, int> topBreeds;
  final double databaseSizeMB;
  
  DatabaseStatistics({
    required this.totalImages,
    required this.featureDimension,
    required this.animalsByType,
    required this.topBreeds,
    required this.databaseSizeMB,
  });
  
  factory DatabaseStatistics.fromJson(Map<String, dynamic> json) {
    final stats = json['statistics'] ?? {};
    
    return DatabaseStatistics(
      totalImages: stats['total_images'] ?? 0,
      featureDimension: stats['feature_dimension'] ?? 0,
      animalsByType: Map<String, int>.from(stats['animals_by_type'] ?? {}),
      topBreeds: Map<String, int>.from(stats['top_breeds'] ?? {}),
      databaseSizeMB: (stats['database_size_mb'] ?? 0.0).toDouble(),
    );
  }
}