import 'dart:ui';
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
        scaffoldBackgroundColor: const Color(0xFF080C14),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          surface: Color(0xFF101726),
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

  // Global State persistence so state doesn't reset automatically
  static bool isShieldActive = true;
  static bool blockForeign = true;
  static bool warnUnknown = true;
  static bool liveLocationPopup = true;

  final List<Widget> _pages = [
    const DashboardPage(),
    const LocationAnalyzerPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF080C14), Color(0xFF121B2D), Color(0xFF05080E)],
          ),
        ),
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF101726).withOpacity(0.7),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08))),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: const Color(0xFF00E676),
              unselectedItemColor: Colors.white38,
              onTap: (index) => setState(() => _currentIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.shield_rounded), label: 'Shield'),
                BottomNavigationBarItem(icon: Icon(Icons.my_location_rounded), label: 'Live Location'),
                BottomNavigationBarItem(icon: Icon(Icons.tune_rounded), label: 'Rules'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- GLASSMORPHIC CONTAINER WIDGET ----------------
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final Color? borderColor;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withOpacity(0.12),
              width: 1.2,
            ),
          ),
          child: child,
        ),
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
  List<Map<String, String>> callLogs = [
    {
      'number': '+1 (555) 019-2834',
      'status': 'Auto-Blocked (Foreign)',
      'location': 'United States • Live GPS Tracked',
      'time': '2 mins ago',
      'type': 'blocked_foreign'
    },
    {
      'number': '+880 1712-998877',
      'status': 'Unknown Caller Warning',
      'location': 'Grameenphone • Dhaka, Bangladesh',
      'time': '15 mins ago',
      'type': 'warning_unknown'
    },
    {
      'number': '+91 98765 43210',
      'status': 'Auto-Blocked (Foreign)',
      'location': 'India • Live GPS Tracked',
      'time': '1 hour ago',
      'type': 'blocked_foreign'
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool active = _MainTabScreenState.isShieldActive;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Call Shield Ultra', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Chip(
              backgroundColor: active ? const Color(0xFF00E676).withOpacity(0.15) : Colors.redAccent.withOpacity(0.15),
              side: BorderSide(color: active ? const Color(0xFF00E676) : Colors.redAccent),
              label: Text(
                active ? 'PROTECTED' : 'PAUSED',
                style: TextStyle(
                  color: active ? const Color(0xFF00E676) : Colors.redAccent,
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
            // Glass Banner Switch
            GlassContainer(
              borderColor: active ? const Color(0xFF00E676).withOpacity(0.4) : Colors.redAccent.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: active ? const Color(0xFF00E676).withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
                      child: Icon(
                        active ? Icons.shield_rounded : Icons.shield_outlined,
                        color: active ? const Color(0xFF00E676) : Colors.redAccent,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            active ? 'Smart Shield Active' : 'Protection Paused',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            active
                                ? 'Foreign numbers auto-blocked. Live location tracking enabled.'
                                : 'Shield is OFF. Incoming calls will not be filtered.',
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: active,
                      activeColor: const Color(0xFF00E676),
                      onChanged: (val) {
                        setState(() {
                          _MainTabScreenState.isShieldActive = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Live Activity Feed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
                if (callLogs.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => callLogs.clear()),
                    child: const Text('Clear Logs', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                  )
              ],
            ),

            const SizedBox(height: 12),

            Expanded(
              child: callLogs.isEmpty
                  ? const Center(child: Text('No call activity recorded.', style: TextStyle(color: Colors.white38)))
                  : ListView.builder(
                      itemCount: callLogs.length,
                      itemBuilder: (context, index) {
                        final log = callLogs[index];
                        final isBlocked = log['type'] == 'blocked_foreign';

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: GlassContainer(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: isBlocked ? Colors.redAccent.withOpacity(0.2) : Colors.amber.withOpacity(0.2),
                                child: Icon(
                                  isBlocked ? Icons.block_rounded : Icons.warning_amber_rounded,
                                  color: isBlocked ? Colors.redAccent : Colors.amber,
                                ),
                              ),
                              title: Text(log['number']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(log['status']!, style: TextStyle(color: isBlocked ? Colors.redAccent : Colors.amber, fontSize: 12, fontWeight: FontWeight.w600)),
                                  Text(log['location']!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                ],
                              ),
                              trailing: Text(log['time']!, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                            ),
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

// ---------------- LIVE LOCATION ANALYZER ----------------
class LocationAnalyzerPage extends StatefulWidget {
  const LocationAnalyzerPage({super.key});

  @override
  State<LocationAnalyzerPage> createState() => _LocationAnalyzerPageState();
}

class _LocationAnalyzerPageState extends State<LocationAnalyzerPage> {
  final TextEditingController _controller = TextEditingController();
  String _location = '';
  String _operator = '';
  String _action = '';

  void _analyze(String val) {
    if (val.isEmpty) return;
    setState(() {
      if (val.startsWith('+1')) {
        _operator = 'US/Canada Telecom Network';
        _location = 'United States (North America)';
        _action = 'RULE: AUTO-BLOCK (International)';
      } else if (val.startsWith('+880') || val.startsWith('01')) {
        _location = 'Dhaka Division, Bangladesh';
        _operator = 'Grameenphone / Robi Network';
        _action = 'RULE: SHOW UNKNOWN WARNING & LIVE LOCATION';
      } else {
        _operator = 'Overseas Gateway';
        _location = 'International Region';
        _action = 'RULE: AUTO-BLOCK (International)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Live Caller Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter phone number with country code...',
                    hintStyle: TextStyle(color: Colors.white38),
                    icon: Icon(Icons.search, color: Color(0xFF00E676)),
                  ),
                  onChanged: _analyze,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_location.isNotEmpty)
              GlassContainer(
                borderColor: const Color(0xFF00E676).withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('LIVE TRACKING RESULT', style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF00E676)),
                          const SizedBox(width: 10),
                          Text(_location, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.cell_tower, color: Colors.blueAccent),
                          const SizedBox(width: 10),
                          Text(_operator, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                        ],
                      ),
                      const Divider(color: Colors.white12, height: 24),
                      Text(_action, style: TextStyle(color: _action.contains('AUTO-BLOCK') ? Colors.redAccent : Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              )
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Protection Rules')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GlassContainer(
            child: Column(
              children: [
                SwitchListTile(
                  activeColor: const Color(0xFF00E676),
                  title: const Text('Direct Block Foreign Calls', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Instantly decline incoming calls from non-BD country codes', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: _MainTabScreenState.blockForeign,
                  onChanged: (val) => setState(() => _MainTabScreenState.blockForeign = val),
                ),
                const Divider(color: Colors.white12, height: 1),
                SwitchListTile(
                  activeColor: const Color(0xFF00E676),
                  title: const Text('Unknown Call Warning', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Show caution alert for unknown numbers without blocking', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: _MainTabScreenState.warnUnknown,
                  onChanged: (val) => setState(() => _MainTabScreenState.warnUnknown = val),
                ),
                const Divider(color: Colors.white12, height: 1),
                SwitchListTile(
                  activeColor: const Color(0xFF00E676),
                  title: const Text('Live Caller GPS Tracking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Display real-time location & city pop-up during call', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  value: _MainTabScreenState.liveLocationPopup,
                  onChanged: (val) => setState(() => _MainTabScreenState.liveLocationPopup = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
