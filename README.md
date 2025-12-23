# PatiWorld - عالم الحيوانات الأليفة

تطبيق شامل لإدارة الحيوانات الأليفة مبني بـ Flutter، يتكون من تطبيقين منفصلين: تطبيق المستخدمين وتطبيق الإدارة.

## 📱 التطبيقات

### تطبيق المستخدمين (user/)
- عرض وإدارة الحيوانات الأليفة
- إعلانات المفقودات والتبني
- جدول اللقاحات
- شات بوت ذكي باستخدام Dialogflow
- إدارة الملف الشخصي

### تطبيق الإدارة (admin/)
- لوحة تحكم شاملة
- إدارة المستخدمين والحيوانات
- التقارير والإحصائيات
- إعدادات النظام

## 🛠️ التقنيات

- **Flutter & Dart**: إطار العمل الرئيسي
- **Supabase**: قاعدة البيانات والخدمات الخلفية
- **Dialogflow**: شات بوت ذكي للتفاعل مع المستخدمين
- **Material Design 3**: تصميم الواجهات

## 📊 قاعدة البيانات

يستخدم التطبيق **Supabase** كقاعدة بيانات رئيسية مع الجداول التالية:
- `users`: المستخدمين
- `pets`: الحيوانات
- `lost_pets`: إعلانات المفقودات
- `adoption_pets`: إعلانات التبني
- `vaccinations`: جدول اللقاحات

## 🤖 شات بوت Dialogflow

التطبيق يتضمن شات بوت ذكي يستخدم **Google Dialogflow** لتقديم مساعدة فورية للمستخدمين والإجابة على استفساراتهم حول الحيوانات الأليفة.

## 📁 هيكل المشروع

```
pati_world/
├── user/           # تطبيق المستخدمين
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── assets/
├── admin/          # تطبيق الإدارة
│   ├── lib/
│   ├── android/
│   └── ios/
└── README.md
```

## 🚀 التشغيل

### تطبيق المستخدمين
```bash
cd user
flutter pub get
flutter run
```

### تطبيق الإدارة
```bash
cd admin
flutter pub get
flutter run
```

---

# PatiWorld - Pet World

A comprehensive pet management application built with Flutter, consisting of two separate apps: user app and admin app.

## 📱 Applications

### User App (user/)
- View and manage pets
- Lost and adoption listings
- Vaccination schedule
- Intelligent chatbot using Dialogflow
- Profile management

### Admin App (admin/)
- Comprehensive dashboard
- User and pet management
- Reports and statistics
- System settings

## 🛠️ Technologies

- **Flutter & Dart**: Main framework
- **Supabase**: Database and backend services
- **Dialogflow**: Intelligent chatbot for user interaction
- **Material Design 3**: UI design

## 📊 Database

The application uses **Supabase** as the main database with the following tables:
- `users`: Users
- `pets`: Pets
- `lost_pets`: Lost pet listings
- `adoption_pets`: Adoption listings
- `vaccinations`: Vaccination schedule

## 🤖 Dialogflow Chatbot

The application includes an intelligent chatbot using **Google Dialogflow** to provide instant assistance to users and answer their queries about pets.

## 📁 Project Structure

```
pati_world/
├── user/           # User application
│   ├── lib/
│   ├── android/
│   ├── ios/
│   └── assets/
├── admin/          # Admin application
│   ├── lib/
│   ├── android/
│   └── ios/
└── README.md
```

## 🚀 Running

### User App
```bash
cd user
flutter pub get
flutter run
```

### Admin App
```bash
cd admin
flutter pub get
flutter run
```
