"""
🎯 KOD: HAYVAN BENZERLİK TEST ETME
Model'i test etmek için basit Python kodu
"""

import numpy as np
import cv2
import os
import json
from pathlib import Path
import matplotlib.pyplot as plt
from tensorflow import keras
from sklearn.metrics.pairwise import cosine_similarity

class AnimalSimilarityTester:
    def __init__(self, model_path='saved_models/final_model.keras', 
                 db_path='animal_features_db.pkl'):
        """Test sınıfını başlat"""
        print("🧪 Hayvan Benzerlik Test Aracı Yükleniyor...")
        
        # Modeli yükle
        self.model = keras.models.load_model(model_path, compile=False)
        self.IMG_SIZE = (224, 224)
        
        # Veritabanını yükle
        import pickle
        with open(db_path, 'rb') as f:
            self.database = pickle.load(f)
        
        print(f"✅ Model yüklendi: {len(self.database)} görüntü veritabanında")
    
    def preprocess_image(self, image_path):
        """Görüntüyü işle"""
        # Görüntüyü yükle
        img = cv2.imread(image_path)
        if img is None:
            raise ValueError(f"Görüntü yüklenemedi: {image_path}")
        
        # Boyutlandır
        img = cv2.resize(img, self.IMG_SIZE)
        
        # Renk düzenle
        img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
        
        # Normalize et
        img = img.astype(np.float32) / 255.0
        
        return img
    
    def extract_features(self, image_path):
        """Görüntüden özellik çıkar"""
        # Görüntüyü işle
        img = self.preprocess_image(image_path)
        
        # Batch oluştur
        img_batch = np.expand_dims(img, axis=0)
        
        # Özellikleri çıkar (sadece feature_vector çıkışını al)
        predictions = self.model.predict(img_batch, verbose=0)
        features = predictions[1][0]  # feature_vector çıkışı
        
        # Normalize et
        features = features / (np.linalg.norm(features) + 1e-10)
        
        return features
    
    def find_similar(self, image_path, top_k=5):
        """Benzer görüntüleri bul"""
        print(f"\n🔍 Arama yapılıyor: {Path(image_path).name}")
        
        # Özellikleri çıkar
        query_features = self.extract_features(image_path)
        
        # Tüm veritabanı ile karşılaştır
        similarities = []
        for item in self.database:
            db_features = np.array(item['features'])
            
            # Cosine benzerliği hesapla
            sim = cosine_similarity([query_features], [db_features])[0][0]
            similarities.append((sim, item))
        
        # En yüksek benzerlikleri sırala
        similarities.sort(key=lambda x: x[0], reverse=True)
        
        # En iyi sonuçları al
        results = []
        for i in range(min(top_k, len(similarities))):
            sim, item = similarities[i]
            results.append({
                'rank': i + 1,
                'similarity': float(sim),
                'animal_type': item['animal_type'],
                'breed': item['breed'],
                'file_name': item['file_name'],
                'path': item['path']
            })
        
        return results
    
    def display_results(self, image_path, results):
        """Sonuçları görselleştir"""
        # Orijinal görüntüyü yükle
        original_img = cv2.imread(image_path)
        original_img = cv2.cvtColor(original_img, cv2.COLOR_BGR2RGB)
        
        # En iyi 4 sonucu al
        top_results = results[:4]
        
        # Görsel oluştur
        fig, axes = plt.subplots(2, 3, figsize=(15, 10))
        
        # Orijinal görüntü
        axes[0, 0].imshow(original_img)
        axes[0, 0].set_title(f'ORİJİNAL\n{Path(image_path).name}')
        axes[0, 0].axis('off')
        
        # Benzer görüntüler
        for i, result in enumerate(top_results, 1):
            row = i // 2
            col = (i % 2) + 1
            
            # Benzer görüntüyü yükle
            similar_img = cv2.imread(result['path'])
            similar_img = cv2.cvtColor(similar_img, cv2.COLOR_BGR2RGB)
            
            # Görüntüyü göster
            axes[row, col].imshow(similar_img)
            axes[row, col].set_title(
                f'#{result["rank"]}: {result["breed"]}\n'
                f'Benzerlik: {result["similarity"]:.2%}'
            )
            axes[row, col].axis('off')
        
        # Boş kalan yer
        if len(top_results) < 4:
            axes[1, 2].axis('off')
        
        plt.suptitle('HAYVAN BENZERLİK SONUÇLARI', fontsize=16, fontweight='bold')
        plt.tight_layout()
        plt.show()
    
    def print_results(self, results):
        """Sonuçları terminalde yazdır"""
        print("\n" + "=" * 60)
        print("🏆 EN İYİ BENZERLİK SONUÇLARI")
        print("=" * 60)
        
        for result in results:
            confidence = "ÇOK YÜKSEK" if result['similarity'] > 0.9 else \
                        "YÜKSEK" if result['similarity'] > 0.8 else \
                        "ORTA" if result['similarity'] > 0.7 else \
                        "DÜŞÜK"
            
            print(f"\n{result['rank']}. {result['breed'].upper()}")
            print(f"   🐾 Tür: {result['animal_type']}")
            print(f"   📊 Benzerlik: {result['similarity']:.2%}")
            print(f"   ✅ Güven: {confidence}")
            print(f"   📁 Dosya: {result['file_name']}")
        
        print("=" * 60)

