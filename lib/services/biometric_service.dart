import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();

  factory BiometricService() {
    return _instance;
  }

  BiometricService._internal();

  static BiometricService get instance => _instance;

  final LocalAuthentication _auth = LocalAuthentication();
  final Logger _logger = Logger();

  // Check if hardware is capable of biometric authentication
  Future<bool> canAuthenticate() async {
    try {
      final bool canCheckBiometrics = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      _logger.e('Error checking biometric support: $e');
      return false;
    }
  }

  // Trigger prompt
  Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Scan fingerprint or Face ID to log into SehatMok',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      _logger.e('Error during biometric authentication: $e');
      return false;
    }
  }
}
