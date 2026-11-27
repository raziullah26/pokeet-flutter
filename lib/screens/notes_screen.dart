import 'package:flutter/material.dart';
import '../models/pokeet_state.dart';
import '../theme/app_theme.dart';

class NotesScreen extends StatelessWidget {
  final PokeetController ctrl;
  const NotesScreen({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 84),
        child: FloatingActionButton.extended(
          backgroundColor: PokeetColors.green,
          foregroundColor: PokeetColors.onGreen,
          onPressed: () => _addNoteDialog(context),
          icon: const Icon(Icons.edit),
          label: Text(ctrl.tr('নতুন নোট', 'New Note')),
        ),
      ),
      body: ctrl.notes.isEmpty
          ? Center(child: Text(ctrl.tr('কোনো নোট নেই', 'No notes yet')))
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
              itemCount: ctrl.notes.length,
              itemBuilder: (_, i) {
                final n = ctrl.notes[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(n.title.isEmpty ? ctrl.tr('শিরোনামহীন', 'Untitled') : n.title,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text(n.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: PokeetColors.redDark),
                      onPressed: () => ctrl.deleteNote(n.id),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _addNoteDialog(BuildContext context) {
    final tCtrl = TextEditingController();
    final bCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ctrl.tr('নতুন নোট', 'New Note')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tCtrl, decoration: InputDecoration(hintText: ctrl.tr('শিরোনাম', 'Title'))),
            TextField(controller: bCtrl, maxLines: 3, decoration: InputDecoration(hintText: ctrl.tr('লিখুন...', 'Write...'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(ctrl.tr('বাতিল', 'Cancel'))),
          FilledButton(
            onPressed: () {
              if (tCtrl.text.trim().isNotEmpty || bCtrl.text.trim().isNotEmpty) {
                ctrl.addNote(NoteItem(
                  id: DateTime.now().microsecondsSinceEpoch.toString(),
                  title: tCtrl.text.trim(),
                  body: bCtrl.text.trim(),
                  updatedMs: DateTime.now().millisecondsSinceEpoch,
                ));
              }
              Navigator.pop(context);
            },
            child: Text(ctrl.tr('সংরক্ষণ', 'Save')),
          ),
        ],
      ),
    );
  }
}
