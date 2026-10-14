
import 'package:devera_advmovprog_ay2627/firebase_options.dart';
import 'package:devera_advmovprog_ay2627/providers/theme_provider.dart';
import 'package:devera_advmovprog_ay2627/screens/home_screen.dart';
import 'package:devera_advmovprog_ay2627/screens/settings_screen.dart';
import 'package:devera_advmovprog_ay2627/screens/signin_screen.dart';
import 'package:devera_advmovprog_ay2627/screens/signup_screen.dart';
import 'package:devera_advmovprog_ay2627/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((
    _,
  ) async {
    await dotenv.load(fileName: 'assets/.env');
    // Enhancement 2: Initialize Firebase before the app starts.
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } on UnsupportedError catch (error) {
      debugPrint(error.message);
    }
    runApp(const RosalesAdvMobProg());
  });
}

class RosalesAdvMobProg extends StatelessWidget {
  const RosalesAdvMobProg({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: ScreenUtilInit(
        designSize: const Size(412, 715),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (build, child) {
          final themeModel = build.watch<ThemeProvider>();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: themeModel.isDark ? ThemeMode.dark : ThemeMode.light,
            title: 'E-Commerce App',
            initialRoute: '/',
            routes: {
              '/': (context) => const SplashScreen(),
              '/signin': (context) => const SignInScreen(),
              '/signup': (context) => const SignupScreen(),
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
