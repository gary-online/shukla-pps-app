# Implementation Plan 3: Authentication & Session Management

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development or superpowers:executing-plans.

**Goal:** Build the login screen, lock screen, session management with HIPAA-compliant timeouts, and auth state providers.

**Prerequisites:** Implementation Plans 1 & 2 completed.

**Design Spec:** `DESIGN.md` — Login & Lock Screen section

---

## Task 1: Auth State Providers

**Files:**
- Create: `lib/providers/auth_providers.dart`

- [ ] **Step 1: Implement auth providers**

```dart
// lib/providers/auth_providers.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/data/repositories/auth_repository.dart';
import 'package:shukla_pps/models/user_profile.dart';
import 'package:shukla_pps/providers/repository_providers.dart';

/// The current authenticated user profile. Null if not signed in.
final currentUserProvider = AsyncNotifierProvider<CurrentUserNotifier, UserProfile?>(
  CurrentUserNotifier.new,
);

class CurrentUserNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final authRepo = ref.watch(authRepositoryProvider);

    // Listen to auth state changes
    final sub = authRepo.onAuthStateChange().listen((event) {
      if (event == AuthState.signedOut) {
        state = const AsyncData(null);
      }
    });
    ref.onDispose(() => sub.cancel());

    return authRepo.getCurrentUser();
  }

  Future<void> signIn({required String email, required String password}) async {
    final authRepo = ref.read(authRepositoryProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => authRepo.signIn(email: email, password: password));
  }

  Future<void> signOut() async {
    final authRepo = ref.read(authRepositoryProvider);
    await authRepo.signOut();
    state = const AsyncData(null);
  }

  Future<void> refresh() async {
    final authRepo = ref.read(authRepositoryProvider);
    state = await AsyncValue.guard(() => authRepo.getCurrentUser());
  }
}

/// Whether the user is currently authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull != null;
});

/// Whether the current user is an admin.
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user.valueOrNull?.isAdmin ?? false;
});
```

- [ ] **Step 2: Commit**

```bash
git add lib/providers/auth_providers.dart
git commit -m "Add auth state providers with CurrentUserNotifier"
```

---

## Task 2: Session Service (Inactivity Timeout)

**Files:**
- Create: `lib/services/session_service.dart`
- Create: `lib/providers/session_providers.dart`
- Create: `test/services/session_service_test.dart`

- [ ] **Step 1: Write test for SessionService**

```dart
// test/services/session_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shukla_pps/services/session_service.dart';

void main() {
  group('SessionService', () {
    late SessionService service;

    setUp(() {
      service = SessionService(timeout: const Duration(seconds: 2));
    });

    tearDown(() {
      service.dispose();
    });

    test('starts unlocked', () {
      expect(service.isLocked, false);
    });

    test('locks after timeout', () async {
      service.startTimer();
      await Future.delayed(const Duration(seconds: 3));
      expect(service.isLocked, true);
    });

    test('resetTimer prevents lock', () async {
      service.startTimer();
      await Future.delayed(const Duration(seconds: 1));
      service.resetTimer();
      await Future.delayed(const Duration(seconds: 1));
      expect(service.isLocked, false);
    });

    test('unlock resets lock state', () {
      service.lock();
      expect(service.isLocked, true);
      service.unlock();
      expect(service.isLocked, false);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

```bash
flutter test test/services/session_service_test.dart
```

Expected: FAIL — file not found.

- [ ] **Step 3: Implement SessionService**

```dart
// lib/services/session_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

class SessionService extends ChangeNotifier {
  SessionService({required this.timeout});

  final Duration timeout;
  Timer? _timer;
  bool _isLocked = false;

