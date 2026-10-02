import 'package:flutter/material.dart';

void main() {
  runApp(const CallShieldApp());
}

class CallShieldApp extends StatelessWidget {
  const CallShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Call Shield Ultra',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F19),
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          surface: Color(0xFF161E2E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161E2E),
          elevation: 0,
        ),
      ),
      home: const MainTabScreen(),
    );
  }
}

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const LocationAnalyzerPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF161E2E),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shield_rounded), label: 'Shield'),
          BottomNavigationBarItem(icon: Icon(Icons.location_on_rounded), label: 'Caller Location'),
          BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: 'Rules'),
        ],
      ),
    );
  }
}

// ---------------- DASHBOARD PAGE ----------------
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isShieldActive = true;

  // Mock Call Logs with Foreign Auto-Block & Unknown Warning Logic
  List<Map<String, String>> callLogs = [
    {
      'number': '+1 (555) 019-2834',
      'status': 'Auto-Blocked (Foreign)',
      'location': 'United States (International)',
      'time': '2 mins ago',
      'type': 'blocked_foreign'
    },
    {
      'number': '+880 1712-998877',
      'status': 'Unknown Caller Warning',
      'location': 'Grameenphone • Dhaka Region',
      'time': '15 mins ago',
      'type': 'warning_unknown'
    },
    {
      'number': '+91 98765 43210',
      'status': 'Auto-Blocked (Foreign)',
      'location': 'India (International)',
      'time': '1 hour ago',
      'type': 'blocked_foreign'
    },
    {
      'number': '+880 1819-112233',
      'status': 'Verified Contact',
      'location': 'Robi • Chittagong Division',
      'time': '3 hours ago',
      'type': 'verified'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Shield Ultra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: Chip(
              backgroundColor: isShieldActive ? Colors.greenAccent.withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
              side: BorderSide(color: isShieldActive ? Colors.greenAccent : Colors.redAccent),
              label: Text(
                isShieldActive ? 'PROTECTED' : 'PAUSED',
                style: TextStyle(
                  color: isShieldActive ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Switcher Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF161E2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isShieldActive ? Colors.greenAccent.withOpacity(0.5) : Colors.redAccent.withOpacity(0.5),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: isShieldActive ? Colors.greenAccent.withOpacity(0.1) : Colors.redAccent.withOpacity(0.1),
                    child: Icon(
                      isShieldActive ? Icons.verified_user_rounded : Icons.gpp_maybe_rounded,
                      color: isShieldActive ? Colors.greenAccent : Colors.redAccent,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isShieldActive ? 'Smart Rules Active' : 'Shield Suspended',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isShieldActive
                              ? 'Foreign numbers auto-blocked. Unknown numbers flagged with warning.'
                              : 'Turn on to enable auto-blocking & warnings.',
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isShieldActive,
                    activeColor: Colors.greenAccent,
                    onChanged: (val) {
                      setState(() {
                        isShieldActive = val;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Live Protection Logs',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                if (callLogs.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => callLogs.clear()),
                    child: const Text('Clear History', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  )
              ],
            ),

            const SizedBox(height: 10),

            // Call Log List
            Expanded(
              child: callLogs.isEmpty
                  ? const Center(child: Text('No call logs recorded.', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: callLogs.length,
                      itemBuilder: (context, index) {
                        final log = callLogs[index];
                        final type = log['type'];

                        Color iconColor = Colors.blueAccent;
                        IconData iconData = Icons.call;
                        Color statusColor = Colors.grey;

                        if (type == 'blocked_foreign') {
                          iconColor = Colors.redAccent;
                          iconData = Icons.block_rounded;
                          statusColor = Colors.redAccent;
                        } else if (type == 'warning_unknown') {
                          iconColor = Colors.orangeAccent;
                          iconData = Icons.warning_amber_rounded;
                          statusColor = Colors.orangeAccent;
                        }

                        return Card(
                          color: const Color(0xFF161E2E),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            leading: CircleAvatar(
                              backgroundColor: iconColor.withOpacity(0.15),
                              child: Icon(iconData, color: iconColor),
                            ),
                            title: Text(log['number']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 3),
                                Text(log['status']!, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
                                Text(log['location']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              ],
                            ),
                            trailing: Text(log['time']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- LOCATION ANALYZER PAGE ----------------
class LocationAnalyzerPage extends StatefulWidget {
  const LocationAnalyzerPage({super.key});

  @override
  State<LocationAnalyzerPage> createState() => _LocationAnalyzerPageState();
}

class _LocationAnalyzerPageState extends State<LocationAnalyzerPage> {
  final TextEditingController _inputController = TextEditingController();
  String _detectedLocation = '';
  String _detectedOperator = '';
  String _callRecommendation = '';

  void _analyzeNumber(String number) {
    final clean = number.replaceAll(RegExp(r'[^\d+]'), '');

    if (clean.isEmpty) return;

    setState(() {
      if (clean.startsWith('+1')) {
        _detectedOperator = 'International Operator';
        _detectedLocation = 'United States / Canada (+1)';
        _callRecommendation = 'ACTION: AUTO-BLOCK (Foreign Number Policy)';
      } else if (clean.startsWith('+44')) {
        _detectedOperator = 'UK Mobile / Landline';
        _detectedLocation = 'United Kingdom (+44)';
        _callRecommendation = 'ACTION: AUTO-BLOCK (Foreign Number Policy)';
      } else if (clean.startsWith('+91')) {
        _detectedOperator = 'Indian Telecom';
        _detectedLocation = 'India (+91)';
        _callRecommendation = 'ACTION: AUTO-BLOCK (Foreign Number Policy)';
      } else if (clean.startsWith('+880') || clean.startsWith('01')) {
        _detectedLocation = 'Bangladesh (National Call)';
        if (clean.contains('17') || clean.contains('13')) {
          _detectedOperator = 'Grameenphone (Dhaka/Nationwide)';
        } else if (clean.contains('18')) {
          _detectedOperator = 'Robi Axiata (Chittagong/Nationwide)';
        } else if (clean.contains('19') || clean.contains('14')) {
          _detectedOperator = 'Banglalink (Dhaka/Nationwide)';
        } else if (clean.contains('15')) {
          _detectedOperator = 'Teletalk Bangladesh';
        } else {
          _detectedOperator = 'BD Local Operator';
        }
        _callRecommendation = 'ACTION: ALLOW & SHOW UNKNOWN CALL WARNING';
      } else {
        _detectedOperator = 'Unknown Foreign Gateway';
        _detectedLocation = 'International / Satellite Region';
        _callRecommendation = 'ACTION: AUTO-BLOCK (Foreign Number Policy)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caller Location Lookup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Number Origin & Location Rules',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter any phone number to simulate location lookup and shield action.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _inputController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. +1 555 1234 or +8801712345678',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF161E2E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search, color: Colors.greenAccent),
                  onPressed: () => _analyzeNumber(_inputController.text),
                ),
              ),
              onChanged: _analyzeNumber,
            ),
            const SizedBox(height: 24),
            if (_detectedLocation.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF161E2E),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('LOOKUP RESULTS:', style: TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.greenAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(_detectedLocation, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.cell_tower, color: Colors.blueAccent, size: 20),
                        const SizedBox(width: 8),
                        Text(_detectedOperator, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 24),
                    Text(
                      _callRecommendation,
                      style: TextStyle(
                        color: _callRecommendation.contains('AUTO-BLOCK') ? Colors.redAccent : Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}

// ---------------- RULES & SETTINGS PAGE ----------------
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool blockAllForeign = true;
  bool warnUnknownBD = true;
  bool showLocationPopup = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shield Rules & Policies')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('AUTOMATIC PROTECTION POLICIES', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SwitchListTile(
            activeColor: Colors.greenAccent,
            title: const Text('Direct Block Foreign Numbers', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Automatically terminate incoming calls from non-BD country codes (+1, +44, +91 etc.)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            value: blockAllForeign,
            onChanged: (val) => setState(() => blockAllForeign = val),
          ),
          const Divider(color: Colors.white12),
          SwitchListTile(
            activeColor: Colors.greenAccent,
            title: const Text('Unknown Call Caution Warning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Do NOT block BD unknown numbers. Display caution warning & location banner instead.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            value: warnUnknownBD,
            onChanged: (val) => setState(() => warnUnknownBD = val),
          ),
          const Divider(color: Colors.white12),
          SwitchListTile(
            activeColor: Colors.greenAccent,
            title: const Text('Show Live Caller Location Popup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: const Text('Identify region, operator, and city on screen during ring', style: TextStyle(color: Colors.grey, fontSize: 12)),
            value: showLocationPopup,
            onChanged: (val) => setState(() => showLocationPopup = val),
          ),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          const Card(
            color: Color(0xFF161E2E),
            child: ListTile(
              leading: Icon(Icons.shield_moon_outlined, color: Colors.greenAccent),
              title: Text('Call Shield Policy Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('Foreign Auto-Block: ACTIVE\nUnknown Warning: ACTIVE', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          )
        ],
      ),
    );
  }
}
