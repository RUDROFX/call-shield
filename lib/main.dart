import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const MethodChannel channel = MethodChannel('call_shield/native');

const Color kGreen = Color(0xFF00E676);
const Color kBg = Color(0xFF0A0E17);
const Color kCard = Color(0xFF1A2130);
const Color kRed = Color(0xFFFF5252);
const Color kAmber = Color(0xFFFFC107);

const Map<String, String> kCountries = {
  '1': 'United States / Canada',
  '7': 'Russia / Kazakhstan',
  '20': 'Egypt',
  '27': 'South Africa',
  '33': 'France',
  '44': 'United Kingdom',
  '49': 'Germany',
  '60': 'Malaysia',
  '61': 'Australia',
  '62': 'Indonesia',
  '65': 'Singapore',
  '81': 'Japan',
  '82': 'South Korea',
  '86': 'China',
  '91': 'India',
  '92': 'Pakistan',
  '93': 'Afghanistan',
  '94': 'Sri Lanka',
  '95': 'Myanmar',
  '234': 'Nigeria',
  '960': 'Maldives',
  '965': 'Kuwait',
  '966': 'Saudi Arabia',
  '968': 'Oman',
  '971': 'United Arab Emirates',
  '973': 'Bahrain',
  '974': 'Qatar',
  '977': 'Nepal',
};

const Map<String, String> kOperators = {
  '3': 'Grameenphone',
  '4': 'Banglalink',
  '5': 'Teletalk',
  '6': 'Robi (Airtel)',
  '7': 'Grameenphone',
  '8': 'Robi',
  '9': 'Banglalink',
};

class NumberInfo {
  final String display;
  final bool isForeign;
  final String label;
  final String? suspiciousReason;
  const NumberInfo(this.display, this.isForeign, this.label, this.suspiciousReason);
}

bool hasRepeat(String s) {
  var run = 1;
  for (var i = 1; i < s.length; i++) {
    run = s[i] == s[i - 1] ? run + 1 : 1;
    if (run >= 6) return true;
  }
  return false;
}

NumberInfo analyzeNumber(String raw) {
  var n = raw.replaceAll(RegExp(r'[^0-9+]'), '');
  if (n.startsWith('00')) n = '+${n.substring(2)}';
  if (n.isEmpty) return const NumberInfo('Hidden number', false, 'Unknown', null);

  if (n.startsWith('+') && !n.startsWith('+880')) {
    var country = 'Foreign country';
    final digits = n.substring(1);
    for (var len = 3; len >= 1; len--) {
      if (digits.length >= len) {
        final c = kCountries[digits.substring(0, len)];
        if (c != null) {
          country = c;
          break;
        }
      }
    }
    return NumberInfo(n, true, country, null);
  }

  var local = n;
  if (local.startsWith('+880')) {
    local = '0${local.substring(4)}';
  } else if (local.startsWith('880') && local.length >= 12) {
    local = '0${local.substring(3)}';
  }

  var label = 'Bangladesh';
  String? reason;
  if (local.startsWith('01')) {
    if (local.length != 11) {
      reason = 'Invalid mobile number length';
    } else if ('012'.contains(local[2])) {
      reason = 'Unknown operator code';
    } else {
      final op = kOperators[local[2]] ?? 'Bangladesh';
      label = '$op (Mobile)';
    }
  } else if (local.startsWith('0')) {
    label = 'Bangladesh (Landline)';
    if (local.length < 9 || local.length > 11) reason = 'Unusual landline length';
  } else if (local.length >= 7) {
    reason = 'Unrecognized number format';
  } else {
    label = 'Bangladesh (Short code)';
  }

  if (reason == null && hasRepeat(local)) reason = 'Repeating digits';
  return NumberInfo(local, false, label, reason);
}

String timeAgo(int ms) {
  final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms));
  if (d.inMinutes < 1) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes} min ago';
  if (d.inHours < 24) return '${d.inHours} hr ago';
  return '${d.inDays} d ago';
}

void main() => runApp(const CallShieldApp());

