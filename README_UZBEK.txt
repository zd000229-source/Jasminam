JASMIN FINAL v2.0

Bu paket oldingi Flutter Demo o‘rniga Jasmin ilovasini beradi.

Kiritilgan:
- Ilova nomi: Jasmin
- Chat interfeysi
- AI ulanishi uchun OpenAI Responses API qo‘llab-quvvatlashi
- O‘zbek/Rus/Turk/English til tanlovi
- Mikrofon speech-to-text
- TTS ovozli javob
- Biometrik qulflash
- Secure storage
- Offline fallback
- Codemagic'da analyze + test + release APK
- Android app label: Jasmin

AI:
Sozlamalarda API tokenni kiriting. Endpoint bo‘sh qolsa, OpenAI Responses API ishlatiladi.
API tokenni ChatGPT'ga yoki boshqa odamga yubormang. Uni faqat ilovaning Settings bo‘limiga kiriting.
API ishlatish hisobingizda billing/limitlarga bog‘liq bo‘lishi mumkin.

BUILD:
1) GitHub repository rootida shu paketdagi fayllarni joylang/almashtiring:
   lib/main.dart
   pubspec.yaml
   codemagic.yaml
   patch_android.sh
   test/widget_test.dart
2) Commit changes.
3) Codemagic -> Start new build.
4) Analyze Dart code va Run tests bosqichlari yashil bo‘lishi kerak.
5) Artifacts -> app-release.apk.

MUHIM:
Men bu muhitda Flutter SDK o‘rnatilmagani sababli Codemagic buildini shu yerning o‘zida ishga tushirib tekshira olmadim. Shuning uchun “100% xatosiz” deb yolg‘on va’da bermayman. Konfiguratsiya Flutter stable va hozirgi pub.dev paket versiyalariga moslab tayyorlandi.

3D anime avatar:
Hozirgi paketda haqiqiy 3D anime model fayli yo‘q. Uni keyingi buildga huquqi sizga tegishli GLB/VRM model bilan qo‘shish mumkin. Hozirgi APK esa chat/AI/voice/biometric qismlariga tayyor.


YANGI V2.1 FUNKSIYALAR:
- 3D anime-uslubidagi Jasmin avatar assets/jasmin_avatar.glb ichida.
- 3D avatar ekrani: aylantirish va zoom.
- Telefon boshqaruvi: Wi-Fi, Bluetooth, mobil tarmoq, ovoz, ekran, batareya, joylashuv, bildirishnoma va asosiy Settings sahifalarini rasmiy Android intentlari orqali ochish.
- Android tizimi ilovalarga barcha sozlamalarni yashirincha almashtirishga ruxsat bermaydi; shuning uchun tugmalar tegishli rasmiy Settings sahifasini ochadi.
- 3D viewer uchun model_viewer_plus ishlatiladi; GLB model ilovaning assets papkasida lokal saqlanadi.
