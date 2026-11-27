import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/pokeet_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class AnalysisScreen extends StatelessWidget {
  final PokeetController ctrl;
  const AnalysisScreen({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final byCat = <String, double>{};
    for (final t in ctrl.txs.where((e) => e.type == 'expense')) {
      byCat[t.catName] = (byCat[t.catName] ?? 0) + t.amount;
    }
    final entries = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    const palette = [
      PokeetColors.orange,
      PokeetColors.blue,
      PokeetColors.purple,
      PokeetColors.redDark,
      PokeetColors.teal,
      PokeetColors.green,
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(ctrl.tr('খাত বিশ্লেষণ', 'Category Analysis'),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(ctrl.tr('কোনো ব্যয় নেই', 'No expenses yet')),
                  )
                else
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 52,
                        sectionsSpace: 3,
                        sections: List.generate(entries.length, (i) {
                          return PieChartSectionData(
                            value: entries[i].value,
                            color: palette[i % palette.length],
                            radius: 36,
                            showTitle: false,
                          );
                        }),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...entries.map((e) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: Text(
                  PokeetFmt.money(e.value, isEn: ctrl.isEn),
                  style: const TextStyle(fontWeight: FontWeight.w800, color: PokeetColors.redDark),
                ),
              ),
            )),
      ],
    );
  }
}
