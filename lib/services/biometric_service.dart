import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// Check whether device supports biometrics or device auth
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      return (canCheck || supported);
    } catch (_) {
      return false;
    }
  }

  /// Authenticate using biometrics (allow PIN as fallback)
  static Future<bool> authenticate({String reason = 'Autentikasi untuk masuk'}) async {
    try {
      final didAuth = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          biometricOnly: false, // allow device PIN fallback
          stickyAuth: false,
        ),
      );
      return didAuth;
    } catch (e) {
      return false;
    }
  }
}
