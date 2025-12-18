import 'package:flutter/material.dart';
import 'services/alarm_scheduler.dart';
import 'ui/onboarding_page.dart';
import 'ui/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlarmScheduler.initialize();
  runApp(const KaalamApp());
}

class KaalamApp extends StatelessWidget {
  const KaalamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kaalam',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (ctx) => const OnboardingPage(),
        '/home': (ctx) => const HomePage(),
      },
    );
  }
}
