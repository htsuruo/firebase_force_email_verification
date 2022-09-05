import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_force_email_verification/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:tsuruo_kit/tsuruo_kit.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 44),
          child: EmailForm(
            action: AuthAction.signIn,
            onSubmit: (email, password) async {
              try {
                final credential =
                    await ref.read(progressController).executeWithProgress(
                          () =>
                              FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          ),
                        );
                logger.info(credential);
                // Blocking Functionsで弾かれた場合はFirebaseAuthExceptionでcatchできるものの
                // `code`はundefinedになってしまっていて、全てmessageにStringで入ってしまうので注意。
                // 改善されるとは思いつつ。
              } on FirebaseAuthException catch (e) {
                final isBlocking = e.message?.contains(
                      'BLOCKING_FUNCTION_ERROR_RESPONSE',
                    ) ??
                    false;
                logger.info('isBlocking: $isBlocking');
                if (isBlocking) {
                  ref
                      .read(scaffoldMessengerKey)
                      .currentState!
                      .showMessage('BLOCKING_FUNCTION_ERROR');
                  return;
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
