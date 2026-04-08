import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/jwt_service.dart';

enum VerifyState { idle, challenge, verified, error }

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});
  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen>
    with TickerProviderStateMixin {
  VerifyState _state = VerifyState.idle;
  String? _jwt;
  double _dotX = 0.5;
  double _dotY = 0.5;
  int _tapsCorrect = 0;

  void _startChallenge() {
    setState(() {
      _state = VerifyState.challenge;
      _tapsCorrect = 0;
    });
    _moveDot();
  }

  void _moveDot() {
    final random = Random();
    setState(() {
      _dotX = 0.1 + random.nextDouble() * 0.8;
      _dotY = 0.1 + random.nextDouble() * 0.8;
    });
  }

  void _onDotTapped() {
    if (_state != VerifyState.challenge) return;
    setState(() => _tapsCorrect++);
    if (_tapsCorrect >= 5) {
      _completeChallenge();
    } else {
      _moveDot();
    }
  }

  Future<void> _completeChallenge() async {
    try {
      final score = _tapsCorrect / 5.0;
      if (score >= 0.85) {
        final jwt = await JwtService.generateJwt(
          behaviorScore: score,
        );
        if (mounted) {
          setState(() {
            _jwt = jwt;
            _state = VerifyState.verified;
          });
        }
      } else {
        if (mounted) setState(() => _state = VerifyState.error);
      }
    } catch (e) {
      if (mounted) setState(() => _state = VerifyState.error);
    }
  }

  void _copyToken() {
    if (_jwt != null) {
      Clipboard.setData(ClipboardData(text: _jwt!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Token copied!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case VerifyState.idle:
        return _buildIdle();
      case VerifyState.challenge:
        return _buildChallenge();
      case VerifyState.verified:
        return _buildVerified();
      case VerifyState.error:
        return _buildError();
    }
  }

  Widget _buildIdle() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fingerprint,
              size: 120, color: Color(0xFF00D4FF)),
          const SizedBox(height: 32),
          const Text('Proof of Human',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 16),
          const Text('No KYC. No orb scan.\nJust your phone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, color: Colors.white60)),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: _startChallenge,
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D4FF),
                padding: const EdgeInsets.symmetric(
                    horizontal: 48, vertical: 16)),
            child: const Text('Verify Human',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildChallenge() {
    return Column(
      children: [
        const Text('Tap the dot!',
            style: TextStyle(fontSize: 24, color: Colors.white)),
        const SizedBox(height: 16),
        Text('$_tapsCorrect / 5',
            style: const TextStyle(
                fontSize: 18, color: Color(0xFF00D4FF))),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onTapDown: (details) {
                  final box =
                      context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final local = box.globalToLocal(
                      details.globalPosition);
                  final dx = local.dx / constraints.maxWidth;
                  final dy = local.dy / constraints.maxHeight;
                  if ((dx - _dotX).abs() < 0.15 &&
                      (dy - _dotY).abs() < 0.15) {
                    _onDotTapped();
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: Stack(
                    children: [
                      Positioned(
                        left: _dotX * constraints.maxWidth - 25,
                        top: _dotY * constraints.maxHeight - 25,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                              color: Color(0xFF00D4FF),
                              shape: BoxShape.circle),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVerified() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified,
              size: 80, color: Color(0xFF00D4FF)),
          const SizedBox(height: 24),
          const Text('Human Verified!',
              style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          if (_jwt != null) ...[
            QrImageView(
                data: _jwt!,
                size: 200,
                backgroundColor: Colors.white),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _copyToken,
              icon: const Icon(Icons.copy),
              label: const Text('Copy Token'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7B2FFF)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {
                _state = VerifyState.idle;
                _jwt = null;
              }),
              child: const Text('Verify Again'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              size: 80, color: Colors.red),
          const SizedBox(height: 24),
          const Text('Verification Failed',
              style: TextStyle(
                  fontSize: 24, color: Colors.white)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {
              _state = VerifyState.idle;
              _tapsCorrect = 0;
            }),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
