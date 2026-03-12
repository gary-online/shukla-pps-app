import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shukla_pps/config/app_config.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/config/router.dart';
import 'package:shukla_pps/providers/session_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    AppConfig.supabaseUrl.isNotEmpty && AppConfig.supabaseAnonKey.isNotEmpty,
    'SUPABASE_URL and SUPABASE_ANON_KEY must be provided via --dart-define',
  );

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: ShuklaPpsApp()));
}

class ShuklaPpsApp extends ConsumerWidget {
  const ShuklaPpsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return GestureDetector(
      // Reset inactivity timer on any user interaction
      onTap: () => ref.read(sessionServiceProvider).resetTimer(),
      onPanDown: (_) => ref.read(sessionServiceProvider).resetTimer(),
      child: MaterialApp.router(
        title: 'Shukla PPS',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: router,
        builder: (context, child) {
          // Constrain to mobile width for desktop testing
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