def test_single_image():
    """Tek bir görüntü ile test"""
    # Test ediciyi başlat
    tester = AnimalSimilarityTester()
    
    # Test görüntüsünü seç
    test_images = [
        "1.jpg",  # Kendi görüntünüzü buraya koyun
        "2.jpg",
        "3.jpg",
        "4.jpg",
        "5.jpg",
        "6.jpg"
    ]
    
    # Mevcut test görüntülerini bul
    available_images = []
    for img in test_images:
        if os.path.exists(img):
            available_images.append(img)
    
    if not available_images:
        print("❌ Hiç test görüntüsü bulunamadı!")
        print("ℹ Lütfen proje klasörüne test görüntüleri ekleyin:")
        for img in test_images:
            print(f"   - {img}")
        return
    
    # İlk mevcut görüntüyü test et
    test_image = available_images[0]
    
    # Benzerlik arama
    results = tester.find_similar(test_image, top_k=5)
    
    # Sonuçları yazdır
    tester.print_results(results)
    
    # Görsel sonuçları göster
    try:
        tester.display_results(test_image, results)
    except:
        print("⚠ Görsel gösterim hatası, sadece terminal çıktısı veriliyor.")

def test_multiple_images():
    """Birden fazla görüntü ile test"""
    tester = AnimalSimilarityTester()
    
    # Test görüntüleri dizini
    test_dir = "test_images"
    
    if not os.path.exists(test_dir):
        print(f"❌ Test dizini bulunamadı: {test_dir}")
        print(f"ℹ Lütfen '{test_dir}' klasörü oluşturun ve içine test görüntüleri koyun.")
        return
    
    # Tüm test görüntülerini bul
    test_images = []
    for ext in ['.jpg', '.jpeg', '.png', '.JPG', '.JPEG', '.PNG']:
        test_images.extend(Path(test_dir).glob(f'*{ext}'))
    
    if not test_images:
        print(f"❌ '{test_dir}' klasöründe hiç görüntü bulunamadı!")
        return
    
    print(f"📁 {len(test_images)} test görüntüsü bulundu")
    
    # Her görüntüyü test et
    for i, img_path in enumerate(test_images, 1):
        print(f"\n{'='*50}")
        print(f"📸 TEST {i}/{len(test_images)}: {img_path.name}")
        print(f"{'='*50}")
        
        try:
            # Benzerlik arama
            results = tester.find_similar(str(img_path), top_k=3)
            
            # Sonuçları yazdır
            for result in results:
                print(f"  #{result['rank']}: {result['breed']} "
                      f"({result['similarity']:.2%})")
            
            # En iyi sonucu göster
            if results:
                best = results[0]
                print(f"  🏆 EN İYİ: {best['breed']} - {best['similarity']:.2%}")
        
        except Exception as e:
            print(f"  ❌ Hata: {e}")

def quick_test():
    """Hızlı test (sadece terminal çıktısı)"""
    print("⚡ HIZLI TEST MODU")
    
    # Test ediciyi başlat
    tester = AnimalSimilarityTester()
    
    # Kullanıcıdan görüntü yolu al
    while True:
        image_path = input("\n🖼️  Test edilecek görüntü yolunu girin (çıkmak için 'q'): ").strip()
        
        if image_path.lower() == 'q':
            print("👋 Çıkılıyor...")
            break
        
        if not os.path.exists(image_path):
            print(f"❌ Görüntü bulunamadı: {image_path}")
            continue
        
        try:
            # Benzerlik arama
            results = tester.find_similar(image_path, top_k=3)
            
            # Sonuçları göster
            print(f"\n📊 {Path(image_path).name} için sonuçlar:")
            print("-" * 40)
            
            for result in results:
                star_count = int(result['similarity'] * 10)
                stars = '★' * star_count + '☆' * (10 - star_count)
                
                print(f"{result['rank']}. {result['breed']}")
                print(f"   Benzerlik: {stars} {result['similarity']:.1%}")
                print(f"   Tür: {result['animal_type']}")
                print()
        
        except Exception as e:
            print(f"❌ Hata: {e}")

def main():
    """Ana menü"""
    print("=" * 60)
    print("🐾 HAYVAN BENZERLİK TEST ARACI")
    print("=" * 60)
    print("\nTest seçeneğini seçin:")
    print("1. Tek görüntü testi (görsel + terminal)")
    print("2. Çoklu görüntü testi (terminal)")
    print("3. Hızlı test (interaktif)")
    print("4. Çıkış")
    
    while True:
        choice = input("\nSeçiminiz (1-4): ").strip()
        
        if choice == '1':
            test_single_image()
            break
        elif choice == '2':
            test_multiple_images()
            break
        elif choice == '3':
            quick_test()
            break
        elif choice == '4':
            print("👋 Güle güle!")
            break
        else:
            print("❌ Geçersiz seçim!")

if __name__ == "__main__":
    main()