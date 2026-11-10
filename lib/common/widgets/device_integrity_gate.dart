import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Release builds check the device before showing the app (security review
/// finding 7): a rooted or jailbroken device gets a warning the user must
/// accept. Emulators are allowed. Debug and profile builds skip the check.
///
/// These on-device checks are deterrents and can be bypassed; the backend
/// still validates everything. If the check itself fails, the app opens.
class DeviceIntegrityGate extends StatefulWidget {
  const DeviceIntegrityGate({super.key, required this.child});

  final Widget child;

  @override
  State<DeviceIntegrityGate> createState() => _DeviceIntegrityGateState();
}

enum _Status { checking, ok, rooted }

class _DeviceIntegrityGateState extends State<DeviceIntegrityGate> {
  static const _channel = MethodChannel('device_integrity');

  _Status _status = kReleaseMode ? _Status.checking : _Status.ok;

  @override
  void initState() {
    super.initState();
    if (_status == _Status.checking) _check();
  }

  Future<void> _check() async {
    var status = _Status.ok;
    try {
      final result = await _channel.invokeMapMethod<String, bool>('check');
      if (result?['rooted'] == true) {
        status = _Status.rooted;
      }
    } catch (_) {
      // Fail open: a missing or broken check must not lock users out.
    }
    if (mounted) setState(() => _status = status);
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case _Status.ok:
        return widget.child;
      case _Status.checking:
        return const _Screen(child: Center(child: CircularProgressIndicator()));
      case _Status.rooted:
        return _Screen(
          child: _Message(
            icon: Icons.warning_amber_rounded,
            title: 'This device may be rooted',
            body: 'Postura found signs that this device is rooted or '
                'jailbroken. Other apps on it may be able to read your '
                'assessment data and photos. Use an unmodified device if you '
                'can.',
            action: FilledButton(
              onPressed: () => setState(() => _status = _Status.ok),
              child: const Text('I understand, continue'),
            ),
          ),
        );
    }
  }
}

class _Screen extends StatelessWidget {
  const _Screen({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(body: SafeArea(child: child)),
  );
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 56, color: Colors.orange),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(body, textAlign: TextAlign.center),
        if (action != null) ...[const SizedBox(height: 24), action!],
      ],
    ),
  );
}
