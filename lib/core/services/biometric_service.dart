import 'dart:io';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

typedef BiometricInfo = ({String label, IconData icon});

class BiometricService {
  static final _auth = LocalAuthentication();

  static Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<BiometricInfo> getBiometricInfo() async {
    try {
      final biometrics = await _auth.getAvailableBiometrics();
      if (Platform.isAndroid) {
        if (biometrics.contains(BiometricType.fingerprint)) {
          return (label: 'Vân tay', icon: Icons.fingerprint_rounded);
        }
        if (biometrics.contains(BiometricType.face)) {
          return (label: 'Khuôn mặt', icon: Icons.face_retouching_natural_rounded);
        }
      } else {
        if (biometrics.contains(BiometricType.face)) {
          return (label: 'Face ID', icon: Icons.face_retouching_natural_rounded);
        }
        if (biometrics.contains(BiometricType.fingerprint)) {
          return (label: 'Vân tay', icon: Icons.fingerprint_rounded);
        }
      }
    } catch (_) {}
    return Platform.isAndroid
        ? (label: 'Vân tay', icon: Icons.fingerprint_rounded)
        : (label: 'Sinh trắc học', icon: Icons.lock_open_rounded);
  }

  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Xác thực để đăng nhập Folkify',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
