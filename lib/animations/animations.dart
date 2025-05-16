import 'package:flutter/material.dart';

class BouncingCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const BouncingCard({super.key, required this.child, this.onTap});

  @override
  State<BouncingCard> createState() => _BouncingCardState();
}

class _BouncingCardState extends State<BouncingCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);
  }

  void _animateOnTap() async {
    await _controller.animateTo(0.0, duration: const Duration(milliseconds: 80), curve: Curves.easeOut);
    await _controller.animateTo(1.0, duration: const Duration(milliseconds: 120), curve: Curves.elasticOut);
    if (widget.onTap != null) widget.onTap!();
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