import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_force_email_verification/email_verification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:touch_indicator/touch_indicator.dart';
import 'package:tsuruo_kit/tsuruo_kit.dart';

import 'home_page.dart';
import 'login_page.dart';

final routerProvider = Provider((ref) {
  final router = RouterNotifier(ref);
  return GoRouter(
    debugLogDiagnostics: true,
    refreshListenable: router,
    routes: router._routes,
    redirect: router._redirectLogic,
    navigatorBuilder: (context, state, child) => TouchIndicator(
      child: ProgressHUD(child: child),
    ),
  );
});

// ref. https://github.com/lucavenir/go_router_riverpod/blob/master/lib/router.dart
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<User?>(
      userProvider.select((userAsync) => userAsync.value),
      (previous, user) {
        // listen対象が`userChanges`なので、ユーザーが切り替わった場合のみnotifyするよう間引く
        if (previous?.uid != user?.uid) {
          notifyListeners();
        }
      },
    );
  }

  final Ref _ref;

  static const _home = '/';
  static const _login = '/login';

  List<GoRoute> get _routes => [
        GoRoute(
          name: 'home',
          path: _home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          name: EmailVerificationPage.routeName,
          path: '/${EmailVerificationPage.routeName}',
          builder: (context, state) => const EmailVerificationPage(),
        ),
        GoRoute(
          name: 'login',
          path: _login,
          // docs. https://gorouter.dev/transitions#custom-transitions
          // ref. https://github.com/flutter/packages/blob/main/packages/go_router/example/lib/others/transitions.dart
          pageBuilder: (context, state) => CustomTransitionPage<void>(
            key: state.pageKey,
            child: const LoginPage(),
            transitionsBuilder: (context, animation, _, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        ),
      ];

  String? _redirectLogic(GoRouterState state) {
    final user = _ref.read(userProvider).valueOrNull;
    // 未認証時は`/login`へリダイレクト
    if (user == null) {
      return state.location == _login ? null : _login;
    }

    // 認証時で`/login`のままだったら`/home`へリダイレクト
    if (state.location == _login) {
      return _home;
    }
    return null;
  }
}
