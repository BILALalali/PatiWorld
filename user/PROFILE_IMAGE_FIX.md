# إصلاح مشكلة صور الملف الشخصي 🖼️

## المشكلة الحالية
```
StorageException (message: Bucket not found, statusCode: 404, error: Bucket not found)
```

## الحلول المتاحة 🔧

### الحل الأول: إنشاء Storage Bucket يدوياً (الأسرع)

#### 1. اذهب إلى Supabase Dashboard
- افتح [supabase.com/dashboard](https://supabase.com/dashboard)
- اختر مشروعك
- اذهب إلى **Storage** في القائمة الجانبية

#### 2. إنشاء Bucket جديد
- اضغط **New Bucket**
- اسم الـ Bucket: `profile-images`
- اختر **Public bucket** ✅
- اضغط **Create bucket**

#### 3. إعداد السياسات
- اذهب إلى **SQL Editor**
- انسخ والصق هذا الكود:

```sql
-- إنشاء سياسات الأمان للصور
DROP POLICY IF EXISTS "Users can upload their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Profile images are publicly readable" ON storage.objects;

CREATE POLICY "Users can upload their own profile images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own profile images" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own profile images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Profile images are publicly readable" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-images');
```

### الحل الثاني: استخدام SQL Editor (شامل)

#### 1. اذهب إلى SQL Editor
- في Supabase Dashboard
- اذهب إلى **SQL Editor**

#### 2. شغل الكود الكامل
انسخ والصق هذا الكود:

```sql
-- إنشاء Storage Bucket لصور الملف الشخصي
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO NOTHING;

-- حذف السياسات الموجودة (إذا كانت موجودة)
DROP POLICY IF EXISTS "Users can upload their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Profile images are publicly readable" ON storage.objects;

-- إنشاء السياسات الجديدة
CREATE POLICY "Users can upload their own profile images" ON storage.objects
FOR INSERT WITH CHECK (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can update their own profile images" ON storage.objects
FOR UPDATE USING (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Users can delete their own profile images" ON storage.objects
FOR DELETE USING (
  bucket_id = 'profile-images' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

CREATE POLICY "Profile images are publicly readable" ON storage.objects
FOR SELECT USING (bucket_id = 'profile-images');

-- التحقق من إنشاء الـ Bucket
SELECT * FROM storage.buckets WHERE id = 'profile-images';
```

## التحسينات المضافة في الكود ✨

### 1. محاولة إنشاء Bucket تلقائياً
- إذا فشل الرفع، يحاول إنشاء الـ Bucket برمجياً
- إذا فشل الإنشاء، يعطي رسالة خطأ واضحة

### 2. معالجة أفضل للأخطاء
- رسائل خطأ واضحة باللغة التركية
- معالجة أخطاء مختلفة (404, 403, 413)
- تحذير من حجم الملف الكبير

### 3. إعدادات Bucket محسنة
- أنواع ملفات مسموحة: JPEG, PNG, GIF
- حد أقصى لحجم الملف: 5MB
- Bucket عام للقراءة

## اختبار الحل 🧪

### 1. بعد إنشاء الـ Bucket
- أعد تشغيل التطبيق
- اذهب إلى شاشة الملف الشخصي
- اضغط على زر القلم للتعديل
- اضغط على زر الكاميرا
- اختر "Galeriden Seç"
- اختر صورة
- اضغط "Kaydet"

### 2. إذا استمرت المشكلة
- تحقق من أن الـ Bucket موجود في Storage
- تحقق من أن السياسات تم إنشاؤها
- تأكد من أن المستخدم مسجل دخول

## استكشاف الأخطاء 🔍

### رسائل الخطأ المحسنة:
- ✅ "Storage bucket bulunamadı" - الـ bucket غير موجود
- ✅ "Yükleme izni yok" - مشكلة في الصلاحيات
- ✅ "Dosya çok büyük" - الملف كبير جداً
- ✅ "Resim yükleme hatası" - خطأ عام

### نصائح إضافية:
- تأكد من اتصال الإنترنت
- تحقق من صحة Supabase URL و API Key
- تأكد من أن Storage مفعل في المشروع

## الملفات المحدثة 📁

1. **`profile_screen.dart`** - تحسينات في رفع الصور
2. **`create_profile_images_bucket.sql`** - كود SQL للإعداد
3. **`PROFILE_IMAGE_FIX.md`** - هذا الملف

بعد تطبيق الحل، ستتمكن من رفع صور الملف الشخصي بنجاح! 🎉
