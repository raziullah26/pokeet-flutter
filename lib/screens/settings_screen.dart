import 'package:flutter/material.dart';
import '../models/pokeet_state.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  final PokeetController ctrl;
  const SettingsScreen({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
      children: [
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text(ctrl.tr('ডার্ক মোড', 'Dark Mode'), style: const TextStyle(fontWeight: FontWeight.w700)),
                secondary: const Icon(Icons.dark_mode),
                value: ctrl.themeMode == ThemeMode.dark,
                onChanged: (_) => ctrl.toggleTheme(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(ctrl.tr('ভাষা', 'Language'), style: const TextStyle(fontWeight: FontWeight.w700)),
                trailing: FilledButton.tonal(
                  onPressed: ctrl.toggleLang,
                  child: Text(ctrl.isEn ? 'English' : 'বাংলা'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const Icon(Icons.delete_forever, color: PokeetColors.redDark),
            title: Text(ctrl.tr('সব ডেটা ডিলিট', 'Delete All Data'),
                style: const TextStyle(fontWeight: FontWeight.w700, color: PokeetColors.redDark)),
            onTap: () => ctrl.wipeAll(),
          ),
        ),
      ],
    );
  }
}
