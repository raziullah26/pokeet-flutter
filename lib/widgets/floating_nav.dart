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
  static const _icons = [
    Icons.home_rounded,
    Icons.swap_horizontal_circle_outlined,
    Icons.pie_chart_outline_rounded,
    Icons.edit_note_rounded,
    Icons.settings_outlined,
  ];

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
    List<double> k0 = [0.40, 0.60, 0.70, 0.30, 0.40, 0.50, 0.60, 0.50];
    List<double> k1 = [0.70, 0.30, 0.50, 0.50, 0.30, 0.30, 0.70, 0.70];
    List<double> k2 = [1.00, 0.60, 0.60, 1.00, 1.00, 1.00, 0.60, 0.60];

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
            final itemW = constraints.maxWidth / _icons.length;
            final sx = math.min(1.35, 1.0 + _v.abs() * 3.2);
            final sy = math.max(0.75, 1.0 - _v.abs() * 1.6);

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (d) {
                _dragging = true;
                _springTicker.stop();
                _v = 0;
              },
              onHorizontalDragUpdate: (d) {
                final nx = ((d.localPosition.dx - itemW / 2) / itemW)
                    .clamp(0.0, (_icons.length - 1).toDouble());
                setState(() {
                  _v = (nx - _x) * 0.5;
                  _x = nx;
                });
              },
              onHorizontalDragEnd: (_) {
                _dragging = false;
                final idx = _x.round().clamp(0, _icons.length - 1);
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
                    children: List.generate(_icons.length, (i) {
                      final active = i == widget.currentIndex;
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
                                child: Icon(
                                  _icons[i],
                                  size: 26,
                                  color: active
                                      ? (isDark
                                          ? Colors.white
                                          : const Color(0xFF06402B))
                                      : (isDark
                                          ? const Color(0xFF8FA59D)
                                          : const Color(0xFF5F6B7A)),
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
