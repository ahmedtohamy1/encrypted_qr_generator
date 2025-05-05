import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';

void main() {
  runApp(
    // Wrap the entire app with ProviderScope for Riverpod
    const ProviderScope(child: App()),
  );
}