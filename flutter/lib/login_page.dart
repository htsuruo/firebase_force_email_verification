import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_force_email_verification/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/auth.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final link = ref.watch(appLinksProvier).value;
    final link2 = ref.watch(appLinksLatestProvier).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: EmailForm(
            action: AuthAction.signUp,
            onSubmit: (email, password) async {
              try {
                final credential =
                    await FirebaseAuth.instance.createUserWithEmailAndPassword(
                  email: email,
                  password: password,
                );
                logger.info(credential);
                // Blocking Functionsで弾かれた場合はFirebaseAuthExceptionでcatchできるものの
                // `code`はundefinedになってしまっていて、全てmessageにStringで入ってしまうので注意。
                // 改善されるとは思いつつ。
              } on FirebaseAuthException catch (e) {
                final isBlocking = e.message?.contains(
                  'BLOCKING_FUNCTION_ERROR_RESPONSE',
                );
                logger.info('isBlocking: $isBlocking');
              }
            },
          ),
        ),
      ),
    );
  }
}

final appLinksProvier = StreamProvider((ref) => AppLinks().uriLinkStream);
final appLinksLatestProvier =
    FutureProvider((ref) => AppLinks().getLatestAppLink());
