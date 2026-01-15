import '../models/lost_pet.dart';
import '../models/found_pet.dart';
import 'lost_pet_service.dart';

/// AI Matching Service for finding similar lost pets based on found pet information
class AIMatchingService {
  /// Find similar lost pets based on found pet criteria
  /// This service matches based on:
  /// - Animal type (exact match)
  /// - Breed (fuzzy match - checks if breed appears in description)
  /// - City (proximity match - same city gets higher priority)
  /// - Image similarity (future: will use AI model for image comparison)
  static Future<List<LostPet>> findSimilarLostPets({
    required String type,
    required String breed,
    required String city,
    String? imageUrl,
    int limit = 5,
  }) async {
    try {
      // Get all active lost pets
      final allLostPets = await LostPetService.getAllLostPets();

      // Filter and score lost pets
      final scoredPets = <({LostPet pet, double score})>[];

      for (final lostPet in allLostPets) {
        double score = 0.0;

        // 1. Type match (exact match = 40 points)
        if (lostPet.type.toLowerCase() == type.toLowerCase()) {
          score += 40.0;
        } else {
          // Skip if type doesn't match at all
          continue;
        }

        // 2. Breed match (fuzzy match = 30 points)
        // Check if breed appears in description (case insensitive)
        final breedLower = breed.toLowerCase();
        final descriptionLower = lostPet.description.toLowerCase();
        
        if (descriptionLower.contains(breedLower)) {
          score += 30.0;
        } else {
          // Partial match (check for common breed keywords)
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

        // 3. City match (exact match = 20 points, nearby = 10 points)
        if (lostPet.city.toLowerCase() == city.toLowerCase()) {
          score += 20.0;
        } else {
          // Could add logic here for nearby cities
          // For now, we'll give a small score for different cities
          score += 5.0;
        }

        // 4. Image similarity (future: AI model comparison)
        // For now, if both have images, give a small bonus
        if (imageUrl != null && lostPet.imageUrl != null) {
          score += 10.0; // Placeholder for future AI image matching
        }

        // Only include pets with a minimum score
        if (score >= 30.0) {
          scoredPets.add((pet: lostPet, score: score));
        }
      }

      // Sort by score (highest first)
      scoredPets.sort((a, b) => b.score.compareTo(a.score));

      // Return top N results
      return scoredPets
          .take(limit)
          .map((scored) => scored.pet)
          .toList();
    } catch (e) {
      print('Error finding similar lost pets: $e');
      return [];
    }
  }

  /// Find similar lost pets based on found pet object
  static Future<List<LostPet>> findSimilarLostPetsFromFoundPet({
    required FoundPet foundPet,
    int limit = 5,
  }) async {
    return findSimilarLostPets(
      type: foundPet.type,
      breed: foundPet.breed,
      city: foundPet.city,
      imageUrl: foundPet.imageUrl,
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
