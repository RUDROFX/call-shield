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
      title: 'Call Shield',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          elevation: 0,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isProtectionOn = true;

  final List<Map<String, String>> recentCalls = [
    {'number': '+880 1712-345678', 'type': 'Spam Blocked', 'time': '10 mins ago', 'isSpam': 'true'},
    {'number': '+880 1819-000000', 'type': 'Verified Business', 'time': '1 hour ago', 'isSpam': 'false'},
    {'number': '+880 1911-998877', 'type': 'Suspected Telemarketer', 'time': '3 hours ago', 'isSpam': 'true'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call Shield', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.shield_outlined), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
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
                          isProtectionOn ? 'Shield Active' : 'Shield Disabled',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isProtectionOn ? 'Protecting from spam calls' : 'Turn on for protection',
                          style: const TextStyle(color: Colors.grey),
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
            const SizedBox(height: 24),
            const Text(
              'Recent Protection Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            // Call List
            Expanded(
              child: ListView.builder(
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
