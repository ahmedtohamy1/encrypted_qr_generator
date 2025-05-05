import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/qr_encryption/provider/qr_providers.dart';
import 'features/qr_encryption/view/decrypt_screen.dart';
import 'features/qr_encryption/view/encrypt_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the app theme for changes
    final appTheme = ref.watch(appThemeProvider);

    return MaterialApp(
      title: 'Encrypted QR Generator',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = [const EncryptScreen(), const DecryptScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code), label: 'Encrypt'),
          NavigationDestination(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Decrypt',
          ),
        ],
      ),
    );
  }
}
