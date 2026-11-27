import 'package:flutter/material.dart';

class PokeetFloatingNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const PokeetFloatingNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _icons = [
    Icons.home_rounded,
    Icons.swap_horizontal_circle_outlined,
    Icons.pie_chart_outline_rounded,
    Icons.edit_note_rounded,
    Icons.settings_outlined,
  ];

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
            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: currentIndex * itemW + (itemW - 52) / 2,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(22),
                        topRight: Radius.circular(28),
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(20),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF00D9A8), Color(0xFF00A884)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00FFCC).withValues(alpha: 0.32),
                          blurRadius: 16,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_icons.length, (i) {
                    final active = i == currentIndex;
                    return Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onTap(i),
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
                                    ? (isDark ? Colors.white : const Color(0xFF06402B))
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
            );
          },
        ),
      ),
    );
  }
}
