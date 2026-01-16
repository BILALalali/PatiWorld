import 'dart:io';
import '../models/lost_pet.dart';
import '../models/found_pet.dart';
import 'lost_pet_service.dart';
import 'animal_similarity_api.dart';

/// AI Matching Service for finding similar lost pets based on found pet information
/// Combines AI image matching with text-based matching
class AIMatchingService {
  /// Find similar lost pets based on found pet criteria
  /// This service matches based on:
  /// - Animal type (exact match)
  /// - Breed (fuzzy match - checks if breed appears in description)
  /// - City (proximity match - same city gets higher priority)
  /// - Image similarity (AI model comparison)
  static Future<List<LostPet>> findSimilarLostPets({
    required String type,
    required String breed,
    required String city,
    String? imageUrl,
    File? imageFile,
    int limit = 5,
  }) async {
    try {
      List<LostPet> aiMatchedPets = [];
      Map<String, double> aiScores = {}; // Map of pet ID to AI similarity score

      // Step 1: Try AI image matching if image file is provided
      if (imageFile != null && await imageFile.exists()) {
        try {
          print('🤖 Starting AI image matching...');
          // Map Turkish types to English for API
          final typeMapping = {
            'Kedi': 'cats',
            'Köpek': 'dogs',
            'Kuş': 'birds',
          };
          final englishType = typeMapping[type] ?? type.toLowerCase();
          print('📤 Sending image to AI API: type=$englishType, breed=$breed, city=$city');

          // Call AI API
          final apiResponse = await AnimalSimilarityAPI.searchSimilarImage(
            imageFile,
            topK: 20,
            threshold: 0.6,
            animalType: englishType,
            breed: breed,
            city: city,
          );
          
          print('📥 AI API response: success=${apiResponse.success}, status=${apiResponse.statusCode}');

          if (apiResponse.success && apiResponse.data != null) {
            final supabaseMatches = apiResponse.data['supabase_matches'] as List?;
            
            if (supabaseMatches != null && supabaseMatches.isNotEmpty) {
              print('✅ AI found ${supabaseMatches.length} matches from Supabase');
              // Convert Supabase matches to LostPet objects
              for (final matchData in supabaseMatches) {
                try {
                  final match = SupabaseAnimalMatch.fromJson(matchData);
                  
                  // Get full LostPet from database
                  final lostPet = await LostPetService.getLostPetById(match.lostPetId);
                  if (lostPet != null) {
                    aiMatchedPets.add(lostPet);
                    aiScores[lostPet.id] = match.aiSimilarity;
                    print('✅ Added AI match: ${lostPet.name} (similarity: ${match.aiSimilarity})');
                  } else {
                    print('⚠️ LostPet not found for ID: ${match.lostPetId}');
                  }
                } catch (e) {
                  print('⚠️ Error parsing match: $e');
                }
              }
            } else {
              print('ℹ️ No Supabase matches from AI (but AI search succeeded)');
            }
          } else {
            print('⚠️ AI API response not successful: ${apiResponse.error}');
          }
        } catch (e, stackTrace) {
          print('❌ AI matching error (falling back to text matching): $e');
          print('Stack trace: $stackTrace');
          // Continue with text-based matching if AI fails
        }
      }

      // Step 2: Text-based matching (always runs as fallback or supplement)
      final allLostPets = await LostPetService.getAllLostPets();
      final scoredPets = <({LostPet pet, double score})>[];

      for (final lostPet in allLostPets) {
        // Skip if already matched by AI
        if (aiScores.containsKey(lostPet.id)) {
          continue;
        }

        double score = 0.0;

        // 1. Type match (exact match = 40 points)
        if (lostPet.type.toLowerCase() == type.toLowerCase()) {
          score += 40.0;
        } else {
          continue;
        }

        // 2. Breed match (fuzzy match = 30 points)
        final breedLower = breed.toLowerCase();
        final descriptionLower = lostPet.description.toLowerCase();
        
        if (descriptionLower.contains(breedLower)) {
          score += 30.0;
        } else {
          final breedWords = breedLower.split(' ');
          int matchingWords = 0;
          for (final word in breedWords) {
            if (word.length > 3 && descriptionLower.contains(word)) {
              matchingWords++;
            }
          }
          if (matchingWords > 0) {
            score += (matchingWords / breedWords.length) * 20.0;
          }
        }

        // 3. City match (exact match = 20 points)
        if (lostPet.city.toLowerCase() == city.toLowerCase()) {
          score += 20.0;
        } else {
          score += 5.0;
        }

        // 4. Image bonus
        if (imageUrl != null && lostPet.imageUrl != null) {
          score += 10.0;
        }

        if (score >= 30.0) {
          scoredPets.add((pet: lostPet, score: score));
        }
      }

      // Step 3: Combine and sort results
      // AI matches get priority (higher weight)
      final combinedResults = <LostPet>[];
      
      // Add AI matches first (sorted by AI similarity)
      aiMatchedPets.sort((a, b) {
        final scoreA = aiScores[a.id] ?? 0.0;
        final scoreB = aiScores[b.id] ?? 0.0;
        return scoreB.compareTo(scoreA);
      });
      combinedResults.addAll(aiMatchedPets);

      // Add text-based matches (sorted by text score)
      scoredPets.sort((a, b) => b.score.compareTo(a.score));
      for (final scored in scoredPets) {
        if (!combinedResults.any((pet) => pet.id == scored.pet.id)) {
          combinedResults.add(scored.pet);
        }
      }

      // Return top N results
      return combinedResults.take(limit).toList();
    } catch (e) {
      print('Error finding similar lost pets: $e');
      return [];
    }
  }

  /// Find similar lost pets based on found pet object
  static Future<List<LostPet>> findSimilarLostPetsFromFoundPet({
    required FoundPet foundPet,
    File? imageFile,
    int limit = 5,
  }) async {
    return findSimilarLostPets(
      type: foundPet.type,
      breed: foundPet.breed,
      city: foundPet.city,
      imageUrl: foundPet.imageUrl,
      imageFile: imageFile,
      limit: limit,
    );
  }

  /// Calculate similarity score between two pets (0.0 to 1.0)
  static double calculateSimilarityScore({
    required String type1,
    required String breed1,
    required String city1,
    required String type2,
    required String description2,
    required String city2,
  }) {
    double score = 0.0;
    double maxScore = 100.0;

    // Type match (40%)
    if (type1.toLowerCase() == type2.toLowerCase()) {
      score += 40.0;
    }

    // Breed match (30%)
    final breedLower = breed1.toLowerCase();
    final descriptionLower = description2.toLowerCase();
    if (descriptionLower.contains(breedLower)) {
      score += 30.0;
    } else {
      final breedWords = breedLower.split(' ');
      int matchingWords = 0;
      for (final word in breedWords) {
        if (word.length > 3 && descriptionLower.contains(word)) {
          matchingWords++;
        }
      }
      if (matchingWords > 0) {
        score += (matchingWords / breedWords.length) * 30.0;
      }
    }

    // City match (20%)
    if (city1.toLowerCase() == city2.toLowerCase()) {
      score += 20.0;
    } else {
      score += 5.0;
    }

    // Image bonus (10%)
    score += 10.0;

    return (score / maxScore).clamp(0.0, 1.0);
  }
}
