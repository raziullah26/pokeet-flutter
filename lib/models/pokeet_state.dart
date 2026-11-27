import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TxItem {
  final String id;
  final String type; // 'income' | 'expense'
  final double amount;
  final String catName;
  final String catIcon;
  final String? walletId;
  final String note;
  final int dateMs;

  TxItem({
    required this.id,
    required this.type,
    required this.amount,
    required this.catName,
    required this.catIcon,
    this.walletId,
    this.note = '',
    required this.dateMs,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'amount': amount,
        'catName': catName,
        'catIcon': catIcon,
        'walletId': walletId,
        'note': note,
        'date': dateMs,
      };

  factory TxItem.fromJson(Map<String, dynamic> j) => TxItem(
        id: j['id'] ?? '',
        type: j['type'] ?? 'expense',
        amount: (j['amount'] as num?)?.toDouble() ?? 0,
        catName: j['catName'] ?? 'অন্যান্য',
        catIcon: j['catIcon'] ?? '🧾',
        walletId: j['walletId'],
        note: j['note'] ?? '',
        dateMs: j['date'] ?? DateTime.now().millisecondsSinceEpoch,
      );
}

class WalletItem {
  final String id;
  final String name;
  final double opening;
  final String icon;
  final int colorValue;

  WalletItem({
    required this.id,
    required this.name,
    required this.opening,
    this.icon = '👛',
    this.colorValue = 0xFF09A75A,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'opening': opening,
        'icon': icon,
        'colorValue': colorValue,
      };

  factory WalletItem.fromJson(Map<String, dynamic> j) => WalletItem(
        id: j['id'] ?? '',
        name: j['name'] ?? 'পকেট',
        opening: (j['opening'] as num?)?.toDouble() ?? 0,
        icon: j['icon'] ?? '👛',
        colorValue: j['colorValue'] ?? 0xFF09A75A,
      );
}

class NoteItem {
  final String id;
  final String title;
  final String body;
  final int updatedMs;
  bool pinned;

  NoteItem({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedMs,
    this.pinned = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'upd': updatedMs,
        'pin': pinned,
      };

  factory NoteItem.fromJson(Map<String, dynamic> j) => NoteItem(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        body: j['body'] ?? '',
        updatedMs: j['upd'] ?? DateTime.now().millisecondsSinceEpoch,
        pinned: j['pin'] ?? false,
      );
}

class PokeetController extends ChangeNotifier {
  static const _storageKey = 'muhasabah_v1';

  String userName = 'Raziullah';
  String lang = 'bn';
  ThemeMode themeMode = ThemeMode.dark;
  bool hideBalance = false;
  double monthlyBudget = 0;

  List<TxItem> txs = [];
  List<WalletItem> wallets = [];
  List<NoteItem> notes = [];

  bool get isEn => lang == 'en';
  String tr(String bn, String en) => isEn ? en : bn;

  double get totalIncome => txs.where((t) => t.type == 'income').fold(0, (s, t) => s + t.amount);
  double get totalExpense => txs.where((t) => t.type == 'expense').fold(0, (s, t) => s + t.amount);
  double get totalBalance => wallets.fold(0.0, (s, w) => s + w.opening) + totalIncome - totalExpense;

  double walletBalance(WalletItem w) {
    final delta = txs
        .where((t) => t.walletId == w.id)
        .fold(0.0, (s, t) => s + (t.type == 'income' ? t.amount : -t.amount));
    return w.opening + delta;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final profile = (map['profile'] as Map<String, dynamic>?) ?? {};
      userName = profile['name'] ?? userName;
      lang = profile['lang'] ?? 'bn';
      hideBalance = profile['hideBalance'] ?? false;
      final th = profile['theme'] ?? 'dark';
      themeMode = th == 'light' ? ThemeMode.light : ThemeMode.dark;
      monthlyBudget = (map['monthlyBudget'] as num?)?.toDouble() ?? 0;
      txs = ((map['tx'] as List?) ?? []).map((e) => TxItem.fromJson(e)).toList();
      wallets = ((map['wallets'] as List?) ?? []).map((e) => WalletItem.fromJson(e)).toList();
      notes = ((map['notes'] as List?) ?? []).map((e) => NoteItem.fromJson(e)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = {
      'v': 2,
      'profile': {
        'name': userName,
        'lang': lang,
        'theme': themeMode == ThemeMode.light ? 'light' : 'dark',
        'hideBalance': hideBalance,
      },
      'monthlyBudget': monthlyBudget,
      'tx': txs.map((e) => e.toJson()).toList(),
      'wallets': wallets.map((e) => e.toJson()).toList(),
      'notes': notes.map((e) => e.toJson()).toList(),
    };
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    save();
    notifyListeners();
  }

  void toggleLang() {
    lang = isEn ? 'bn' : 'en';
    save();
    notifyListeners();
  }

  void toggleHideBalance() {
    hideBalance = !hideBalance;
    save();
    notifyListeners();
  }

  void addTx(TxItem item) {
    txs.insert(0, item);
    save();
    notifyListeners();
  }

  void deleteTx(String id) {
    txs.removeWhere((e) => e.id == id);
    save();
    notifyListeners();
  }

  void addWallet(WalletItem w) {
    wallets.add(w);
    save();
    notifyListeners();
  }

  void addNote(NoteItem n) {
    notes.insert(0, n);
    save();
    notifyListeners();
  }

  void deleteNote(String id) {
    notes.removeWhere((e) => e.id == id);
    save();
    notifyListeners();
  }

  void setBudget(double amount) {
    monthlyBudget = amount;
    save();
    notifyListeners();
  }

  void wipeAll() {
    txs.clear();
    wallets.clear();
    notes.clear();
    monthlyBudget = 0;
    save();
    notifyListeners();
  }
}
