import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CallShieldApp());
}

class CallShieldApp extends StatelessWidget {
  const CallShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Shield',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const MethodChannel _channel = MethodChannel('call_shield/native');

  bool _blockForeign = true;
  bool _warnSuspicious = true;
  bool _isDefaultScreener = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _checkRole();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _blockForeign = prefs.getBool('block_foreign') ?? true;
      _warnSuspicious = prefs.getBool('warn_suspicious') ?? true;
    });
    await _syncToNative();
  }

  Future<void> _syncToNative() async {
    try {
      await _channel.invokeMethod('saveSettings', {
        'blockForeign': _blockForeign,
        'warnSuspicious': _warnSuspicious,
      });
    } catch (_) {}
  }

  Future<void> _checkRole() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isScreeningRoleHeld');
      setState(() {
        _isDefaultScreener = result ?? false;
      });
    } catch (_) {}
  }

  Future<void> _requestRole() async {
    try {
      await _channel.invokeMethod('requestScreeningRole');
    } catch (_) {}
    await Future.delayed(const Duration(seconds: 1));
    await _checkRole();
  }

  Future<void> _setBlockForeign(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('block_foreign', value);
    setState(() => _blockForeign = value);
    await _syncToNative();
  }

  Future<void> _setWarnSuspicious(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('warn_suspicious', value);
    setState(() => _warnSuspicious = value);
    await _syncToNative();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Shield'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: _isDefaultScreener ? Colors.green.shade50 : Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isDefaultScreener ? Icons.shield : Icons.shield_outlined,
                        color: _isDefaultScreener ? Colors.green : Colors.orange,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isDefaultScreener
                              ? 'সুরক্ষা চালু আছে'
                              : 'সুরক্ষা চালু নেই',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_isDefaultScreener
                      ? 'এই অ্যাপ এখন আপনার কল স্ক্রিন করছে।'
                      : 'কল ব্লক করতে এই অ্যাপকে ডিফল্ট কল স্ক্রিনিং অ্যাপ বানাতে হবে।'),
                  if (!_isDefaultScreener) ...[
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _requestRole,
                      child: const Text('চালু করুন'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('বিদেশি নাম্বার ব্লক করুন'),
            subtitle: const Text('+880 ছাড়া অন্য দেশের নাম্বার থেকে কল এলে অটো ব্লক হবে'),
            value: _blockForeign,
            onChanged: _setBlockForeign,
          ),
          SwitchListTile(
            title: const Text('সন্দেহজনক নাম্বারে সতর্কতা'),
            subtitle: const Text('অস্বাভাবিক দেশি নাম্বার হলে নোটিফিকেশনে সতর্ক করবে'),
            value: _warnSuspicious,
            onChanged: _setWarnSuspicious,
          ),
          const SizedBox(height: 16),
          const Text(
            'নোট: ডিফল্ট কল স্ক্রিনিং অ্যাপ হিসেবে সিলেক্ট না করলে ব্লকিং কাজ করবে না।',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