  bool get isLocked => _isLocked;

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(timeout, lock);
  }

  void resetTimer() {
    if (!_isLocked) {
      startTimer();
    }
  }

  void lock() {
    _isLocked = true;
    _timer?.cancel();
    notifyListeners();
  }

  void unlock() {
    _isLocked = false;
    startTimer();
    notifyListeners();
  }

  void stop() {
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
```

- [ ] **Step 4: Create session providers**

```dart
// lib/providers/session_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/config/app_config.dart';
import 'package:shukla_pps/services/session_service.dart';

final sessionServiceProvider = ChangeNotifierProvider<SessionService>((ref) {
  final service = SessionService(timeout: AppConfig.inactivityTimeout);
  ref.onDispose(() => service.dispose());
  return service;
});

final isLockedProvider = Provider<bool>((ref) {
  return ref.watch(sessionServiceProvider).isLocked;
});
```

- [ ] **Step 5: Run tests**

```bash
flutter test test/services/session_service_test.dart
```

Expected: All tests PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/services/session_service.dart lib/providers/session_providers.dart test/services/session_service_test.dart
git commit -m "Add SessionService with inactivity timeout and providers"
```

---

## Task 3: Login Screen

**Files:**
- Create: `lib/screens/auth/login_screen.dart`

- [ ] **Step 1: Implement LoginScreen**

```dart
// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/config/app_config.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _errorMessage = null);

    await ref.read(currentUserProvider.notifier).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    final authState = ref.read(currentUserProvider);
    if (authState.hasError) {
      setState(() {
        final error = authState.error.toString();
        if (error.contains('deactivated')) {
          _errorMessage = 'Your account has been deactivated. Contact your administrator.';
        } else {
          _errorMessage = 'Invalid email or password';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(currentUserProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo placeholder — replace with actual Shukla logo asset
                  Icon(
                    Icons.medical_services,
                    size: 80,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Shukla PPS',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.black,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      helperText: 'Minimum ${AppConfig.minPasswordLength} characters',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Error message
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: AppTheme.urgentRed, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Login button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Log In'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/auth/login_screen.dart
git commit -m "Add login screen with email/password authentication"
```

---

## Task 4: Lock Screen

**Files:**
- Create: `lib/screens/auth/lock_screen.dart`

- [ ] **Step 1: Implement LockScreen**

```dart
// lib/screens/auth/lock_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/providers/session_providers.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleUnlock() async {
    final password = _passwordController.text;
    if (password.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ref.read(authRepositoryProvider).reauthenticate(password: password);
      ref.read(sessionServiceProvider).unlock();
    } catch (_) {
      setState(() => _errorMessage = 'Incorrect password');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock, size: 64, color: AppTheme.primaryBlue),
                const SizedBox(height: 16),
                Text(
                  'Session Locked',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your password to continue',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  onFieldSubmitted: (_) => _handleUnlock(),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: AppTheme.urgentRed),
                    ),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleUnlock,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Unlock'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/screens/auth/lock_screen.dart
git commit -m "Add lock screen for inactivity timeout"
```

---

## Task 5: GoRouter with Auth Guards

**Files:**
- Create: `lib/config/router.dart`
- Modify: `lib/main.dart`

- [ ] **Step 1: Create router with auth redirect and shell routes**

```dart
// lib/config/router.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/providers/session_providers.dart';
import 'package:shukla_pps/screens/auth/login_screen.dart';
import 'package:shukla_pps/screens/auth/lock_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);
  final isLocked = ref.watch(isLockedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final loggingIn = state.matchedLocation == '/login';

      if (!isAuthenticated) {
        return loggingIn ? null : '/login';
      }

      if (isLocked) {
        return state.matchedLocation == '/lock' ? null : '/lock';
      }

      if (loggingIn || state.matchedLocation == '/lock') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockScreen(),
      ),
      // App shell with bottom tabs — defined in Plan 4
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Home — Coming in Plan 4')),
        ),
      ),
    ],
  );
});
```

- [ ] **Step 2: Update main.dart to use GoRouter**

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shukla_pps/config/app_config.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/config/router.dart';
import 'package:shukla_pps/providers/session_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      ),
    );
  }
}
```

- [ ] **Step 3: Verify app builds**

```bash
flutter analyze
```

Expected: No issues.

- [ ] **Step 4: Commit**

```bash
git add lib/config/router.dart lib/main.dart
git commit -m "Add GoRouter with auth guards, lock screen redirect, and inactivity detection"
```

---

## End of Plan 3

**What we have after completing Plan 3:**
- Auth state management via Riverpod (CurrentUserNotifier)
- Session service with configurable inactivity timeout
- Login screen with email/password, error handling, Shukla branding
- Lock screen overlay for inactivity timeout
- GoRouter with auth redirects (unauthenticated → login, locked → lock screen)
- User interaction resets inactivity timer via GestureDetector wrapper

**Next:** Implementation Plan 4 — Navigation Shell & Home Screens
