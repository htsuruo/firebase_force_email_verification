import 'package:app_links/app_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_force_email_verification/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLinksProvider = StreamProvider((ref) => AppLinks().uriLinkStream);

class EmailVerificationPage extends ConsumerWidget {
  const EmailVerificationPage({super.key});

  static const routeName = 'email_verification';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(
      appLinksProvider,
      (previous, next) {
        final uri = next.value;
        logger.info(uri);
        if (uri == null) {
          return;
        }
        final params = uri.queryParameters;
        final code = params['oobCode'].toString();
        logger
          ..info('mode: ${params['mode']}')
          ..info('oobCode: $code')
          ..info('continueUrl: ${params['continueUrl']}')
          ..info('lang: ${params['lang']}');
        FirebaseAuth.instance.applyActionCode(code);
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
      ),
      body: const Center(
        child: Text('メール認証してください'),
      ),
    );
  }
}
