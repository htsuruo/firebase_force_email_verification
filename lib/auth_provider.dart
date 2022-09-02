import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = Provider(Authenticator.new);

class Authenticator {
  const Authenticator(this._ref);
  final Ref _ref;

  // Future<void> signIn() => _authenticateWithGoogle(
  //       f: (credential) =>
  //           FirebaseAuth.instance.signInWithCredential(credential),
  //     );

}
