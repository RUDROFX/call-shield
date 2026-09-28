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
      title: 'Call Shield Pro',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        colorScheme: const ColorScheme.dark(
          primary: Colors.greenAccent,
          surface: Color(0xFF1E293B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
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
    const BlacklistPage(),
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
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.shield), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.block), label: 'Blacklist'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
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
  bool isProtectionOn = true;

  List<Map<String, String>> recentCalls = [
    {'number': '+880 1712-345678', 'type': 'Spam Blocked', 'time': '10 mins ago', 'isSpam': 'true'},
    {'number': '+880 1819-000000', 'type': 'Verified Business', 'time': '1 hour ago', 'isSpam': 'false'},
    {'number': '+880 1911-998877', 'type': 'Telemarketer', 'time': '3 hours ago', 'isSpam': 'true'},
    {'number': '+880 1622-114455', 'type': 'Unknown Number', 'time': '5 hours ago', 'isSpam': 'true'},
  ];

  void _checkForUpdates() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Update Check'),
        content: const Text('You are using the latest version of Call Shield Pro! (v1.0.2)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Shield Pro', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.system_update_alt),
            tooltip: 'Check Update',
            onPressed: _checkForUpdates,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Shield Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isProtectionOn ? const Color(0xFF1E293B) : const Color(0xFF334155),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isProtectionOn ? Colors.greenAccent : Colors.redAccent,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isProtectionOn ? Icons.security : Icons.security_update_warning,
                    size: 48,
                    color: isProtectionOn ? Colors.greenAccent : Colors.redAccent,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isProtectionOn ? 'Shield Active' : 'Shield Paused',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isProtectionOn ? 'Protecting from unknown spam calls' : 'Tap switch to enable shield',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isProtectionOn,
                    activeColor: Colors.greenAccent,
                    onChanged: (val) {
                      setState(() {
                        isProtectionOn = val;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity Log',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
                ),
                if (recentCalls.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => recentCalls.clear()),
                    child: const Text('Clear All', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                  )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: recentCalls.isEmpty
                  ? const Center(child: Text('No call logs available', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: recentCalls.length,
                      itemBuilder: (context, index) {
                        final item = recentCalls[index];
                        final isSpam = item['isSpam'] == 'true';
                        return Card(
                          color: const Color(0xFF1E293B),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSpam ? Colors.red.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                              child: Icon(
                                isSpam ? Icons.call_end : Icons.call,
                                color: isSpam ? Colors.redAccent : Colors.blueAccent,
                              ),
                            ),
                            title: Text(item['number']!, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
                            subtitle: Text(item['type']!, style: TextStyle(color: isSpam ? Colors.redAccent : Colors.grey)),
                            trailing: Text(item['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

// ---------------- BLACKLIST MANAGEMENT PAGE ----------------
class BlacklistPage extends StatefulWidget {
  const BlacklistPage({super.key});

  @override
  State<BlacklistPage> createState() => _BlacklistPageState();
}

class _BlacklistPageState extends State<BlacklistPage> {
  final List<String> blacklistedNumbers = [
    '+880 1700-000000',
    '+880 1900-112233',
  ];
  final TextEditingController _numberController = TextEditingController();

  void _addNumber() {
    if (_numberController.text.isNotEmpty) {
      setState(() {
        blacklistedNumbers.add(_numberController.text.trim());
        _numberController.clear();
      });
      Navigator.pop(context);
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Add Number to Blacklist'),
        content: TextField(
          controller: _numberController,
          keyboardType: TextInputType.phone,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter phone number...',
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.greenAccent)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: _addNumber,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.greenAccent),
            child: const Text('Add', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blacklist Manager')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.greenAccent,
        onPressed: _showAddDialog,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: blacklistedNumbers.isEmpty
            ? const Center(child: Text('No custom blocked numbers.', style: TextStyle(color: Colors.grey)))
            : ListView.builder(
                itemCount: blacklistedNumbers.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF1E293B),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const Icon(Icons.block, color: Colors.redAccent),
                      title: Text(blacklistedNumbers[index], style: const TextStyle(color: Colors.white)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            blacklistedNumbers.removeAt(index);
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// ---------------- SETTINGS PAGE ----------------
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool blockUnknown = true;
  bool blockSpam = true;
  bool autoReject = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Protection Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            activeColor: Colors.greenAccent,
            title: const Text('Block Unknown Calls', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Block calls from numbers not in contacts', style: TextStyle(color: Colors.grey, fontSize: 12)),
            value: blockUnknown,
            onChanged: (val) => setState(() => blockUnknown = val),
          ),
          const Divider(color: Colors.white12),
          SwitchListTile(
            activeColor: Colors.greenAccent,
            title: const Text('Spam & Telemarketer Filter', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Automatically drop suspected telemarketers', style: TextStyle(color: Colors.grey, fontSize: 12)),
            value: blockSpam,
            onChanged: (val) => setState(() => blockSpam = val),
          ),
          const Divider(color: Colors.white12),
          SwitchListTile(
            activeColor: Colors.greenAccent,
            title: const Text('Silence Rejected Calls', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Don’t ring phone when call is blocked', style: TextStyle(color: Colors.grey, fontSize: 12)),
            value: autoReject,
            onChanged: (val) => setState(() => autoReject = val),
          ),
          const Divider(color: Colors.white12),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.verified_user, color: Colors.greenAccent),
            title: const Text('Permissions Status', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Call Log & Phone permission granted', style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: const Icon(Icons.check_circle, color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }
}
