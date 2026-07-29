import 'package:flutter/material.dart';

class BouncingLogo extends StatefulWidget {
  final String imageAsset;
  final double width;
  final double height;
  final double speed;
  final bool enabled;

  const BouncingLogo({
    super.key,
    required this.imageAsset,
    this.width = 180,
    this.height = 99,
    this.speed = 2.0,
    this.enabled = true,
  });

  @override
  State<BouncingLogo> createState() => _BouncingLogoState();
}

class _BouncingLogoState extends State<BouncingLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _x = 100;
  double _y = 100;
  late double _dx;
  late double _dy;

  @override
  void initState() {
    super.initState();
    _dx = widget.speed;
    _dy = widget.speed * 0.9;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    );
    _controller.addListener(_tick);
    _controller.repeat();
  }

  void _tick() {
    if (!widget.enabled) return;
    final mw = MediaQuery.of(context).size.width - widget.width;
    final mh = MediaQuery.of(context).size.height - widget.height;

    setState(() {
      _x += _dx;
      _y += _dy;
      if (_x <= 0 || _x >= mw) {
        _dx = -_dx;
        _x = _x.clamp(0.0, mw);
      }
      if (_y <= 0 || _y >= mh) {
        _dy = -_dy;
        _y = _y.clamp(0.0, mh);
      }
    });
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();
    return Positioned(
      left: _x,
      top: _y,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Image.asset(
          widget.imageAsset,
          fit: BoxFit.contain,
          errorBuilder: (_, error, stackTrace) => const SizedBox.shrink(),
        ),
      ),
    );
  }
}