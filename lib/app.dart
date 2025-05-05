import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/qr_encryption/provider/qr_providers.dart' as qr_providers;
import 'features/qr_encryption/view/decrypt_screen.dart';
import 'features/qr_encryption/view/encrypt_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the theme from the provider
    final appTheme = ref.watch(qr_providers.appThemeProvider);
    final bool isDarkMode = appTheme.brightness == Brightness.dark;

    return MaterialApp(
      title: 'Encrypted QR Generator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _controller;
  late final Animation<double> _animation;

  final List<Widget> _screens = [const EncryptScreen(), const DecryptScreen()];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changePage(int index) {
    setState(() {
      _currentIndex = index;
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _changePage,
        backgroundColor: theme.colorScheme.surface,
        elevation: 8,
        shadowColor: Colors.black26,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        animationDuration: const Duration(milliseconds: 300),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.qr_code_outlined),
            selectedIcon: Icon(
              Icons.qr_code_rounded,
              color: theme.colorScheme.primary,
            ),
            label: 'Encrypt',
          ),
          NavigationDestination(
            icon: const Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(
              Icons.qr_code_scanner_rounded,
              color: theme.colorScheme.primary,
            ),
            label: 'Decrypt',
          ),
        ],
      ),
    );
  }
}
