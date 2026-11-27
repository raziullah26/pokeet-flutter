import 'package:flutter/material.dart';
import '../models/pokeet_state.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class TransactionsScreen extends StatefulWidget {
  final PokeetController ctrl;
  const TransactionsScreen({super.key, required this.ctrl});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final c = widget.ctrl;
    final list = c.txs.where((t) => _filter == 'all' || t.type == _filter).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
          child: Row(
            children: [
              _chip('all', c.tr('সব', 'All')),
              const SizedBox(width: 8),
              _chip('income', c.tr('আয়', 'Income')),
              const SizedBox(width: 8),
              _chip('expense', c.tr('ব্যয়', 'Expense')),
            ],
          ),
        ),
        Expanded(
          child: list.isEmpty
              ? Center(child: Text(c.tr('কোনো লেনদেন নেই', 'No transactions')))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final t = list[i];
                    final inc = t.type == 'income';
                    return Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: PokeetColors.redDark,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => c.deleteTx(t.id),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: Text(t.catIcon, style: const TextStyle(fontSize: 24)),
                          title: Text(t.catName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          subtitle: t.note.isNotEmpty ? Text(t.note) : null,
                          trailing: Text(
                            PokeetFmt.money(inc ? t.amount : -t.amount, isEn: c.isEn, showSign: true),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: inc ? PokeetColors.green : PokeetColors.redDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip(String key, String label) {
    final on = _filter == key;
    return ChoiceChip(
      label: Text(label),
      selected: on,
      selectedColor: PokeetColors.green,
      onSelected: (_) => setState(() => _filter = key),
    );
  }
}
