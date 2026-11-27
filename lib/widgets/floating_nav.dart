import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PokeetFloatingNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PokeetFloatingNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<PokeetFloatingNav> createState() => _PokeetFloatingNavState();
}

class _PokeetFloatingNavState extends State<PokeetFloatingNav>
    with TickerProviderStateMixin {
  late final AnimationController _morphCtrl;
  late final AnimationController _spinCtrl;
  late final Ticker _springTicker;

  double _x = 0;
  double _v = 0;
  double _target = 0;
  bool _dragging = false;
  Duration _lastTick = Duration.zero;

  @override
  void initState() {
    super.initState();
    _x = widget.currentIndex.toDouble();
    _target = _x;

    _morphCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _springTicker = createTicker(_onSpringTick);
  }

  @override
  void didUpdateWidget(covariant PokeetFloatingNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex && !_dragging) {
      _goTo(widget.currentIndex.toDouble());
    }
  }

  void _goTo(double t) {
    _target = t;
    if (!_springTicker.isActive) {
      _lastTick = Duration.zero;
      _springTicker.start();
    }
  }

  void _onSpringTick(Duration elapsed) {
    final dt = _lastTick == Duration.zero
        ? 1.0
        : ((elapsed - _lastTick).inMicroseconds / 16666.0).clamp(0.5, 2.0);
    _lastTick = elapsed;

    _v = (_v + (_target - _x) * 0.14 * dt) * math.pow(0.72, dt);
    _x += _v * dt;

    if (_v.abs() < 0.0006 && (_target - _x).abs() < 0.0034) {
      _x = _target;
      _v = 0;
      _springTicker.stop();
    }
    if (mounted) setState(() {});
  }

  BorderRadius _morphRadius(double t, double size) {
    const k0 = [0.40, 0.60, 0.70, 0.30, 0.40, 0.50, 0.60, 0.50];
    const k1 = [0.70, 0.30, 0.50, 0.50, 0.30, 0.30, 0.70, 0.70];
    const k2 = [1.00, 0.60, 0.60, 1.00, 1.00, 1.00, 0.60, 0.60];

    late List<double> a, b;
    late double p;
    if (t < 0.34) {
      a = k0;
      b = k1;
      p = Curves.easeInOut.transform(t / 0.34);
    } else if (t < 0.67) {
      a = k1;
      b = k2;
      p = Curves.easeInOut.transform((t - 0.34) / 0.33);
    } else {
      a = k2;
      b = k0;
      p = Curves.easeInOut.transform((t - 0.67) / 0.33);
    }

    double lerp(int i) => (a[i] + (b[i] - a[i]) * p) * size;

    return BorderRadius.only(
      topLeft: Radius.elliptical(lerp(0), lerp(4)),
      topRight: Radius.elliptical(lerp(1), lerp(5)),
      bottomRight: Radius.elliptical(lerp(2), lerp(6)),
      bottomLeft: Radius.elliptical(lerp(3), lerp(7)),
    );
  }

  @override
  void dispose() {
    _springTicker.dispose();
    _morphCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, 12 + bottomPad),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          color: isDark ? const Color(0xF0091E16) : const Color(0xF2ECF0FC),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.20)
                : Colors.white.withValues(alpha: 0.90),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.38 : 0.14),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemW = constraints.maxWidth / 5;
            final sx = math.min(1.35, 1.0 + _v.abs() * 3.2);
            final sy = math.max(0.75, 1.0 - _v.abs() * 1.6);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) {
                _dragging = true;
                _springTicker.stop();
                _v = 0;
              },
              onHorizontalDragUpdate: (d) {
                final nx =
                    ((d.localPosition.dx - itemW / 2) / itemW).clamp(0.0, 4.0);
                setState(() {
                  _v = (nx - _x) * 0.5;
                  _x = nx;
                });
              },
              onHorizontalDragEnd: (_) {
                _dragging = false;
                final idx = _x.round().clamp(0, 4);
                _goTo(idx.toDouble());
                if (idx != widget.currentIndex) {
                  widget.onTap(idx);
                }
              },
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    left: _x * itemW + (itemW - 54) / 2,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([_morphCtrl, _spinCtrl]),
                      builder: (context, _) {
                        final br = _morphRadius(_morphCtrl.value, 54);
                        final angle = _spinCtrl.value * 2 * math.pi;
                        return Transform.scale(
                          scaleX: sx,
                          scaleY: sy,
                          child: Transform.rotate(
                            angle: angle,
                            child: Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                borderRadius: br,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF00D9A8), Color(0xFF00A884)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00FFCC)
                                        .withValues(alpha: 0.38),
                                    blurRadius: 18,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: List.generate(5, (i) {
                      final active = i == widget.currentIndex;
                      final iconColor = active
                          ? (isDark ? Colors.white : const Color(0xFF06402B))
                          : (isDark
                              ? const Color(0xFF8FA59D)
                              : const Color(0xFF5F6B7A));
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            _goTo(i.toDouble());
                            widget.onTap(i);
                          },
                          child: SizedBox(
                            height: 64,
                            child: Center(
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 220),
                                scale: active ? 1.12 : 1.0,
                                child: CustomPaint(
                                  size: const Size(26, 26),
                                  painter: _AppJsNavPainter(
                                    index: i,
                                    color: iconColor,
                                    active: active,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AppJsNavPainter extends CustomPainter {
  final int index;
  final Color color;
  final bool active;

  const _AppJsNavPainter({
    required this.index,
    required this.color,
    required this.active,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillSoft = Paint()
      ..color = color.withValues(alpha: active ? 0.30 : 0.0)
      ..style = PaintingStyle.fill;

    switch (index) {
      case 0: // nvhome
        final fl = Path()
          ..moveTo(4.5 * s, 11 * s)
          ..lineTo(12 * s, 4.5 * s)
          ..lineTo(19.5 * s, 11 * s)
          ..lineTo(19.5 * s, 19 * s)
          ..cubicTo(19.5 * s, 19.83 * s, 18.83 * s, 20.5 * s, 18 * s, 20.5 * s)
          ..lineTo(15 * s, 20.5 * s)
          ..lineTo(15 * s, 15 * s)
          ..lineTo(9 * s, 15 * s)
          ..lineTo(9 * s, 20.5 * s)
          ..lineTo(6 * s, 20.5 * s)
          ..cubicTo(5.17 * s, 20.5 * s, 4.5 * s, 19.83 * s, 4.5 * s, 19 * s)
          ..close();
        if (active) canvas.drawPath(fl, fillSoft);
        canvas.drawPath(fl, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(3 * s, 11.5 * s)
            ..lineTo(12 * s, 3.5 * s)
            ..lineTo(21 * s, 11 * s),
          stroke,
        );
        canvas.drawPath(
          Path()
            ..moveTo(9 * s, 20.5 * s)
            ..lineTo(9 * s, 15 * s)
            ..lineTo(15 * s, 15 * s)
            ..lineTo(15 * s, 20.5 * s),
          stroke,
        );
        break;

      case 1: // nvtx
        if (active) {
          canvas.drawCircle(Offset(12 * s, 12 * s), 9 * s, fillSoft);
        }
        canvas.drawCircle(Offset(12 * s, 12 * s), 9 * s, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(7.5 * s, 9.5 * s)
            ..lineTo(16.5 * s, 9.5 * s)
            ..lineTo(13.7 * s, 6.7 * s)
            ..moveTo(16.5 * s, 14.5 * s)
            ..lineTo(7.5 * s, 14.5 * s)
            ..lineTo(10.3 * s, 17.3 * s),
          stroke,
        );
        break;

      case 2: // nvan
        if (active) {
          canvas.drawCircle(Offset(12 * s, 12 * s), 9 * s, fillSoft);
        }
        canvas.drawCircle(Offset(12 * s, 12 * s), 9 * s, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(12 * s, 3 * s)
            ..lineTo(12 * s, 12 * s)
            ..lineTo(21 * s, 12 * s),
          stroke,
        );
        break;

      case 3: // nvnote
        canvas.drawPath(
          Path()
            ..moveTo(4 * s, 7 * s)
            ..lineTo(15 * s, 7 * s)
            ..moveTo(4 * s, 12 * s)
            ..lineTo(11.5 * s, 12 * s)
            ..moveTo(4 * s, 17 * s)
            ..lineTo(9.5 * s, 17 * s),
          stroke,
        );
        final pen = Path()
          ..moveTo(13.2 * s, 18.6 * s)
          ..lineTo(13.8 * s, 15.8 * s)
          ..lineTo(19.8 * s, 9.8 * s)
          ..lineTo(22 * s, 12 * s)
          ..lineTo(16 * s, 18 * s)
          ..close();
        if (active) canvas.drawPath(pen, fillSoft);
        canvas.drawPath(pen, stroke);
        break;

      case 4: // nvset
        final gear = Path()
          ..moveTo(12.2 * s, 2.5 * s)
          ..lineTo(11.8 * s, 2.5 * s)
          ..cubicTo(10.7 * s, 2.5 * s, 9.8 * s, 3.4 * s, 9.8 * s, 4.5 * s)
          ..lineTo(9.8 * s, 4.7 * s)
          ..cubicTo(9.8 * s, 5.4 * s, 9.4 * s, 6.05 * s, 8.8 * s, 6.4 * s)
          ..lineTo(8.4 * s, 6.65 * s)
          ..cubicTo(7.8 * s, 7.0 * s, 7.05 * s, 7.0 * s, 6.45 * s, 6.65 * s)
          ..lineTo(6.3 * s, 6.55 * s)
          ..cubicTo(5.35 * s, 6.0 * s, 4.15 * s, 6.32 * s, 3.6 * s, 7.25 * s)
          ..lineTo(3.4 * s, 7.65 * s)
          ..cubicTo(2.85 * s, 8.6 * s, 3.17 * s, 9.8 * s, 4.1 * s, 10.35 * s)
          ..lineTo(4.25 * s, 10.45 * s)
          ..cubicTo(4.85 * s, 10.8 * s, 5.25 * s, 11.45 * s, 5.25 * s, 12.15 * s)
          ..lineTo(5.25 * s, 12.65 * s)
          ..cubicTo(5.25 * s, 13.35 * s, 4.85 * s, 14.0 * s, 4.25 * s, 14.4 * s)
          ..lineTo(4.1 * s, 14.5 * s)
          ..cubicTo(3.17 * s, 15.05 * s, 2.85 * s, 16.25 * s, 3.4 * s, 17.2 * s)
          ..lineTo(3.6 * s, 17.6 * s)
          ..cubicTo(4.15 * s, 18.53 * s, 5.35 * s, 18.85 * s, 6.3 * s, 18.3 * s)
          ..lineTo(6.45 * s, 18.2 * s)
          ..cubicTo(7.05 * s, 17.85 * s, 7.8 * s, 17.85 * s, 8.4 * s, 18.2 * s)
          ..lineTo(8.8 * s, 18.45 * s)
          ..cubicTo(9.4 * s, 18.8 * s, 9.8 * s, 19.45 * s, 9.8 * s, 20.15 * s)
          ..lineTo(9.8 * s, 20.35 * s)
          ..cubicTo(9.8 * s, 21.45 * s, 10.7 * s, 22.35 * s, 11.8 * s, 22.35 * s)
          ..lineTo(12.2 * s, 22.35 * s)
          ..cubicTo(13.3 * s, 22.35 * s, 14.2 * s, 21.45 * s, 14.2 * s, 20.35 * s)
          ..lineTo(14.2 * s, 20.15 * s)
          ..cubicTo(14.2 * s, 19.45 * s, 14.6 * s, 18.8 * s, 15.2 * s, 18.45 * s)
          ..lineTo(15.6 * s, 18.2 * s)
          ..cubicTo(16.2 * s, 17.85 * s, 16.95 * s, 17.85 * s, 17.55 * s, 18.2 * s)
          ..lineTo(17.7 * s, 18.3 * s)
          ..cubicTo(18.65 * s, 18.85 * s, 19.85 * s, 18.53 * s, 20.4 * s, 17.6 * s)
          ..lineTo(20.6 * s, 17.2 * s)
          ..cubicTo(21.15 * s, 16.25 * s, 20.83 * s, 15.05 * s, 19.9 * s, 14.5 * s)
          ..lineTo(19.75 * s, 14.4 * s)
          ..cubicTo(19.15 * s, 14.0 * s, 18.75 * s, 13.35 * s, 18.75 * s, 12.65 * s)
          ..lineTo(18.75 * s, 12.15 * s)
          ..cubicTo(18.75 * s, 11.45 * s, 19.15 * s, 10.8 * s, 19.75 * s, 10.45 * s)
          ..lineTo(19.9 * s, 10.35 * s)
          ..cubicTo(20.83 * s, 9.8 * s, 21.15 * s, 8.6 * s, 20.6 * s, 7.65 * s)
          ..lineTo(20.4 * s, 7.25 * s)
          ..cubicTo(19.85 * s, 6.32 * s, 18.65 * s, 6.0 * s, 17.7 * s, 6.55 * s)
          ..lineTo(17.55 * s, 6.65 * s)
          ..cubicTo(16.95 * s, 7.0 * s, 16.2 * s, 7.0 * s, 15.6 * s, 6.65 * s)
          ..lineTo(15.2 * s, 6.4 * s)
          ..cubicTo(14.6 * s, 6.05 * s, 14.2 * s, 5.4 * s, 14.2 * s, 4.7 * s)
          ..lineTo(14.2 * s, 4.5 * s)
          ..cubicTo(14.2 * s, 3.4 * s, 13.3 * s, 2.5 * s, 12.2 * s, 2.5 * s)
          ..close();
        if (active) canvas.drawPath(gear, fillSoft);
        canvas.drawPath(gear, stroke);
        canvas.drawCircle(Offset(12 * s, 12 * s), 3 * s, stroke);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _AppJsNavPainter oldDelegate) =>
      oldDelegate.index != index ||
      oldDelegate.color != color ||
      oldDelegate.active != active;
}
