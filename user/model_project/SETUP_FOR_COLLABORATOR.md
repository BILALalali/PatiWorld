# 🚀 Setup Instructions for Collaborators

## ✅ AI Model Files

ملفات AI Model **موجودة على GitHub** باستخدام Git LFS (Large File Storage). سيتم تحميلها تلقائياً عند `git clone` أو `git pull`.

## 📋 خطوات الإعداد:

### 1. تحديث المشروع (إذا كنت مربوط من قبل):
```bash
cd PatiWorld  # أو المسار الذي clone فيه المشروع
git pull origin main
git lfs pull  # لتحميل ملفات AI Model الكبيرة
```

**أو إذا كان أول مرة:**
```bash
git clone https://github.com/BILALalali/PatiWorld.git
cd PatiWorld
git lfs pull  # لتحميل ملفات AI Model الكبيرة
```

### 2. Setup Flutter App:
```bash
cd user
flutter pub get
```

### 3. Setup AI Model Server:

#### أ. إنشاء Virtual Environment:
```bash
cd model_project
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# أو
venv\Scripts\activate  # Windows
```

#### ب. تثبيت Dependencies:
```bash
pip install -r requirements.txt
```

#### ج. Model Files:
الملفات موجودة على GitHub (باستخدام Git LFS):
- `saved_models/final_model.keras` (~8.3 MB) ✅
- `saved_models/best_model.keras` (~8.3 MB) ✅
- `animal_features_db.pkl` (~8.5 MB) ✅

**ملاحظة:** بعد `git pull`، تأكد من تحميل ملفات LFS:
```bash
git lfs pull
```

**للتحقق من وجود الملفات:**
```bash
ls -lh user/model_project/saved_models/*.keras
ls -lh user/model_project/*.pkl
```

#### د. إعداد Supabase:
تأكد من وجود متغيرات البيئة في `api_server.py`:
- `SUPABASE_URL`
- `SUPABASE_KEY`

### 4. تشغيل Flask API Server:
```bash
cd user/model_project
source venv/bin/activate
python api_server.py
```

سترى:
```
🌐 API running on http://localhost:5001
```

### 5. تشغيل Flutter App:
```bash
cd user
flutter run
```

## ✅ التحقق من أن كل شيء يعمل:

1. **Flask Server Health Check:**
```bash
curl http://127.0.0.1:5001/api/v1/health
```

يجب أن ترى:
```json
{"success": true, "message": "API is running", ...}
```

2. **في Flutter App:**
- افتح "Bulunan Hayvan Ekle"
- اختر صورة + النوع + الفصيلة
- يجب أن ترى قسم "Kayıp Hayvanlar (Benzer veya Yakın)" مع نتائج AI

## 🔧 Troubleshooting:

### Port 5001 مستخدم؟
غيّر Port في `api_server.py`:
```python
app.run(host='0.0.0.0', port=5002, debug=True)
```

وتأكد من تحديث `animal_similarity_api.dart` أيضاً.

### Model Files غير موجودة؟
التطبيق سيعمل لكن AI matching لن يعمل. سيستخدم text-based matching فقط.

## 📝 Notes:

- `venv/` غير موجود في Git (يجب إنشاؤه محلياً)
- ملفات AI Model موجودة على GitHub باستخدام **Git LFS** ✅
- Port الافتراضي: **5001** (لأن 5000 مستخدم من AirPlay على macOS)
- **Git LFS** مثبت تلقائياً مع Git - لا حاجة لتثبيت إضافي
