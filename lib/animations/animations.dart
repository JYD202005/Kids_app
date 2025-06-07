import 'package:flutter/material.dart';

class BouncingCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const BouncingCard({super.key, required this.child, this.onTap});

  @override
  _BouncingCardState createState() => _BouncingCardState();
}

class _BouncingCardState extends State<BouncingCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);

    _startBouncingAnimation();
  }

  void _startBouncingAnimation() {
    if (_controller.isAnimating) _controller.stop();
    _controller.value = 0.0;
    _controller.repeat(reverse: true);
  }

  void _animateOnTap() async {
    // Detener la animación de rebote
    _controller.stop();

    // Animación al hacer tap
    await _controller.animateTo(0.0,
        duration: const Duration(milliseconds: 80), curve: Curves.easeOut);
    await _controller.animateTo(1.0,
        duration: const Duration(milliseconds: 120), curve: Curves.elasticOut);

    if (widget.onTap != null) widget.onTap!();

    // Volver a la animación de rebote después de un pequeño retraso
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _startBouncingAnimation();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _animateOnTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

class FlipCard extends StatefulWidget {
  final bool flipped;
  final Widget front;
  final Widget back;
  final Duration duration;
  final VoidCallback? onTap;

  const FlipCard({
    super.key,
    required this.flipped,
    required this.front,
    required this.back,
    this.duration = const Duration(milliseconds: 350),
    this.onTap,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      value: widget.flipped ? 1.0 : 0.0,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void didUpdateWidget(covariant FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.flipped != oldWidget.flipped) {
      if (widget.flipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap != null) widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * 3.1416;
          final isFront = _animation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? widget.back
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(3.1416),
                    child: widget.front,
                  ),
          );
        },
      ),
    );
  }
}

class CelebrationOverlay {
  static void show(BuildContext context, {required bool win}) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            child: _AnimatedCelebration(win: win),
          ),
        );
      },
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () {
      entry.remove();
    });
  }
}

class _AnimatedCelebration extends StatefulWidget {
  final bool win;
  const _AnimatedCelebration({required this.win});

  @override
  State<_AnimatedCelebration> createState() => _AnimatedCelebrationState();
}

class _AnimatedCelebrationState extends State<_AnimatedCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.win ? Colors.amber : Colors.redAccent;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Transform.scale(
                scale: _scale.value * 1.2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(
                    3,
                    (i) => Icon(
                      widget.win ? Icons.star : Icons.heart_broken,
                      color: widget.win ? Colors.amber : Colors.red,
                      size: 70, // Más grandes
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
