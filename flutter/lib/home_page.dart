import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:tsuruo_kit/tsuruo_kit.dart';

final userProvider = StreamProvider<User?>((ref) {
  // MFAの有効/無効の変更を受けたいので`authStateChange`ではなくsupersetの`userChanges`を使う
  return FirebaseAuth.instance.userChanges();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: user == null
          ? const SizedBox.shrink()
          : SingleChildScrollView(
              child: Column(
                children: [
                  const Divider(),
                  const Divider(),
                  const Gap(44),
                  ElevatedButton(
                    onPressed: () async {
                      await ref.read(progressController).executeWithProgress(
                            () => FirebaseAuth.instance.signOut(),
                          );
                    },
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
    );
  }
}
