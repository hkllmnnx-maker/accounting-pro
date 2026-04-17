import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';

/// شاشة قفل التطبيق برمز PIN
class LockScreen extends StatefulWidget {
  final bool isSetup; // true = إنشاء رمز جديد، false = إدخال للفتح
  const LockScreen({super.key, this.isSetup = false});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String? _error;

  void _onKeyPressed(String digit) {
    setState(() {
      _error = null;
      if (widget.isSetup && _isConfirming) {
        if (_confirmPin.length < 4) _confirmPin += digit;
        if (_confirmPin.length == 4) _validateSetup();
      } else {
        if (_pin.length < 4) _pin += digit;
        if (_pin.length == 4) {
          if (widget.isSetup) {
            setState(() => _isConfirming = true);
          } else {
            _validateLogin();
          }
        }
      }
    });
  }

  void _onBackspace() {
    setState(() {
      _error = null;
      if (widget.isSetup && _isConfirming) {
        if (_confirmPin.isNotEmpty) {
          _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        }
      } else {
        if (_pin.isNotEmpty) _pin = _pin.substring(0, _pin.length - 1);
      }
    });
  }

  void _validateSetup() async {
    if (_pin == _confirmPin) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      await provider.setLockPin(_pin);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _error = 'الرموز غير متطابقة، أعد المحاولة';
        _pin = '';
        _confirmPin = '';
        _isConfirming = false;
      });
    }
  }

  void _validateLogin() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.verifyLockPin(_pin)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        _error = 'رمز القفل غير صحيح';
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayPin = widget.isSetup && _isConfirming ? _confirmPin : _pin;
    final title = widget.isSetup
        ? (_isConfirming ? 'أكد رمز القفل' : 'أنشئ رمز قفل')
        : 'أدخل رمز القفل';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.lock, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Accounting Pro',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (i) {
                  final filled = i < displayPin.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: filled ? Colors.white : Colors.transparent,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.yellowAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: _buildKeypad(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: [
        for (final row in const [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((d) => _keyButton(d)).toList(),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 70, height: 70),
              _keyButton('0'),
              SizedBox(
                width: 70,
                height: 70,
                child: IconButton(
                  icon: const Icon(Icons.backspace, size: 28),
                  onPressed: _onBackspace,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _keyButton(String digit) {
    return SizedBox(
      width: 70,
      height: 70,
      child: ElevatedButton(
        onPressed: () => _onKeyPressed(digit),
        style: ElevatedButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        child: Text(digit, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
