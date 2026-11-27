import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/pokeet_state.dart';
import 'screens/analysis_screen.dart';
import 'screens/home_screen.dart';
import 'screens/notes_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/transactions_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/floating_nav.dart';
import 'widgets/pokeet_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ctrl = PokeetController();
  await ctrl.load();
  runApp(PokeetApp(ctrl: ctrl));
}

class PokeetApp extends StatelessWidget {
  final PokeetController ctrl;
  const PokeetApp({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ctrl,
      builder: (context, _) {
        final isDark = ctrl.themeMode == ThemeMode.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ));
        return MaterialApp(
          title: 'Pokeet',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ctrl.themeMode,
          home: PokeetShell(ctrl: ctrl),
        );
      },
    );
  }
}

class PokeetShell extends StatefulWidget {
  final PokeetController ctrl;
  const PokeetShell({super.key, required this.ctrl});

  @override
  State<PokeetShell> createState() => _PokeetShellState();
}

class _PokeetShellState extends State<PokeetShell> {
  int _idx = 0;

  void _openAddTxSheet(String type) {
    final amtCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String selectedType = type;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'expense', label: Text(widget.ctrl.tr('ব্যয়', 'Expense'))),
                  ButtonSegment(value: 'income', label: Text(widget.ctrl.tr('আয়', 'Income'))),
                ],
                selected: {selectedType},
                onSelectionChanged: (s) => setS(() => selectedType = s.first),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: amtCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(prefixText: '৳ ', hintText: widget.ctrl.tr('পরিমাণ', 'Amount')),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(hintText: widget.ctrl.tr('নোট (ঐচ্ছিক)', 'Note (Optional)')),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final amt = double.tryParse(amtCtrl.text.trim()) ?? 0;
                    if (amt <= 0) return;
                    widget.ctrl.addTx(TxItem(
                      id: DateTime.now().microsecondsSinceEpoch.toString(),
                      type: selectedType,
                      amount: amt,
                      catName: selectedType == 'income'
                          ? widget.ctrl.tr('আয়', 'Income')
                          : widget.ctrl.tr('খরচ', 'Expense'),
                      catIcon: selectedType == 'income' ? '💰' : '🧾',
                      note: noteCtrl.text.trim(),
                      dateMs: DateTime.now().millisecondsSinceEpoch,
                    ));
                    Navigator.pop(ctx);
                  },
                  child: Text(widget.ctrl.tr('সংরক্ষণ করুন', 'Save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(ctrl: widget.ctrl, onAddTx: _openAddTxSheet),
      TransactionsScreen(ctrl: widget.ctrl),
      AnalysisScreen(ctrl: widget.ctrl),
      NotesScreen(ctrl: widget.ctrl),
      SettingsScreen(ctrl: widget.ctrl),
    ];

    return Scaffold(
      extendBody: true,
      body: PokeetBackground(
        child: SafeArea(bottom: false, child: pages[_idx]),
      ),
      bottomNavigationBar: PokeetFloatingNav(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
      ),
    );
  }
}
