# 🚀 تحديث سريع للمشروع الموجود

## للشريك المربوط من قبل:

```bash
# 1. تحديث الكود
cd PatiWorld  # أو المسار الذي clone فيه المشروع
git pull origin main

# 2. تحميل ملفات AI Model (جديدة اليوم)
git lfs pull

# 3. تحديث Flutter dependencies (إذا لزم)
cd user
flutter pub get

# 4. إذا كان venv موجود، فعّله. إذا لا، أنشئه:
cd ../model_project
source venv/bin/activate  # إذا موجود
# أو
python3 -m venv venv && source venv/bin/activate  # إذا جديد
pip install -r requirements.txt

# 5. شغّل Flask Server
python api_server.py
```

## ✅ التحقق من أن كل شيء يعمل:

```bash
# تحقق من وجود ملفات AI Model
ls -lh user/model_project/saved_models/*.keras
ls -lh user/model_project/*.pkl

# تحقق من Flask Server
curl http://127.0.0.1:5001/api/v1/health
```

## 📝 ملاحظات:

- **Git LFS** مثبت تلقائياً مع Git - لا حاجة لتثبيت إضافي
- ملفات AI Model (26 MB) موجودة الآن على GitHub ✅
- Port الافتراضي: **5001** (لأن 5000 مستخدم من AirPlay على macOS)
