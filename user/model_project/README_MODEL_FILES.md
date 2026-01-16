# 📦 AI Model Files - Setup Instructions

## ⚠️ Important Note
ملفات AI Model (`.keras`, `.pkl`) **غير موجودة** في Git لأنها كبيرة جداً (8-9 MB لكل ملف).

## 🔧 Setup Instructions

### 1. إنشاء Virtual Environment:
```bash
cd user/model_project
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# أو
venv\Scripts\activate  # Windows
```

### 2. تثبيت Dependencies:
```bash
pip install -r requirements.txt
```

### 3. الحصول على Model Files:
يجب أن تكون ملفات AI Model موجودة محلياً:
- `saved_models/final_model.keras` (8.3 MB)
- `animal_features_db.pkl` (8.5 MB)

إذا لم تكن موجودة، يجب الحصول عليها من:
- Developer الذي درب النموذج
- أو من مكان آخر (Google Drive, etc.)

### 4. تشغيل Flask Server:
```bash
source venv/bin/activate
python api_server.py
```

## 📝 Files Ignored by Git:
- `venv/` - Python virtual environment
- `*.pkl` - AI feature database
- `*.keras` - Trained AI models
- `__pycache__/` - Python cache files

## 💡 Alternative: Git LFS
إذا أردت مشاركة ملفات AI Model عبر Git، استخدم **Git LFS**:
```bash
git lfs install
git lfs track "*.keras"
git lfs track "*.pkl"
git add .gitattributes
```
