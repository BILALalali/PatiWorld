"""
Flask API Server for Animal Similarity Matching
Connects AI Model with Flutter App and Supabase
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import cv2
import pickle
import os
from pathlib import Path
from tensorflow import keras
from sklearn.metrics.pairwise import cosine_similarity
import base64
from io import BytesIO
from PIL import Image
import requests
from supabase import create_client, Client
import json

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Configuration
MODEL_PATH = 'saved_models/final_model.keras'
DB_PATH = 'animal_features_db.pkl'
IMG_SIZE = (224, 224)

# Supabase Configuration (Update with your credentials)
SUPABASE_URL = 'https://xtysfxxrkwzemkasrxfl.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0eXNmeHhya3d6ZW1rYXNyeGZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2Mjk1MTMsImV4cCI6MjA3NjIwNTUxM30.JpmTTuwIqWIo5gWIjSFpU04qrOA2d2gMY-MUMF3DuKQ'

# Global variables
model = None
database = None
supabase: Client = None

def load_model():
    """Load the trained model"""
    global model
    if model is None:
        print("Loading AI model...")
        model = keras.models.load_model(MODEL_PATH, compile=False)
        print("✅ Model loaded successfully")
    return model

def load_database():
    """Load the features database"""
    global database
    if database is None:
        print("Loading features database...")
        with open(DB_PATH, 'rb') as f:
            database = pickle.load(f)
        print(f"✅ Database loaded: {len(database)} images")
    return database

def init_supabase():
    """Initialize Supabase client"""
    global supabase
    if supabase is None:
        supabase = create_client(SUPABASE_URL, SUPABASE_KEY)
        print("✅ Supabase client initialized")
    return supabase

def preprocess_image(image_data):
    """Preprocess image for model input"""
    # Convert base64 or bytes to numpy array
    if isinstance(image_data, str):
        # Base64 string
        image_bytes = base64.b64decode(image_data)
        image = Image.open(BytesIO(image_bytes))
        img_array = np.array(image)
    else:
        # Bytes or numpy array
        if isinstance(image_data, bytes):
            image = Image.open(BytesIO(image_data))
            img_array = np.array(image)
        else:
            img_array = image_data
    
    # Convert to RGB if needed
    if len(img_array.shape) == 2:
        img_array = cv2.cvtColor(img_array, cv2.COLOR_GRAY2RGB)
    elif img_array.shape[2] == 4:
        img_array = cv2.cvtColor(img_array, cv2.COLOR_RGBA2RGB)
    
    # Resize
    img_array = cv2.resize(img_array, IMG_SIZE)
    
    # Normalize
    img_array = img_array.astype(np.float32) / 255.0
    
    return img_array

def extract_features(image_data):
    """Extract features from image using the model"""
    model = load_model()
    img = preprocess_image(image_data)
    img_batch = np.expand_dims(img, axis=0)
    
    # Get features (feature_vector output)
    predictions = model.predict(img_batch, verbose=0)
    features = predictions[1][0]  # feature_vector output
    
    # Normalize
    features = features / (np.linalg.norm(features) + 1e-10)
    
    return features

def find_similar_in_database(query_features, top_k=10, threshold=0.6):
    """Find similar images in the database"""
    database = load_database()
    
    similarities = []
    for item in database:
        db_features = np.array(item['features'])
        sim = cosine_similarity([query_features], [db_features])[0][0]
        
        if sim >= threshold:
            similarities.append((sim, item))
    
    # Sort by similarity
    similarities.sort(key=lambda x: x[0], reverse=True)
    
    # Get top K results
    results = []
    for i, (sim, item) in enumerate(similarities[:top_k]):
        confidence = "ÇOK YÜKSEK" if sim > 0.9 else \
                   "YÜKSEK" if sim > 0.8 else \
                   "ORTA" if sim > 0.7 else \
                   "DÜŞÜK"
        
        results.append({
            'id': i + 1,
            'animal_type': item.get('animal_type', 'unknown'),
            'breed': item.get('breed', 'unknown'),
            'similarity': float(sim),
            'confidence': confidence,
            'match_quality': 'EXCELLENT' if sim > 0.85 else 'GOOD' if sim > 0.75 else 'FAIR',
            'image_name': item.get('file_name', ''),
            'image_path': item.get('path', ''),
            'score_percentage': f"{sim * 100:.1f}%"
        })
    
    return results

def map_to_supabase_lost_pets(ai_results, animal_type, breed, city):
    """Map AI results to Supabase lost_pets records"""
    supabase = init_supabase()
    
    # Get all lost pets from Supabase
    try:
        response = supabase.table('lost_pets').select('*').eq('is_active', True).execute()
        lost_pets = response.data if response.data else []
    except Exception as e:
        print(f"Error fetching lost pets: {e}")
        return []
    
    # Create mapping: breed -> lost_pets
    matched_pets = []
    
    for ai_result in ai_results:
        ai_breed = ai_result['breed'].lower()
        ai_type = ai_result['animal_type'].lower()
        
        # Map AI types to Turkish types
        type_mapping = {
            'cats': 'Kedi',
            'dogs': 'Köpek',
            'birds': 'Kuş'
        }
        turkish_type = type_mapping.get(ai_type, ai_type)
        
        # Find matching lost pets
        for pet in lost_pets:
            pet_type = pet.get('type', '').lower()
            pet_description = pet.get('description', '').lower()
            
            # Type must match
            if pet_type != turkish_type.lower():
                continue
            
            # Check if breed matches in description
            breed_match = False
            if ai_breed in pet_description or any(word in pet_description for word in ai_breed.split('_')):
                breed_match = True
            
            # If type matches and breed matches, add to results
            if breed_match:
                # Calculate combined score
                base_score = ai_result['similarity']
                
                # Boost score if breed matches exactly
                if breed and breed.lower() in pet_description:
                    base_score += 0.1
                
                # Boost score if city matches
                if city and pet.get('city', '').lower() == city.lower():
                    base_score += 0.05
                
                base_score = min(1.0, base_score)  # Cap at 1.0
                
                matched_pets.append({
                    'lost_pet_id': pet.get('id'),
                    'name': pet.get('name', ''),
                    'type': pet.get('type', ''),
                    'description': pet.get('description', ''),
                    'city': pet.get('city', ''),
                    'image_url': pet.get('image_url'),
                    'contact_number': pet.get('contact_number', ''),
                    'whatsapp_number': pet.get('whatsapp_number', ''),
                    'ai_similarity': base_score,
                    'ai_confidence': ai_result['confidence'],
                    'ai_breed': ai_result['breed'],
                    'match_reason': 'AI Image Match'
                })
    
    # Remove duplicates and sort by similarity
    seen_ids = set()
    unique_pets = []
    for pet in matched_pets:
        if pet['lost_pet_id'] not in seen_ids:
            seen_ids.add(pet['lost_pet_id'])
            unique_pets.append(pet)
    
    unique_pets.sort(key=lambda x: x['ai_similarity'], reverse=True)
    
    return unique_pets[:10]  # Return top 10

@app.route('/api/v1/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'success': True,
        'message': 'API is running',
        'model_loaded': model is not None,
        'database_loaded': database is not None
    })

@app.route('/api/v1/search', methods=['POST'])
def search_similar():
    """Search for similar animals"""
    try:
        # Get image from request
        if 'image' not in request.files:
            return jsonify({
                'success': False,
                'error': 'No image provided'
            }), 400
        
        image_file = request.files['image']
        if image_file.filename == '':
            return jsonify({
                'success': False,
                'error': 'Empty image file'
            }), 400
        
        # Read image
        image_bytes = image_file.read()
        
        # Get optional parameters
        top_k = int(request.form.get('top_k', 10))
        threshold = float(request.form.get('threshold', 0.6))
        animal_type = request.form.get('animal_type', '')
        breed = request.form.get('breed', '')
        city = request.form.get('city', '')
        
        # Extract features
        query_features = extract_features(image_bytes)
        
        # Find similar in database
        ai_results = find_similar_in_database(query_features, top_k=top_k, threshold=threshold)
        
        # Map to Supabase lost_pets if type/breed/city provided
        supabase_results = []
        if animal_type and breed:
            supabase_results = map_to_supabase_lost_pets(ai_results, animal_type, breed, city)
        
        return jsonify({
            'success': True,
            'matches': ai_results,
            'supabase_matches': supabase_results,
            'total_ai_matches': len(ai_results),
            'total_supabase_matches': len(supabase_results)
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/v1/stats', methods=['GET'])
def get_statistics():
    """Get database statistics"""
    try:
        database = load_database()
        
        # Count by type
        animals_by_type = {}
        top_breeds = {}
        
        for item in database:
            animal_type = item.get('animal_type', 'unknown')
            breed = item.get('breed', 'unknown')
            
            animals_by_type[animal_type] = animals_by_type.get(animal_type, 0) + 1
            top_breeds[breed] = top_breeds.get(breed, 0) + 1
        
        # Calculate database size
        db_size_mb = os.path.getsize(DB_PATH) / (1024 * 1024)
        
        return jsonify({
            'success': True,
            'statistics': {
                'total_images': len(database),
                'feature_dimension': len(database[0]['features']) if database else 0,
                'animals_by_type': animals_by_type,
                'top_breeds': dict(sorted(top_breeds.items(), key=lambda x: x[1], reverse=True)[:10]),
                'database_size_mb': round(db_size_mb, 2)
            }
        })
        
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    print("🚀 Starting Animal Similarity API Server...")
    print("📦 Loading model and database...")
    
    # Pre-load model and database
    load_model()
    load_database()
    init_supabase()
    
    print("✅ Server ready!")
    print("🌐 API running on http://localhost:5001")
    print("   (Port 5001 used because 5000 is often taken by AirPlay on macOS)")
    print("📡 Endpoints:")
    print("   - GET  /api/v1/health")
    print("   - POST /api/v1/search")
    print("   - GET  /api/v1/stats")
    
    # Run server
    # Note: Port 5000 is often used by AirPlay on macOS, so we use 5001
    app.run(host='0.0.0.0', port=5001, debug=True)
