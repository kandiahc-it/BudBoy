import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/budget_provider.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isTransitionTimerDone = false;
  bool _isTypingComplete = false;
  bool _hasTransitioned = false;

  @override
  void initState() {
    super.initState();
    _startTransitionTimer();
  }

  void _startTransitionTimer() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isTransitionTimerDone = true;
        });
        _checkAndTransition();
      }
    });
  }

  void _onTypingComplete() {
    if (mounted) {
      setState(() {
        _isTypingComplete = true;
      });
      _checkAndTransition();
    }
  }

  void _checkAndTransition() {
    if (!_isTransitionTimerDone || !_isTypingComplete) return;
    if (_hasTransitioned) return;

    final provider = Provider.of<BudgetProvider>(context, listen: false);
    if (!provider.isLoading) {
      _hasTransitioned = true;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const DashboardScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      // Retry in 100ms if provider is still reading from SharedPreferences
      Future.delayed(const Duration(milliseconds: 100), _checkAndTransition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A), // Deep Slate
              Color(0xFF1E1B4B), // Indigo Tint
              Color(0xFF311062), // Royal Purple Tint
            ],
            stops: [0.1, 0.6, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo Container with bounce scale/fade animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7C3AED).withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.query_stats_rounded,
                  color: Colors.white,
                  size: 55,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // typing animated Title
            TypingText(
              text: 'BudBoy',
              style: const TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
              charDuration: const Duration(milliseconds: 120),
              onComplete: _onTypingComplete,
            ),
            const SizedBox(height: 12),
            // Tagline that fades in once typing is complete
            AnimatedOpacity(
              opacity: _isTypingComplete ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: const Text(
                'Track • Filter • Grow',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF94A3B8), // Slate-400
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypingText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Duration charDuration;
  final VoidCallback? onComplete;

  const TypingText({
    super.key,
    required this.text,
    required this.style,
    this.charDuration = const Duration(milliseconds: 150),
    this.onComplete,
  });

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  String _displayedText = '';
  int _currentIndex = 0;
  Timer? _typingTimer;
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _startCursorBlink();
  }

  void _startTyping() {
    _typingTimer = Timer.periodic(widget.charDuration, (timer) {
      if (_currentIndex < widget.text.length) {
        setState(() {
          _displayedText += widget.text[_currentIndex];
          _currentIndex++;
        });
      } else {
        _typingTimer?.cancel();
        _cursorTimer?.cancel();
        setState(() {
          _showCursor = false;
        });
        widget.onComplete?.call();
      }
    });
  }

  void _startCursorBlink() {
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 450), (timer) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _displayedText,
          style: widget.style,
        ),
        Opacity(
          opacity: _showCursor ? 1.0 : 0.0,
          child: Text(
            '|',
            style: widget.style.copyWith(
              fontWeight: FontWeight.w200,
              color: const Color(0xFF0D9488), // Neon Teal cursor
            ),
          ),
        ),
      ],
    );
  }
}
