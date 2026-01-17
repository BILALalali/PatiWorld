"""
Flask API Server for Animal Similarity Matching
Connects AI Model with Flutter App and Supabase
Updated to use new TFLite classification model
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import numpy as np
import cv2
import pickle
import os
import tensorflow as tf
from io import BytesIO
from PIL import Image
from supabase import create_client, Client

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

# Configuration - Updated for new TFLite model
TFLITE_MODEL_PATH = 'saved_models/pet_image_classifier.tflite'
DB_PATH = 'animal_features_db.pkl'
IMG_SIZE = (256, 256)  # Updated to match new model input size

# Pet breed class names (37 classes from the new model)
CLASS_NAMES = [
    "Abyssinian", "Bengal", "Birman", "Bombay", "British Shorthair",
    "Egyptian Mau", "Maine Coon", "Persian", "Ragdoll", "Russian Blue",
    "Siamese", "Sphynx", "american bulldog", "american pit bull terrier",
    "basset hound", "beagle", "boxer", "chihuahua", "english cocker spaniel",
    "english setter", "german shorthaired", "great pyrenees", "havanese",
    "japanese chin", "keeshond", "leonberger", "miniature pinscher",
    "newfoundland", "pomeranian", "pug", "saint bernard", "samoyed",
    "scottish terrier", "shiba inu", "staffordshire bull terrier",
    "wheaten terrier", "yorkshire terrier"
]

# Map breeds to animal types
BREED_TO_TYPE = {
    # Cats (0-11)
    "abyssinian": "cats", "bengal": "cats", "birman": "cats", "bombay": "cats",
    "british shorthair": "cats", "egyptian mau": "cats", "maine coon": "cats",
    "persian": "cats", "ragdoll": "cats", "russian blue": "cats",
    "siamese": "cats", "sphynx": "cats",
    # Dogs (12-36)
    "american bulldog": "dogs", "american pit bull terrier": "dogs",
    "basset hound": "dogs", "beagle": "dogs", "boxer": "dogs",
    "chihuahua": "dogs", "english cocker spaniel": "dogs",
    "english setter": "dogs", "german shorthaired": "dogs",
    "great pyrenees": "dogs", "havanese": "dogs", "japanese chin": "dogs",
    "keeshond": "dogs", "leonberger": "dogs", "miniature pinscher": "dogs",
    "newfoundland": "dogs", "pomeranian": "dogs", "pug": "dogs",
    "saint bernard": "dogs", "samoyed": "dogs", "scottish terrier": "dogs",
    "shiba inu": "dogs", "staffordshire bull terrier": "dogs",
    "wheaten terrier": "dogs", "yorkshire terrier": "dogs"
}

# Supabase Configuration (Update with your credentials)
SUPABASE_URL = 'https://xtysfxxrkwzemkasrxfl.supabase.co'
SUPABASE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh0eXNmeHhya3d6ZW1rYXNyeGZsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2Mjk1MTMsImV4cCI6MjA3NjIwNTUxM30.JpmTTuwIqWIo5gWIjSFpU04qrOA2d2gMY-MUMF3DuKQ'

# Global variables
interpreter = None
input_details = None
output_details = None
database = None
supabase: Client = None

def load_model():
    """Load the TFLite model"""
    global interpreter, input_details, output_details
    if interpreter is None:
        print("Loading TFLite model...")
        try:
            interpreter = tf.lite.Interpreter(model_path=TFLITE_MODEL_PATH)
            interpreter.allocate_tensors()
            input_details = interpreter.get_input_details()
            output_details = interpreter.get_output_details()
            print("✅ TFLite model loaded successfully")
            print(f"   Input shape: {input_details[0]['shape']}")
            print(f"   Output shape: {output_details[0]['shape']}")
        except Exception as e:
            print(f"❌ Error loading TFLite model: {e}")
            raise
    return interpreter

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
    """Preprocess image for TFLite model input (256x256)"""
    # Convert bytes to PIL Image
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
    
    # Resize to 256x256 (new model requirement)
    img_array = cv2.resize(img_array, IMG_SIZE)
    
    # Normalize to [0, 1]
    img_array = img_array.astype(np.float32) / 255.0
    
    return img_array

def classify_image(image_data):
    """Classify image using the TFLite model"""
    interpreter = load_model()
    img = preprocess_image(image_data)
    img_batch = np.expand_dims(img, axis=0)
    
    # Ensure correct dtype
    input_dtype = input_details[0]['dtype']
    if input_dtype == np.float32:
        img_batch = img_batch.astype(np.float32)
    else:
        img_batch = img_batch.astype(input_dtype)
    
    # Set input tensor
    interpreter.set_tensor(input_details[0]['index'], img_batch)
    
    # Run inference
    interpreter.invoke()
    
    # Get predictions
    predictions = interpreter.get_tensor(output_details[0]['index'])[0]
    
    # Get top predictions
    top_indices = np.argsort(predictions)[::-1][:5]  # Top 5
    
    results = []
    for idx in top_indices:
        breed = CLASS_NAMES[idx]
        confidence = float(predictions[idx])
        animal_type = BREED_TO_TYPE.get(breed.lower(), "unknown")
        
        results.append({
            'breed': breed,
            'animal_type': animal_type,
            'confidence': confidence,
            'class_index': int(idx)
        })
    
    return results

def find_similar_by_classification(classification_results, top_k=10, threshold=0.3):
    """Find similar images based on classification results"""
    database = load_database()
    
    # Extract top predicted breed
    if not classification_results:
        return []
    
    top_result = classification_results[0]
    predicted_breed = top_result['breed'].lower()
    predicted_type = top_result['animal_type']
    confidence = top_result['confidence']
    
    # Find matches in database
    matches = []
    for item in database:
        db_breed = item.get('breed', '').lower()
        db_type = item.get('animal_type', '').lower()
        
        # Check if breed matches (fuzzy matching)
        breed_match = False
        if predicted_breed in db_breed or db_breed in predicted_breed:
            breed_match = True
        elif any(word in db_breed for word in predicted_breed.split() if len(word) > 3):
            breed_match = True
        
        # Check type match
        type_match = (predicted_type.lower() == db_type)
        
        if breed_match and type_match:
            # Calculate similarity score based on confidence
            similarity = confidence * 0.8  # Base score from model confidence
            if predicted_breed == db_breed:
                similarity = min(1.0, similarity + 0.2)  # Exact match bonus
            
            if similarity >= threshold:
                matches.append((similarity, item))
    
    # Sort by similarity
    matches.sort(key=lambda x: x[0], reverse=True)
    
    # Format results
    results = []
    for i, (sim, item) in enumerate(matches[:top_k]):
        conf_level = "ÇOK YÜKSEK" if sim > 0.9 else \
                    "YÜKSEK" if sim > 0.8 else \
                    "ORTA" if sim > 0.7 else \
                    "DÜŞÜK"
        
        results.append({
            'id': i + 1,
            'animal_type': item.get('animal_type', 'unknown'),
            'breed': item.get('breed', 'unknown'),
            'similarity': float(sim),
            'confidence': conf_level,
            'match_quality': 'EXCELLENT' if sim > 0.85 else 'GOOD' if sim > 0.75 else 'FAIR',
            'image_name': item.get('file_name', ''),
            'image_path': item.get('path', ''),
            'score_percentage': f"{sim * 100:.1f}%"
        })
    
    return results

def map_to_supabase_lost_pets(classification_results, ai_results, animal_type, breed, city):
    """Map AI classification results to Supabase lost_pets records"""
    supabase = init_supabase()
    
    # Get all lost pets from Supabase
    try:
        response = supabase.table('lost_pets').select('*').eq('is_active', True).execute()
        lost_pets = response.data if response.data else []
    except Exception as e:
        print(f"Error fetching lost pets: {e}")
        return []
    
    # Get top classification result
    if not classification_results:
        return []
    
    top_classification = classification_results[0]
    predicted_breed = top_classification['breed'].lower()
    predicted_type = top_classification['animal_type'].lower()
    model_confidence = top_classification['confidence']
    
    # Map AI types to Turkish types
    type_mapping = {
        'cats': 'Kedi',
        'dogs': 'Köpek',
        'birds': 'Kuş'
    }
    
    # **الأولوية للمستخدم**: استخدم animal_type من المستخدم إذا كان موجوداً
    # إذا لم يكن موجوداً، استخدم تصنيف النموذج
    if animal_type and animal_type.strip():
        # المستخدم حدد النوع يدوياً - استخدمه
        user_type = animal_type.strip()
        
        # تحويل من الإنجليزية إلى التركية إذا لزم الأمر
        # التطبيق يرسل 'cats'/'dogs' لكن السيرفر يحتاج 'Kedi'/'Köpek'
        reverse_mapping = {
            'cats': 'Kedi',
            'dogs': 'Köpek',
            'birds': 'Kuş',
            'cat': 'Kedi',
            'dog': 'Köpek',
            'bird': 'Kuş'
        }
        
        # إذا كان بالإنجليزية، حوّله للتركية
        if user_type.lower() in reverse_mapping:
            turkish_type = reverse_mapping[user_type.lower()]
            print(f"✅ Converted user type '{user_type}' → '{turkish_type}'")
        else:
            # إذا كان بالفعل بالتركية، استخدمه كما هو
            turkish_type = user_type
            print(f"✅ Using user-specified type: {turkish_type}")
    else:
        # لم يحدد المستخدم النوع - استخدم تصنيف النموذج
        turkish_type = type_mapping.get(predicted_type, predicted_type.capitalize())
        print(f"⚠️  No user type specified, using model prediction: {turkish_type}")
    
    matched_pets = []
    
    # Find matching lost pets
    for pet in lost_pets:
        pet_type = pet.get('type', '').lower()
        pet_description = pet.get('description', '').lower()
        pet_breed = breed.lower() if breed else ''
        
        # **الأولوية للمستخدم**: Type must match user's selection or model prediction
        if pet_type != turkish_type.lower():
            continue
        
        # Check breed match (multiple strategies)
        breed_match_score = 0.0
        
        # Strategy 1: Exact breed match in description
        if predicted_breed in pet_description:
            breed_match_score = 0.9
        # Strategy 2: User-provided breed matches
        elif pet_breed and pet_breed in pet_description:
            breed_match_score = 0.8
        # Strategy 3: Partial breed match
        elif any(word in pet_description for word in predicted_breed.split() if len(word) > 3):
            breed_match_score = 0.6
        # Strategy 4: Check all classification results
        else:
            for cls_result in classification_results[:3]:  # Check top 3
                cls_breed = cls_result['breed'].lower()
                if cls_breed in pet_description:
                    breed_match_score = max(breed_match_score, cls_result['confidence'] * 0.7)
        
        # If breed matches, add to results
        if breed_match_score > 0.3:
            # Calculate combined score
            base_score = model_confidence * 0.6 + breed_match_score * 0.4
            
            # Boost score if city matches
            if city and pet.get('city', '').lower() == city.lower():
                base_score = min(1.0, base_score + 0.1)
            
            # Determine confidence level
            if base_score > 0.85:
                confidence_level = "ÇOK YÜKSEK"
            elif base_score > 0.75:
                confidence_level = "YÜKSEK"
            elif base_score > 0.65:
                confidence_level = "ORTA"
            else:
                confidence_level = "DÜŞÜK"
            
            matched_pets.append({
                'lost_pet_id': pet.get('id'),
                'name': pet.get('name', ''),
                'type': pet.get('type', ''),
                'description': pet.get('description', ''),
                'city': pet.get('city', ''),
                'image_url': pet.get('image_url'),
                'contact_number': pet.get('contact_number', ''),
                'whatsapp_number': pet.get('whatsapp_number', ''),
                'ai_similarity': round(base_score, 3),
                'ai_confidence': confidence_level,
                'ai_breed': top_classification['breed'],
                'match_reason': f'AI Classification Match ({top_classification["breed"]})'
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
        'model_loaded': interpreter is not None,
        'database_loaded': database is not None,
        'model_type': 'TFLite Classification Model',
        'input_size': IMG_SIZE
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
        animal_type = request.form.get('animal_type', '').strip()
        breed = request.form.get('breed', '').strip()
        city = request.form.get('city', '').strip()
        
        # Log received parameters
        print(f"📥 Received parameters:")
        print(f"   animal_type: '{animal_type}'")
        print(f"   breed: '{breed}'")
        print(f"   city: '{city}'")
        
        # Classify image using new TFLite model
        classification_results = classify_image(image_bytes)
        
        # Log classification results
        if classification_results:
            top_result = classification_results[0]
            print(f"🤖 Model predicted: {top_result['breed']} ({top_result['animal_type']}) - {top_result['confidence']*100:.2f}%")
        
        # Find similar in database based on classification
        ai_results = find_similar_by_classification(classification_results, top_k=top_k, threshold=threshold)
        
        # Map to Supabase lost_pets - **الأولوية للمستخدم في تحديد النوع**
        supabase_results = []
        if classification_results:
            supabase_results = map_to_supabase_lost_pets(
                classification_results, ai_results, animal_type, breed, city
            )
            print(f"✅ Found {len(supabase_results)} matching lost pets")
        
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
                'animals_by_type': animals_by_type,
                'top_breeds': dict(sorted(top_breeds.items(), key=lambda x: x[1], reverse=True)[:10]),
                'database_size_mb': round(db_size_mb, 2),
                'model_type': 'TFLite Classification',
                'supported_classes': len(CLASS_NAMES)
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
    try:
        load_model()
    except Exception as e:
        print(f"❌ Failed to load model: {e}")
        print("   Make sure pet_image_classifier.tflite is in saved_models/ folder")
        exit(1)
    
    try:
        load_database()
    except Exception as e:
        print(f"⚠️  Database not loaded (optional): {e}")
        print("   API will work with classification only")
    
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
