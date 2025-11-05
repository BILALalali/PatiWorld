# Scripts

## generate_admin_hash.dart

Script لإنتاج SHA-256 hash لكلمة مرور المشرف الافتراضي.

### الاستخدام

```bash
cd admin
dart run scripts/generate_admin_hash.dart
```

سيقوم السكريبت بإنتاج:
- SHA-256 hash لكلمة المرور `Sdra.2003`
- SQL statement جاهز لإضافة المشرف الافتراضي

### ملاحظات

1. قم بتشغيل السكريبت لإنتاج hash كلمة المرور
2. انسخ SQL statement الناتج
3. نفذه في Supabase SQL Editor لإضافة المشرف الافتراضي

