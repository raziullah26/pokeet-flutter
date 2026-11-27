import 'package:flutter/material.dart';
import '../utils/formatters.dart';

class AnimatedMoneyCounter extends StatelessWidget {
  final double value;
  final TextStyle style;
  final bool isEn;
  final bool hide;
  final bool showSign;

  const AnimatedMoneyCounter({
    super.key,
    required this.value,
    required this.style,
    this.isEn = false,
    this.hide = false,
    this.showSign = false,
  });

  @override
  Widget build(BuildContext context) {
    if (hide) {
      return Text('****', style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, val, _) {
        return Text(
          PokeetFmt.money(val, isEn: isEn, hide: hide, showSign: showSign),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        );
      },
    );
  }
}