class CallShieldApp extends StatelessWidget {
  const CallShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Call Shield Ultra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kBg,
        colorScheme: const ColorScheme.dark(primary: kGreen),
        useMaterial3: true,
      ),
      home: const RootPage(),
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> with WidgetsBindingObserver {
  int _tab = 0;
  bool _enabled = true;
  bool _blockForeign = true;
  bool _warnSuspicious = true;
  bool _roleHeld = false;
  List<Map<String, dynamic>> _logs = [];
  final TextEditingController _search = TextEditingController();
  NumberInfo? _result;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _search.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh();
    }
  }

  Future<void> _init() async {
    try {
      await channel.invokeMethod('requestNotificationPermission');
    } catch (_) {}
    await _loadSettings();
    await _refresh();
  }

  Future<void> _loadSettings() async {
    try {
      final Map? s = await channel.invokeMethod<Map>('getSettings');
      if (s != null && mounted) {
        setState(() {
          _enabled = s['enabled'] == true;
          _blockForeign = s['blockForeign'] == true;
          _warnSuspicious = s['warnSuspicious'] == true;
        });
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      await channel.invokeMethod('saveSettings', {
        'enabled': _enabled,
        'blockForeign': _blockForeign,
        'warnSuspicious': _warnSuspicious,
      });
    } catch (_) {}
  }

  Future<void> _refresh() async {
    try {
      final String? raw = await channel.invokeMethod<String>('getLogs');
      final bool? held = await channel.invokeMethod<bool>('isRoleHeld');
      final list = (jsonDecode(raw ?? '[]') as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      if (mounted) {
        setState(() {
          _logs = list;
          _roleHeld = held ?? false;
        });
      }
    } catch (_) {}
  }

  Future<void> _requestRole() async {
    try {
      await channel.invokeMethod('requestRole');
    } catch (_) {}
    await Future.delayed(const Duration(seconds: 1));
    await _refresh();
  }

  Future<void> _clearLogs() async {
    try {
      await channel.invokeMethod('clearLogs');
    } catch (_) {}
    await _refresh();
  }

  Widget _card({required Widget child, Color? border}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border ?? const Color(0xFF2A3345)),
      ),
      child: child,
    );
  }

  Widget _shieldTab() {
    final protected = _enabled && _roleHeld;
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Call Shield Ultra',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: protected ? kGreen : kAmber),
                ),
                child: Text(
                  protected ? 'PROTECTED' : 'INACTIVE',
                  style: TextStyle(
                    color: protected ? kGreen : kAmber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _card(
            border: protected ? kGreen : null,
            child: Row(
              children: [
                Icon(Icons.shield, size: 40, color: _enabled ? kGreen : Colors.grey),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _enabled ? 'Smart Shield Active' : 'Shield Paused',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Foreign calls blocked. Suspicious local calls flagged.',
                        style: TextStyle(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _enabled,
                  onChanged: (v) {
                    setState(() => _enabled = v);
                    _save();
                  },
                ),
              ],
            ),
          ),
          if (!_roleHeld)
            _card(
              border: kAmber,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Set as default call screening app',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Without this, blocking will not work.',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _requestRole,
                    child: const Text('Enable protection'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Incoming Call Logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextButton(
                onPressed: _clearLogs,
                child: const Text('Clear Logs', style: TextStyle(color: kRed)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_logs.isEmpty)
            _card(
              child: const Text(
                'No calls yet. Incoming calls from numbers not in your contacts will appear here.',
                style: TextStyle(color: Colors.white60),
              ),
            ),
          for (final l in _logs) _logTile(l),
        ],
      ),
    );
  }

  Widget _logTile(Map<String, dynamic> l) {
    final number = (l['number'] ?? '').toString();
    final status = (l['status'] ?? 'allowed').toString();
    final detail = (l['detail'] ?? '').toString();
    final ms = (l['time'] as num?)?.toInt() ?? 0;
    final info = analyzeNumber(number);

    Color color;
    IconData icon;
    String title;
    if (status == 'blocked') {
      color = kRed;
      icon = Icons.block;
      title = 'Auto-Blocked (Foreign)';
    } else if (status == 'warned') {
      color = kAmber;
      icon = Icons.warning_amber_rounded;
      title = 'Suspicious: $detail';
    } else {
      color = kGreen;
      icon = Icons.call_received;
      title = 'Allowed';
    }

    return _card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.18),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.display,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(info.label, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
          Text(timeAgo(ms), style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _trackerTab() {
    final r = _result;
    var c = kGreen;
    var verdict = 'Looks normal';
    if (r != null) {
      if (r.isForeign) {
        c = kRed;
        verdict = _blockForeign ? 'Foreign number - will be auto-blocked' : 'Foreign number';
      } else if (r.suspiciousReason != null) {
        c = kAmber;
        verdict = 'Suspicious: ${r.suspiciousReason}';
      }
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Live Caller & Location Lookup',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _search,
          keyboardType: TextInputType.phone,
          onChanged: (v) {
            setState(() {
              _result = v.trim().isEmpty ? null : analyzeNumber(v.trim());
            });
          },
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search, color: kGreen),
            hintText: 'Enter phone number (e.g. 01739...)',
            filled: true,
            fillColor: kCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (r != null)
          _card(
            border: c,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.display, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(r.label, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 10),
                Text(verdict, style: TextStyle(color: c, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        const Text(
          'Note: only the operator or country can be identified from a number. The exact district or city cannot be known.',
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _rulesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Protection Rules',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _card(
          child: Column(
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Direct Block Foreign Calls'),
                subtitle: const Text('Instantly decline incoming calls from non-BD country codes'),
                value: _blockForeign,
                onChanged: (v) {
                  setState(() => _blockForeign = v);
                  _save();
                },
              ),
              const Divider(color: Color(0xFF2A3345)),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Suspicious Number Warning'),
                subtitle: const Text('Notify when a Bangladeshi number looks unusual'),
                value: _warnSuspicious,
                onChanged: (v) {
                  setState(() => _warnSuspicious = v);
                  _save();
                },
              ),
            ],
          ),
        ),
        const Text(
          'Note: Android does not screen calls from numbers saved in your contacts.',
          style: TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [_shieldTab(), _trackerTab(), _rulesTab()];
    return Scaffold(
      body: SafeArea(child: tabs[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.shield_outlined), selectedIcon: Icon(Icons.shield), label: 'Shield'),
          NavigationDestination(icon: Icon(Icons.my_location_outlined), selectedIcon: Icon(Icons.my_location), label: 'Caller Tracker'),
          NavigationDestination(icon: Icon(Icons.tune), label: 'Rules'),
        ],
      ),
    );
  }
}
