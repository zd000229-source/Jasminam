
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:local_auth/local_auth.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JasminApp());
}

class JasminApp extends StatelessWidget {
  const JasminApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jasmin',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB98CFF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0A13),
      ),
      home: const LockGate(),
    );
  }
}

class LockGate extends StatefulWidget {
  const LockGate({super.key});
  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> {
  final _auth = LocalAuthentication();
  bool _checking = true;
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _checkLock();
  }

  Future<void> _checkLock() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('app_lock') ?? false;
    if (!enabled) {
      if (mounted) setState(() => _checking = false);
      return;
    }
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        if (mounted) setState(() => _checking = false);
        return;
      }
      final ok = await _auth.authenticate(
        localizedReason: 'Jasminni ochish uchun tasdiqlang',
      );
      if (mounted) {
        setState(() {
          _locked = !ok;
          _checking = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() {
        _locked = true;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_locked) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Jasmin qulflangan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _checking = true);
                  _checkLock();
                },
                icon: const Icon(Icons.fingerprint),
                label: const Text('Qayta ochish'),
              ),
            ],
          ),
        ),
      );
    }
    return const ChatPage();
  }
}

class ChatMessage {
  final String text;
  final bool fromUser;
  const ChatMessage(this.text, this.fromUser);
}


Future<void> openAndroidSetting(String action, {String? data}) async {
  try {
    await AndroidIntent(action: action, data: data).launch();
  } catch (_) {
    // Some Android versions/OEMs do not expose every settings page.
  }
}

class PhoneControlsPage extends StatelessWidget {
  const PhoneControlsPage({super.key});

  Widget _tile(BuildContext context, IconData icon, String title, String subtitle, String action, {String? data}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => openAndroidSetting(action, data: data),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Telefon boshqaruvi')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF211B2D),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Jasmin telefonni yashirincha yoki chetlab o‘tib boshqarmaydi. Android ruxsat bergan amallar uchun rasmiy tizim sozlamalarini ochadi. Shuning uchun xavfsiz va barqaror ishlaydi.',
                    style: TextStyle(height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          _tile(context, Icons.wifi, 'Wi‑Fi', 'Wi‑Fi sozlamalarini ochish', 'android.settings.WIFI_SETTINGS'),
          _tile(context, Icons.bluetooth, 'Bluetooth', 'Bluetooth sozlamalarini ochish', 'android.settings.BLUETOOTH_SETTINGS'),
          _tile(context, Icons.signal_cellular_alt, 'Mobil tarmoq', 'Mobil tarmoq sozlamalari', 'android.settings.WIRELESS_SETTINGS'),
          _tile(context, Icons.volume_up, 'Ovoz', 'Ovoz va vibratsiya sozlamalari', 'android.settings.SOUND_SETTINGS'),
          _tile(context, Icons.brightness_6, 'Ekran', 'Yorqinlik va ekran sozlamalari', 'android.settings.DISPLAY_SETTINGS'),
          _tile(context, Icons.battery_full, 'Batareya', 'Batareya va quvvat sozlamalari', 'android.settings.BATTERY_SAVER_SETTINGS'),
          _tile(context, Icons.location_on, 'Joylashuv', 'Joylashuv sozlamalari', 'android.settings.LOCATION_SOURCE_SETTINGS'),
          _tile(context, Icons.notifications, 'Bildirishnomalar', 'Bildirishnoma sozlamalari', 'android.settings.NOTIFICATION_SETTINGS'),
          _tile(context, Icons.settings, 'Barcha sozlamalar', 'Telefonning asosiy sozlamalari', 'android.settings.SETTINGS'),
          _tile(context, Icons.phone_android, 'Jasmin ilovasi', 'Ilova ruxsatlari va tizim ma’lumotlari', 'android.settings.APPLICATION_DETAILS_SETTINGS', data: 'package:com.jasmin.ai'),
        ],
      ),
    );
  }
}

