import 'package:flutter/material.dart';
import '../models/pokeet_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/animated_counter.dart';

class HomeScreen extends StatelessWidget {
  final PokeetController ctrl;
  final void Function(String type) onAddTx;

  const HomeScreen({super.key, required this.ctrl, required this.onAddTx});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final red = isDark ? PokeetColors.redDark : PokeetColors.redLight;
    final today = DateTime.now();
    final todayTxs = ctrl.txs.where((t) {
      final d = DateTime.fromMillisecondsSinceEpoch(t.dateMs);
      return d.year == today.year && d.month == today.month && d.day == today.day;
    }).toList();
    final todayInc = todayTxs.where((t) => t.type == 'income').fold(0.0, (s, t) => s + t.amount);
    final todayExp = todayTxs.where((t) => t.type == 'expense').fold(0.0, (s, t) => s + t.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ctrl.tr('স্বাগতম,', 'Welcome,'), style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                Text(
                  ctrl.userName,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: PokeetColors.green),
                ),
              ],
            ),
            CircleAvatar(
              radius: 22,
              backgroundColor: PokeetColors.green.withValues(alpha: 0.2),
              child: Text(
                ctrl.userName.isNotEmpty ? ctrl.userName[0].toUpperCase() : 'P',
                style: const TextStyle(fontWeight: FontWeight.w800, color: PokeetColors.green),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ctrl.tr('মোট ব্যালেন্স', 'Total Balance'), style: const TextStyle(fontSize: 13)),
                    IconButton(
                      onPressed: ctrl.toggleHideBalance,
                      icon: Icon(ctrl.hideBalance ? Icons.visibility_off : Icons.visibility, size: 20),
                    ),
                  ],
                ),
                AnimatedMoneyCounter(
                  value: ctrl.totalBalance,
                  isEn: ctrl.isEn,
                  hide: ctrl.hideBalance,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: ctrl.totalBalance < 0 ? red : PokeetColors.green,
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.arrow_upward_rounded,
                        color: PokeetColors.green,
                        label: ctrl.tr('মোট আয়', 'Total Income'),
                        amount: PokeetFmt.money(ctrl.totalIncome, isEn: ctrl.isEn, hide: ctrl.hideBalance),
                      ),
                    ),
                    Expanded(
                      child: _MiniStat(
                        icon: Icons.arrow_downward_rounded,
                        color: red,
                        label: ctrl.tr('মোট ব্যয়', 'Total Expense'),
                        amount: PokeetFmt.money(ctrl.totalExpense, isEn: ctrl.isEn, hide: ctrl.hideBalance),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _BentoAction(
                icon: Icons.arrow_upward_rounded,
                title: ctrl.tr('আয় যোগ করুন', 'Add Income'),
                subtitle: ctrl.tr('নতুন আয় রেকর্ড', 'New income'),
                color: PokeetColors.green,
                onTap: () => onAddTx('income'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BentoAction(
                icon: Icons.arrow_downward_rounded,
                title: ctrl.tr('ব্যয় যোগ করুন', 'Add Expense'),
                subtitle: ctrl.tr('নতুন খরচ রেকর্ড', 'New expense'),
                color: red,
                onTap: () => onAddTx('expense'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ctrl.tr('আজকের সারসংক্ষেপ', "Today's Summary"),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _TodayTile(
                        label: ctrl.tr('আজ আয়', 'Today Inc'),
                        value: PokeetFmt.money(todayInc, isEn: ctrl.isEn, hide: ctrl.hideBalance),
                        color: PokeetColors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TodayTile(
                        label: ctrl.tr('আজ ব্যয়', 'Today Exp'),
                        value: PokeetFmt.money(todayExp, isEn: ctrl.isEn, hide: ctrl.hideBalance),
                        color: red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _TodayTile(
                        label: ctrl.tr('লেনদেন', 'Txns'),
                        value: PokeetFmt.toDigits('${todayTxs.length}', ctrl.isEn),
                        color: PokeetColors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: () => _showBudgetDialog(context),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(ctrl.tr('মাসিক বাজেট', 'Monthly Budget'),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(
                        ctrl.monthlyBudget > 0
                            ? '${PokeetFmt.toDigits(((ctrl.totalExpense / ctrl.monthlyBudget) * 100).round().toString(), ctrl.isEn)}%'
                            : ctrl.tr('সেট করুন +', 'Set +'),
                        style: const TextStyle(fontWeight: FontWeight.w800, color: PokeetColors.green),
                      ),
                    ],
                  ),
                  if (ctrl.monthlyBudget > 0) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (ctrl.totalExpense / ctrl.monthlyBudget).clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: Colors.black.withValues(alpha: 0.2),
                        color: ctrl.totalExpense > ctrl.monthlyBudget ? red : PokeetColors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showBudgetDialog(BuildContext context) {
    final tc = TextEditingController(text: ctrl.monthlyBudget > 0 ? ctrl.monthlyBudget.toStringAsFixed(0) : '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ctrl.tr('মাসিক বাজেট (৳)', 'Monthly Budget (৳)')),
        content: TextField(controller: tc, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(ctrl.tr('বাতিল', 'Cancel'))),
          FilledButton(
            onPressed: () {
              final v = double.tryParse(tc.text.trim()) ?? 0;
              ctrl.setBudget(v);
              Navigator.pop(context);
            },
            child: Text(ctrl.tr('সংরক্ষণ', 'Save')),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String amount;
  const _MiniStat({required this.icon, required this.color, required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withValues(alpha: 0.18),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12)),
              Text(amount, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w800, color: color)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BentoAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _BentoAction({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: color.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.2),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 14)),
                    Text(subtitle, style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TodayTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _TodayTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 4),
          Text(value, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}
