# PatiWorld User App

تطبيق PatiWorld - تطبيق الرفق بالحيوان

## Getting Started

### Prerequisites

- Flutter SDK (3.8.1 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd pati_world/user
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure DialogFlow Credentials** 🔐
   
   **Important:** You need to set up DialogFlow credentials to use the chatbot feature.
   
   - Copy the example file:
     ```bash
     cp assets/dialog_flow_auth.json.example assets/dialog_flow_auth.json
     ```
   
   - Edit `assets/dialog_flow_auth.json` and replace the placeholder values with your actual Google Cloud Service Account credentials:
     - `project_id`: Your Google Cloud project ID
     - `private_key_id`: Your private key ID
     - `private_key`: Your private key (keep the `\n` characters)
     - `client_email`: Your service account email
     - `client_id`: Your client ID
   
   **⚠️ Security Note:** 
   - The file `dialog_flow_auth.json` is already in `.gitignore` and will NOT be committed to Git
   - Never share your credentials publicly
   - If you're working in a team, ask the team lead for the credentials file or use a secure password manager

4. **Run the app**
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── constants/      # App constants and configuration
├── models/         # Data models
├── screens/        # UI screens
├── services/       # Business logic and API services
├── widgets/        # Reusable widgets
└── utils/          # Utility functions
```

## Features

- 🐾 Pet management
- 💬 AI Chatbot (DialogFlow integration)
- 📍 Location services
- 🌍 Multi-language support (Arabic/Turkish)
- 🔐 User authentication

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [DialogFlow Documentation](https://cloud.google.com/dialogflow/docs)
- [Supabase Documentation](https://supabase.com/docs)

---

## إعدادات المشروع

### متطلبات التشغيل

- Flutter SDK (3.8.1 أو أحدث)
- Dart SDK
- Android Studio / VS Code مع إضافات Flutter

### تعليمات الإعداد

1. **استنساخ المستودع**
   ```bash
   git clone <repository-url>
   cd pati_world/user
   ```

2. **تثبيت المكتبات**
   ```bash
   flutter pub get
   ```

3. **إعداد بيانات DialogFlow** 🔐
   
   **مهم:** تحتاج إلى إعداد بيانات DialogFlow لاستخدام ميزة الشات بوت.
   
   - انسخ ملف المثال:
     ```bash
     cp assets/dialog_flow_auth.json.example assets/dialog_flow_auth.json
     ```
   
   - عدّل `assets/dialog_flow_auth.json` واستبدل القيم المؤقتة ببيانات Google Cloud Service Account الحقيقية:
     - `project_id`: معرف مشروع Google Cloud الخاص بك
     - `private_key_id`: معرف المفتاح الخاص
     - `private_key`: المفتاح الخاص (احتفظ بأحرف `\n`)
     - `client_email`: بريد حساب الخدمة
     - `client_id`: معرف العميل
   
   **⚠️ ملاحظة أمنية:** 
   - الملف `dialog_flow_auth.json` موجود في `.gitignore` ولن يُضاف إلى Git
   - لا تشارك بيانات الاعتماد علناً أبداً
   - إذا كنت تعمل مع فريق، اطلب ملف بيانات الاعتماد من قائد الفريق أو استخدم مدير كلمات مرور آمن

4. **تشغيل التطبيق**
   ```bash
   flutter run
   ```