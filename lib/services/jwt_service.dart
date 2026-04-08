import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:math';

class JwtService {
  static const String _privateKey =
      'POH_MVP_SECRET_KEY_2024_PLEASE_CHANGE_ME';

  static String generateJwt({
    required double behaviorScore,
  }) {
    final nullifier = _generateNullifier();
    final deviceHash = _generateDeviceHash();

    final jwt = JWT(
      {
        'nullifier': nullifier,
        'device_hash': deviceHash,
        'behavior_score': behaviorScore,
      },
    );

    return jwt.sign(
      SecretKey(_privateKey),
      expiresIn: const Duration(hours: 24),
      algorithm: JWTAlgorithm.HS256,
    );
  }

  static String _generateNullifier() {
    final random = Random.secure();
    final bytes =
        List<int>.generate(32, (_) => random.nextInt(256));
    return '0x${bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join()}';
  }

  static String _generateDeviceHash() {
    final random = Random.secure();
    final bytes =
        List<int>.generate(32, (_) => random.nextInt(256));
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }
}
