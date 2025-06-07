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
            child: AnimatedCelebration(win: win),
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

class AnimatedCelebration extends StatefulWidget {
  final bool win;
  const AnimatedCelebration({super.key, required this.win});

  @override
  State<AnimatedCelebration> createState() => _AnimatedCelebrationState();
}

class _AnimatedCelebrationState extends State<AnimatedCelebration>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _rotation;
  late Animation<Color?> _color;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _scale = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInCubic),
    );

    _rotation = Tween<double>(begin: -0.2, end: 0.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.1, 0.9, curve: Curves.easeInOutSine),
      ),
    );

    _color = ColorTween(
      begin: widget.win
          ? Colors.amber.withOpacity(0.5)
          : Colors.red.withOpacity(0.5),
      end: widget.win ? Colors.amber : Colors.red,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Efecto de destello/brillo de fondo
                if (_controller.value < 0.8)
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.win
                          ? Colors.amber
                              .withOpacity(0.1 * (1 - _controller.value))
                          : Colors.red
                              .withOpacity(0.05 * (1 - _controller.value)),
                    ),
                  ),

                Transform.scale(
                  scale: _scale.value,
                  child: Transform.rotate(
                    angle: _rotation.value,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        3,
                        (i) {
                          // Animación escalonada para cada icono
                          final delay = i * 0.15;
                          final iconAnimation = Tween<double>(
                            begin: 0,
                            end: 1,
                          ).animate(
                            CurvedAnimation(
                              parent: _controller,
                              curve: Interval(
                                delay.clamp(0, 0.7),
                                1.0,
                                curve: Curves.elasticOut,
                              ),
                            ),
                          );

                          return ScaleTransition(
                            scale: iconAnimation,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                widget.win ? Icons.star : Icons.heart_broken,
                                color: _color.value,
                                size: 70,
                                shadows: [
                                  Shadow(
                                    color: widget.win
                                        ? Colors.amber.withOpacity(0.7)
                                        : Colors.red.withOpacity(0.7),
                                    blurRadius: 20,
                                    offset: const Offset(0, 0),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