class AvatarPage extends StatelessWidget {
  const AvatarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jasmin 3D avatar')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFF16121F),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const ModelViewer(
                src: 'assets/jasmin_avatar.glb',
                alt: 'Jasmin 3D anime-inspired avatar',
                autoRotate: true,
                cameraControls: true,
                disableZoom: false,
                backgroundColor: Color(0xFF16121F),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Text(
              'Ekranda barmoq bilan aylantir, ikki barmoq bilan boshqar. Avatar model telefonning o‘zida saqlanadi.',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _secure = const FlutterSecureStorage();
  final _speech = stt.SpeechToText();
  final _tts = FlutterTts();

  final List<ChatMessage> _messages = const [
    ChatMessage(
      'Salom! Men Jasmin 🌸\nMen sening shaxsiy yordamchingman. '
      'Savolingni yoz yoki mikrofonni bos.',
      false,
    ),
  ].toList();

  String _locale = 'uz-UZ';
  bool _busy = false;
  bool _listening = false;
  bool _speakReplies = false;

  @override
  void initState() {
    super.initState();
    _tts.setSpeechRate(0.48);
    _tts.setPitch(1.05);
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    Future<void>.delayed(const Duration(milliseconds: 80), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _offlineReply(String text) {
    final t = text.toLowerCase();
    if (t.contains('salom') || t.contains('hello') || t.contains('привет')) {
      return 'Salom 😊 Men Jasminman. Hozir offline rejimdaman.';
    }
    if (t.contains('isming') || t.contains('kim san')) {
      return 'Mening ismim Jasmin 🌸';
    }
    if (t.contains('rahmat') || t.contains('thanks')) {
      return 'Arzimaydi 😊';
    }
    return 'Xabaringni oldim. Haqiqiy AI javoblari uchun Sozlamalarda AI server yoki API ulanishini sozlash kerak.';
  }

  String? _phoneCommandAction(String text) {
    final t = text.toLowerCase().trim();
    if ((t.contains('wifi') || t.contains('wi-fi') || t.contains('вайфай')) &&
        (t.contains('och') || t.contains('yoq') || t.contains('sozlama') || t.contains('settings') || t.contains('настрой'))) {
      return 'android.settings.WIFI_SETTINGS';
    }
    if (t.contains('bluetooth') &&
        (t.contains('och') || t.contains('sozlama') || t.contains('settings') || t.contains('настрой'))) {
      return 'android.settings.BLUETOOTH_SETTINGS';
    }
    if ((t.contains('ovoz') || t.contains('sound') || t.contains('звук') || t.contains('ses')) &&
        (t.contains('och') || t.contains('sozlama') || t.contains('settings') || t.contains('настрой'))) {
      return 'android.settings.SOUND_SETTINGS';
    }
    if ((t.contains('ekran') || t.contains('display') || t.contains('экран')) &&
        (t.contains('och') || t.contains('sozlama') || t.contains('settings') || t.contains('настрой'))) {
      return 'android.settings.DISPLAY_SETTINGS';
    }
    if ((t.contains('batareya') || t.contains('battery') || t.contains('батар')) &&
        (t.contains('och') || t.contains('sozlama') || t.contains('settings') || t.contains('настрой'))) {
      return 'android.settings.BATTERY_SAVER_SETTINGS';
    }
    if ((t.contains('telefon sozlama') || t.contains('phone settings') || t.contains('настройки телефона') || t == 'sozlamalar') &&
        !t.contains('wifi') && !t.contains('bluetooth')) {
      return 'android.settings.SETTINGS';
    }
    return null;
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;

    setState(() {
      _messages.add(ChatMessage(text, true));
      _input.clear();
      _busy = true;
    });
    _scrollDown();

    final phoneAction = _phoneCommandAction(text);
    if (phoneAction != null) {
      await openAndroidSetting(phoneAction);
      const reply = 'Mayli 😊 Telefon sozlamasini ochdim.';
      if (!mounted) return;
      setState(() {
        _messages.add(const ChatMessage(reply, false));
        _busy = false;
      });
      _scrollDown();
      if (_speakReplies) {
        await _tts.setLanguage(_locale);
        await _tts.speak(reply);
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final configuredEndpoint = prefs.getString('endpoint')?.trim() ?? '';
    final endpoint = configuredEndpoint.isEmpty
        ? 'https://api.openai.com/v1/responses'
        : configuredEndpoint;
    final token = await _secure.read(key: 'api_token') ?? '';

    String reply;
    if (token.isEmpty) {
      reply = _offlineReply(text);
    } else {
      try {
        final history = _messages.length > 12
            ? _messages.sublist(_messages.length - 12)
            : _messages;
        final input = history.map((m) => {
          'role': m.fromUser ? 'user' : 'assistant',
          'content': m.text,
        }).toList();

        final response = await http.post(
          Uri.parse(endpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'model': 'gpt-6-luna',
            'instructions':
                'You are Jasmin, a friendly, polite, cheerful personal AI assistant. '
                'Reply in the user language. Be helpful and natural. '
                'Do not claim to be human. Keep the tone warm and playful without romantic roleplay.',
            'input': input,
          }),
        );
        if (response.statusCode >= 200 && response.statusCode < 300) {
          final data = jsonDecode(response.body);
          String? textOut = data['output_text']?.toString();
          if (textOut == null || textOut.isEmpty) {
            final output = data['output'];
            if (output is List) {
              final parts = <String>[];
              for (final item in output) {
                if (item is Map && item['content'] is List) {
                  for (final part in item['content']) {
                    if (part is Map && part['type'] == 'output_text') {
                      final value = part['text'];
                      if (value != null) parts.add(value.toString());
                    }
                  }
                }
              }
              textOut = parts.join('\n').trim();
            }
          }
          reply = (textOut == null || textOut.isEmpty)
              ? 'AI javob qaytarmadi.'
              : textOut;
        } else {
          reply = 'AI server xatosi: HTTP ${response.statusCode}.';
        }
      } catch (_) {
        reply = 'AI ga ulanishda xatolik. Internet va tokenni tekshir.';
      }
    }

    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(reply, false));
      _busy = false;
    });
    _scrollDown();

    if (_speakReplies) {
      await _tts.setLanguage(_locale);
      await _tts.speak(reply);
    }
  }

  Future<void> _toggleMic() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    final initialized = await _speech.initialize(
      onStatus: (status) {
        if (mounted && status == 'done') {
          setState(() => _listening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _listening = false);
      },
    );
    if (!initialized) return;

    setState(() => _listening = true);
    await _speech.listen(
      localeId: _locale,
      onResult: (result) {
        if (mounted) setState(() => _input.text = result.recognizedWords);
      },
    );
  }

  Future<void> _settings() async {
    final prefs = await SharedPreferences.getInstance();
    final endpoint = TextEditingController(
      text: prefs.getString('endpoint') ?? '',
    );
    final token = TextEditingController(
      text: await _secure.read(key: 'api_token') ?? '',
    );
    bool lock = prefs.getBool('app_lock') ?? false;
    bool speak = prefs.getBool('speak_replies') ?? false;
    String lang = _locale;

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                18, 18, 18,
                MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Jasmin sozlamalari',
                      style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: lang,
                      decoration: const InputDecoration(labelText: 'Til'),
                      items: const [
                        DropdownMenuItem(value: 'uz-UZ', child: Text('O‘zbekcha')),
                        DropdownMenuItem(value: 'ru-RU', child: Text('Русский')),
                        DropdownMenuItem(value: 'tr-TR', child: Text('Türkçe')),
                        DropdownMenuItem(value: 'en-US', child: Text('English')),
                      ],
                      onChanged: (value) {
                        if (value != null) setLocal(() => lang = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: endpoint,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'AI server URL',
                        hintText: 'https://example.com/chat',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: token,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'API token',
                      ),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Biometrik qulflash'),
                      subtitle: const Text('Telefon biometrik himoyasidan foydalanadi'),
                      value: lock,
                      onChanged: (value) => setLocal(() => lock = value),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Javoblarni ovoz chiqarib o‘qish'),
                      value: speak,
                      onChanged: (value) => setLocal(() => speak = value),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () async {
                          await prefs.setString('endpoint', endpoint.text.trim());
                          await _secure.write(
                            key: 'api_token',
                            value: token.text.trim(),
                          );
                          await prefs.setBool('app_lock', lock);
                          await prefs.setBool('speak_replies', speak);
                          if (mounted) {
                            setState(() {
                              _locale = lang;
                              _speakReplies = speak;
                            });
                          }
                          if (sheetContext.mounted) Navigator.pop(sheetContext);
                        },
                        child: const Text('Saqlash'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'API tokenni APK ichiga qotirib qo‘ymadik. U telefonning secure storage tizimida saqlanadi. Eng xavfsiz variant — o‘zingizning backend serveringiz orqali AI API chaqirish.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(child: Icon(Icons.auto_awesome)),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Jasmin', style: TextStyle(fontWeight: FontWeight.w800)),
                Text('Personal AI assistant', style: TextStyle(fontSize: 11)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '3D Jasmin',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AvatarPage()),
            ),
            icon: const Icon(Icons.view_in_ar_outlined),
          ),
          IconButton(
            tooltip: 'Telefon boshqaruvi',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PhoneControlsPage()),
            ),
            icon: const Icon(Icons.phone_android_outlined),
          ),
          IconButton(
            tooltip: 'Sozlamalar',
            onPressed: _settings,
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
              itemCount: _messages.length + (_busy ? 1 : 0),
              itemBuilder: (context, index) {
                if (_busy && index == _messages.length) {
                  return const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text('Jasmin yozmoqda…'),
                    ),
                  );
                }
                final message = _messages[index];
                return Align(
                  alignment: message.fromUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 330),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: message.fromUser
                          ? const Color(0xFF7652B8)
                          : const Color(0xFF211B2D),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(fontSize: 16, height: 1.35),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Ovoz',
                    onPressed: _toggleMic,
                    icon: Icon(
                      _listening
                          ? Icons.stop_circle_outlined
                          : Icons.mic_none_rounded,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Jasminga yozing…',
                        filled: true,
                        fillColor: const Color(0xFF211B2D),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(28),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
