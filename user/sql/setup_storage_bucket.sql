-- إنشاء Storage Bucket لصور الملف الشخصي
-- قم بتشغيل هذا الكود في Supabase SQL Editor

-- 1. إنشاء Storage Bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO NOTHING;

-- 2. حذف السياسات الموجودة (إذا كانت موجودة)
DROP POLICY IF EXISTS "Users can upload their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can update their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete their own profile images" ON storage.objects;
DROP POLICY IF EXISTS "Profile images are publicly readable" ON storage.objects;

-- 3. إنشاء السياسات الجديدة
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

-- 4. التحقق من إنشاء الـ Bucket
SELECT * FROM storage.buckets WHERE id = 'profile-images';
