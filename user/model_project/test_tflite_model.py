"""
اختبار نموذج TFLite - Test TFLite Model
تشغيل النموذج على صورة اختبار
"""

import tensorflow as tf
import numpy as np
from PIL import Image
import cv2
import os
import sys

# إعدادات النموذج
MODEL_PATH = 'saved_models/pet_image_classifier.tflite'
IMG_SIZE = (256, 256)

# أسماء السلالات (37 class)
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

def preprocess_image(image_path):
    """معالجة الصورة للنموذج"""
    # قراءة الصورة
    img = cv2.imread(image_path)
    if img is None:
        raise ValueError(f"لا يمكن قراءة الصورة: {image_path}")
    
    # تحويل BGR إلى RGB
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    
    # تغيير الحجم إلى 256x256
    img = cv2.resize(img, IMG_SIZE)
    
    # تطبيع [0, 1]
    img = img.astype(np.float32) / 255.0
    
    # إضافة batch dimension
    img_batch = np.expand_dims(img, axis=0)
    
    return img_batch

def predict_image(image_path):
    """تصنيف صورة باستخدام النموذج"""
    print("=" * 60)
    print("🤖 تشغيل نموذج TFLite")
    print("=" * 60)
    print()
    
    # 1. تحميل النموذج
    print(f"📦 تحميل النموذج: {MODEL_PATH}")
    if not os.path.exists(MODEL_PATH):
        print(f"❌ خطأ: النموذج غير موجود في {MODEL_PATH}")
        return
    
    interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
    interpreter.allocate_tensors()
    
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    print(f"✅ النموذج محمّل بنجاح")
    print(f"   Input shape: {input_details[0]['shape']}")
    print(f"   Output shape: {output_details[0]['shape']}")
    print()
    
    # 2. معالجة الصورة
    print(f"🖼️  معالجة الصورة: {image_path}")
    try:
        img_batch = preprocess_image(image_path)
        print(f"✅ الصورة معالجة: {img_batch.shape}")
        print()
    except Exception as e:
        print(f"❌ خطأ في معالجة الصورة: {e}")
        return
    
    # 3. تشغيل النموذج
    print("🚀 تشغيل النموذج...")
    interpreter.set_tensor(input_details[0]['index'], img_batch)
    interpreter.invoke()
    
    # 4. الحصول على النتائج
    predictions = interpreter.get_tensor(output_details[0]['index'])[0]
    
    # 5. عرض أفضل 5 نتائج
    top_indices = np.argsort(predictions)[::-1][:5]
    
    print()
    print("=" * 60)
    print("📊 النتائج - Top 5 Predictions")
    print("=" * 60)
    print()
    
    for i, idx in enumerate(top_indices, 1):
        breed = CLASS_NAMES[idx]
        confidence = float(predictions[idx])
        percentage = confidence * 100
        
        # تحديد نوع الحيوان
        animal_type = "🐱 قط" if idx < 12 else "🐶 كلب"
        
        # شريط التقدم
        bar_length = 30
        filled = int(bar_length * confidence)
        bar = "█" * filled + "░" * (bar_length - filled)
        
        print(f"{i}. {breed:30s} {animal_type}")
        print(f"   الثقة: {percentage:6.2f}% [{bar}]")
        print()
    
    # أفضل نتيجة
    best_idx = top_indices[0]
    best_breed = CLASS_NAMES[best_idx]
    best_confidence = float(predictions[best_idx])
    
    print("=" * 60)
    print(f"🏆 أفضل نتيجة: {best_breed}")
    print(f"   الثقة: {best_confidence * 100:.2f}%")
    print("=" * 60)
    print()

if __name__ == "__main__":
    # البحث عن صورة للاختبار
    test_images_dir = "test_images"
    
    if len(sys.argv) > 1:
        # استخدام الصورة المحددة
        image_path = sys.argv[1]
    elif os.path.exists(test_images_dir):
        # البحث عن أي صورة في مجلد الاختبار
        images = [f for f in os.listdir(test_images_dir) 
                 if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
        if images:
            image_path = os.path.join(test_images_dir, images[0])
        else:
            print("❌ لا توجد صور في مجلد test_images")
            print("   الاستخدام: python test_tflite_model.py <path_to_image>")
            sys.exit(1)
    else:
        print("❌ يرجى تحديد مسار الصورة")
        print("   الاستخدام: python test_tflite_model.py <path_to_image>")
        sys.exit(1)
    
    # تشغيل التصنيف
    predict_image(image_path)
