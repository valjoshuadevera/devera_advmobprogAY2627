import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Entry point ng application.
/// Dito nagsisimula ang buong Flutter app.
void main() {
  runApp(
    ChangeNotifierProvider(
      // Gumagawa ng ThemeProvider at ginagawa itong accessible
      // sa buong application.
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

/// Class na nagma-manage ng theme gamit ang Provider.
class ThemeProvider extends ChangeNotifier {
  // Variable na nagtatago kung naka-dark mode ba ang app.
  bool _isDarkMode = false;

  /// Getter para makuha ang current theme mode.
  bool get isDarkMode => _isDarkMode;

  /// Function na nagpapalit ng light at dark theme.
  void toggleTheme(bool value) {
    _isDarkMode = value;

    // Ina-update ang lahat ng widgets na gumagamit ng ThemeProvider.
    notifyListeners();
  }
}

/// Main widget ng application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer ang nakikinig sa changes ng ThemeProvider.
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Ephemeral vs App State',

          // Default light theme.
          theme: ThemeData.light(),

          // Dark theme ng application.
          darkTheme: ThemeData.dark(),

          // Pinipili kung light o dark ang gagamitin
          // base sa value ng ThemeProvider.
          themeMode:
              themeProvider.isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light,

          // Unang screen na ipapakita.
          home: const CounterScreen(),
        );
      },
    );
  }
}

/// Screen para ipakita ang Ephemeral State gamit ang setState().
class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  // Local variable para sa counter.
  // Ephemeral state ito dahil sa screen lang ito ginagamit.
  int counter = 0;

  /// Function para dagdagan ang counter.
  void incrementCounter() {
    setState(() {
      counter++;
    });

    // setState() ang nagre-refresh ng UI.
  }

  /// Function para bawasan ang counter.
  void decrementCounter() {
    setState(() {
      counter--;
    });

    // Awtomatikong maa-update ang counter sa screen.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter Screen'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Label ng counter.
            const Text(
              'Counter Value',
              style: TextStyle(
                fontSize: 24,
              ),
            ),

            const SizedBox(height: 15),

            // Ipinapakita ang current value ng counter.
            Text(
              '$counter',
              style: const TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // Buttons para mag-increment at decrement.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: decrementCounter,
                  child: const Text('-'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: incrementCounter,
                  child: const Text('+'),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Button para pumunta sa Theme Settings screen.
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeScreen(),
                  ),
                );
              },
              child: const Text('Go to Theme Settings'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen para ipakita ang App State gamit ang Provider.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Kinukuha ang ThemeProvider para ma-access ang current theme.
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Settings'),
        centerTitle: true,
      ),
      body: Center(
        child: SwitchListTile(
          // Label ng switch.
          title: const Text('Dark Mode'),

          // Short description ng switch.
          subtitle: const Text(
            'Toggle the application theme',
          ),

          // Current value ng switch.
          value: themeProvider.isDarkMode,

          // Kapag tinoggle ang switch,
          // tatawagin ang toggleTheme() para magpalit ng theme.
          onChanged: (value) {
            themeProvider.toggleTheme(value);
          },
        ),
      ),
    );
  }
}