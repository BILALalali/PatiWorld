"""
HIZLI ÖZELLİK ÇIKARMA MODÜLÜ
Tüm hatalar düzeltildi
"""

import numpy as np
import cv2
import pickle
import json
from pathlib import Path
from tqdm import tqdm
import os

class FastFeatureExtractor:
    def __init__(self, model_path='saved_models/final_model.keras'):
        """Özellik çıkarıcıyı başlat"""
        from tensorflow import keras
        
        print(f"📦 Model yükleniyor: {model_path}")
        self.model = keras.models.load_model(model_path, compile=False)
        self.IMG_SIZE = (224, 224)
        self.feature_dim = 256
        
        # Modeli optimize et
        self._optimize_model()
    
    def _optimize_model(self):
        """Modeli özellik çıkarma için optimize et"""
        # Predict fonksiyonunu ön yükle
        try:
            self.model.predict(np.zeros((1, *self.IMG_SIZE, 3)), verbose=0)
            print("✅ Model optimize edildi")
        except:
            print("⚠ Optimizasyon atlandı")
    
    def preprocess_image_fast(self, image_path):
        """Hızlı görüntü ön işleme"""
        try:
            # Görüntüyü yükle
            img = cv2.imread(str(image_path))
            if img is None:
                return None
            
            # Hızlı boyutlandırma
            img = cv2.resize(img, self.IMG_SIZE, interpolation=cv2.INTER_AREA)
            
            # RGB'ye çevir ve normalize et
            img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
            img = img.astype(np.float32) / 255.0
            
            return img
        except Exception as e:
            return None
    
    def extract_features_single(self, image_path):
        """Tek görüntüden özellik çıkar"""
        img = self.preprocess_image_fast(image_path)
        if img is None:
            return None
        
        try:
            # Özellikleri çıkar
            predictions = self.model.predict(np.expand_dims(img, axis=0), verbose=0)
            features = predictions[1][0]  # feature_vector çıkışı
            
            # Normalize et
            norm = np.linalg.norm(features)
            if norm > 0:
                features = features / norm
            
            return features
        except:
            return None
    
    def extract_batch_fast(self, image_paths, batch_size=32):
        """Toplu özellik çıkarma (hızlı)"""
        features_list = []
        valid_paths = []
        
        for i in tqdm(range(0, len(image_paths), batch_size), 
                     desc="Toplu işleme", 
                     unit="batch"):
            batch_paths = image_paths[i:i+batch_size]
            batch_images = []
            
            # Batch hazırla
            for path in batch_paths:
                img = self.preprocess_image_fast(path)
                if img is not None:
                    batch_images.append(img)
                    valid_paths.append(path)
            
            if batch_images:
                try:
                    batch_array = np.array(batch_images)
                    
                    # Batch prediction
                    predictions = self.model.predict(batch_array, verbose=0)
                    batch_features = predictions[1]  # feature_vector çıkışları
                    
                    # Normalize et
                    norms = np.linalg.norm(batch_features, axis=1, keepdims=True)
                    norms = np.where(norms == 0, 1e-10, norms)
                    batch_features = batch_features / norms
                    
                    features_list.extend(batch_features)
                    
                except Exception as e:
                    print(f"⚠ Prediction hatası: {e}")
                    continue
        
        return valid_paths, np.array(features_list)
    
    def extract_from_directory_fast(self, dataset_path='dataset'):
        """Tüm dizinden hızlı özellik çıkar"""
        print(f"🔍 Dizin taranıyor: {dataset_path}")
        
        # Tüm görüntü dosyalarını bul
        image_extensions = ['.jpg', '.jpeg', '.png', '.JPG', '.JPEG', '.PNG']
        image_paths = []
        
        for root, dirs, files in os.walk(dataset_path):
            for file in files:
                if any(file.lower().endswith(ext.lower()) for ext in image_extensions):
                    image_paths.append(os.path.join(root, file))
        
        print(f"📸 {len(image_paths)} görüntü bulundu")
        
        if not image_paths:
            print("❌ Hiç görüntü bulunamadı!")
            return []
        
        # Özellikleri çıkar
        valid_paths, features = self.extract_batch_fast(image_paths, batch_size=32)
        
        # Veritabanını oluştur
        database = []
        for i, (path, feature) in enumerate(zip(valid_paths, features)):
            try:
                # Meta verileri çıkar
                rel_path = os.path.relpath(path, dataset_path)
                parts = Path(rel_path).parts
                
                if len(parts) >= 2:
                    animal_type = parts[0]
                    breed = parts[1]
                else:
                    animal_type = "unknown"
                    breed = "unknown"
                
                database.append({
                    'id': i,
                    'path': str(path),
                    'features': feature.tolist(),
                    'animal_type': animal_type,
                    'breed': breed,
                    'file_name': os.path.basename(path),
                    'feature_dim': self.feature_dim
                })
            except Exception as e:
                continue
        
        print(f"✅ {len(database)} görüntü işlendi")
        return database
    
    def save_database(self, database, output_path='animal_features_db.pkl'):
        """Veritabanını kaydet"""
        if not database:
            print("❌ Kaydedilecek veri yok!")
            return
        
        # Pickle formatında kaydet
        with open(output_path, 'wb') as f:
            pickle.dump(database, f, protocol=pickle.HIGHEST_PROTOCOL)
        
        # JSON formatında da kaydet
        json_path = output_path.replace('.pkl', '.json')
        json_data = []
        
        for item in database:
            json_data.append({
                'id': item['id'],
                'animal_type': item['animal_type'],
                'breed': item['breed'],
                'file_name': item['file_name'],
                'path': item['path']
            })
        
        with open(json_path, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Veritabanı kaydedildi:")
        print(f"   - {output_path} ({len(database)} kayıt)")
        print(f"   - {json_path} (JSON format)")

def main():
    """Ana fonksiyon"""
    print("=" * 60)
    print("🚀 HIZLI ÖZELLİK ÇIKARMA")
    print("=" * 60)
    
    try:
        # Extractor oluştur
        extractor = FastFeatureExtractor()
        
        # Özellikleri çıkar
        database = extractor.extract_from_directory_fast()
        
        if database:
            # Kaydet
            extractor.save_database(database)
            
            print("\n" + "=" * 60)
            print("✅ ÖZELLİK ÇIKARMA TAMAMLANDI")
            print("=" * 60)
        else:
            print("\n❌ Veritabanı oluşturulamadı!")
            
    except Exception as e:
        print(f"\n❌ Hata: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()