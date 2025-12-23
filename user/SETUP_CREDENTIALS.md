# 🔐 إعداد بيانات DialogFlow - Setup DialogFlow Credentials

## للمطورين الجدد - For New Developers

عند الانضمام للمشروع، ستحتاج إلى إعداد ملف بيانات DialogFlow. إليك الطرق الآمنة للحصول على الملف:

When joining the project, you'll need to set up the DialogFlow credentials file. Here are secure ways to get the file:

---

## ✅ الطريقة الموصى بها - Recommended Method

### 1. من قائد الفريق - From Team Lead

اطلب من قائد الفريق أو المطور الرئيسي إرسال ملف `dialog_flow_auth.json` عبر:

Ask the team lead or main developer to send the `dialog_flow_auth.json` file via:

- **Slack/Teams/WhatsApp** (مشفر - encrypted)
- **1Password / LastPass** (مدير كلمات مرور آمن)
- **Google Drive** (مشاركة خاصة - private share)
- **Email** (مشفر - encrypted email)

### 2. بعد الحصول على الملف - After Receiving the File

1. ضع الملف في المسار التالي:
   Place the file in the following path:
   ```
   user/assets/dialog_flow_auth.json
   ```

2. تأكد من أن الملف موجود:
   Verify the file exists:
   ```bash
   ls -la user/assets/dialog_flow_auth.json
   ```

3. **⚠️ مهم جداً:** تأكد من أن الملف موجود في `.gitignore`:
   **⚠️ Very Important:** Make sure the file is in `.gitignore`:
   ```bash
   git check-ignore user/assets/dialog_flow_auth.json
   ```
   
   يجب أن يظهر المسار. إذا لم يظهر، أضف الملف إلى `.gitignore`.

---

## 🔄 إنشاء بيانات جديدة - Creating New Credentials

إذا كنت بحاجة إلى إنشاء بيانات DialogFlow جديدة:

If you need to create new DialogFlow credentials:

### خطوات Google Cloud Console:

1. اذهب إلى [Google Cloud Console](https://console.cloud.google.com/)
2. اختر المشروع أو أنشئ مشروع جديد
3. اذهب إلى **IAM & Admin** > **Service Accounts**
4. اضغط **Create Service Account**
5. املأ التفاصيل:
   - **Name**: `patiworld-chatbot`
   - **Description**: `Service account for DialogFlow chatbot`
6. اضغط **Create and Continue**
7. في **Grant this service account access to project**:
   - اختر Role: **Dialogflow API Client**
8. اضغط **Done**
9. اضغط على Service Account الذي أنشأته
10. اذهب إلى **Keys** tab
11. اضغط **Add Key** > **Create new key**
12. اختر **JSON** format
13. سيتم تحميل الملف تلقائياً
14. انسخ الملف إلى `user/assets/dialog_flow_auth.json`

---

## 🛡️ أفضل الممارسات الأمنية - Security Best Practices

### ✅ افعل - Do:

- ✅ استخدم مدير كلمات مرور (1Password, LastPass)
- ✅ شارك الملف عبر قنوات مشفرة
- ✅ احذف الملف من أي مكان بعد نسخه
- ✅ استخدم `.gitignore` دائماً
- ✅ راجع `.gitignore` قبل كل commit

### ❌ لا تفعل - Don't:

- ❌ لا ترفع الملف إلى Git أبداً
- ❌ لا تشارك الملف عبر GitHub Issues أو Pull Requests
- ❌ لا تضع الملف في Slack العام أو قنوات عامة
- ❌ لا تلتقط screenshot للملف
- ❌ لا تنسخ الملف إلى مستودعات عامة

---

## 🚨 إذا تم رفع الملف بالخطأ - If File Was Accidentally Committed

إذا رفعت الملف بالخطأ إلى Git:

If you accidentally committed the file to Git:

1. **إزالة الملف من Git history:**
   ```bash
   git rm --cached user/assets/dialog_flow_auth.json
   git commit -m "Remove credentials file from Git"
   ```

2. **تأكد من وجوده في `.gitignore`:**
   ```bash
   echo "**/dialog_flow_auth.json" >> user/.gitignore
   git add user/.gitignore
   git commit -m "Add credentials to gitignore"
   ```

3. **إذا كان الملف في commits سابقة، استخدم:**
   ```bash
   git filter-branch --force --index-filter \
     "git rm --cached --ignore-unmatch user/assets/dialog_flow_auth.json" \
     --prune-empty --tag-name-filter cat -- --all
   ```

4. **⚠️ مهم:** بعد إزالة الملف من Git history:
   - **غيّر جميع المفاتيح فوراً** في Google Cloud Console
   - **احذف Service Account القديم** وأنشئ واحد جديد
   - **أبلغ الفريق** لتحديث بياناتهم

---

## 📝 ملاحظات إضافية - Additional Notes

- الملف `dialog_flow_auth.json.example` موجود في Git كقالب فقط
- الملف الحقيقي `dialog_flow_auth.json` يجب ألا يكون في Git أبداً
- كل مطور يحتاج نسخة محلية من الملف
- الملف يعمل محلياً فقط ولا يؤثر على التطبيق في الإنتاج

---

## ❓ أسئلة شائعة - FAQ

**س: هل يمكنني مشاركة الملف عبر GitHub?**
**Q: Can I share the file via GitHub?**

❌ **لا أبداً!** GitHub يفحص الملفات تلقائياً ويمنع رفع المفاتيح السرية.

❌ **Never!** GitHub automatically scans files and blocks secret keys.

---

**س: ماذا لو فقدت الملف?**
**Q: What if I lost the file?**

✅ اطلب نسخة جديدة من قائد الفريق أو أنشئ Service Account جديد.

✅ Ask for a new copy from the team lead or create a new Service Account.

---

**س: هل يمكن استخدام نفس الملف في الإنتاج?**
**Q: Can I use the same file in production?**

⚠️ **لا!** استخدم Service Account منفصل للإنتاج مع صلاحيات محدودة.

⚠️ **No!** Use a separate Service Account for production with limited permissions.

---

## 📞 للمساعدة - For Help

إذا واجهت أي مشكلة، تواصل مع:
If you encounter any issues, contact:

- قائد الفريق - Team Lead
- المطور الرئيسي - Main Developer
- DevOps Team

