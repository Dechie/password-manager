import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pass_mgr/utils/constans.dart';
import 'package:pass_mgr/utils/functions.dart';
import 'package:pass_mgr/utils/hive_services.dart';
import 'package:pass_mgr/widgets/edit_form.dart';
import 'package:pass_mgr/widgets/password_form.dart';

import '../models/item.dart';
import '../widgets/item_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item> items = [];
  // Tracks which item keys are currently showing their password.
  // A Set keyed by item.key eliminates the parallel-list drift that caused
  // RangeErrors when items and a bool list got out of sync.
  final Set<int> _visiblePasswords = {};
  final HiveServices _hiveServices = HiveServices();
  bool isLoading = false;

  static const int _clipboardClearSeconds = 45;
  static const int _passwordHideSeconds = 30;
  Timer? _clipboardTimer;
  Timer? _visibilityTimer;
  String? _copiedValue;

  /// Shows a password and (re)starts the single shared hide-all timer.
  /// Revealing any additional password resets the countdown so all currently
  /// visible passwords stay visible for another [_passwordHideSeconds] seconds.
  void _revealPassword(int key) {
    setState(() => _visiblePasswords.add(key));
    _visibilityTimer?.cancel();
    _visibilityTimer = Timer(
      const Duration(seconds: _passwordHideSeconds),
      () => setState(() => _visiblePasswords.clear()),
    );
  }

  @override
  void dispose() {
    _clipboardTimer?.cancel();
    _visibilityTimer?.cancel();
    super.dispose();
  }

  /// Copies a secret and schedules it to be wiped from the clipboard, but
  /// only if the clipboard still holds the value we put there.
  void _copyWithAutoClear(String value) {
    Clipboard.setData(ClipboardData(text: value));
    _copiedValue = value;
    _clipboardTimer?.cancel();
    _clipboardTimer = Timer(
      const Duration(seconds: _clipboardClearSeconds),
      () async {
        final current = await Clipboard.getData(Clipboard.kTextPlain);
        if (current?.text == _copiedValue) {
          await Clipboard.setData(const ClipboardData(text: ''));
        }
        _copiedValue = null;
      },
    );
  }

  Future<void> _runBackup() async {
    final passphrase = await _promptPassphrase();
    if (passphrase == null || passphrase.isEmpty) return;
    try {
      final path = await _hiveServices.backupHiveData(passphrase);
      if (mounted) displaySnackbar(context, "Encrypted backup saved to $path");
    } catch (e) {
      if (mounted) displaySnackbar(context, "Backup failed: $e");
    }
  }

  Future<String?> _promptPassphrase() async {
    final controller = TextEditingController();
    bool obscure = true;
    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: const Text("Encrypt backup"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Choose a passphrase. You'll need it to restore this "
                "backup — it cannot be recovered if lost.",
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                obscureText: obscure,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Backup passphrase",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setLocal(() => obscure = !obscure),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: const Text("Encrypt & Save"),
            ),
          ],
        ),
      ),
    );
  }

  static const List<Color> _avatarColors = [
    Color(0xFFE53935), Color(0xFF8E24AA), Color(0xFF1E88E5),
    Color(0xFF00897B), Color(0xFF43A047), Color(0xFFFF8F00),
    Color(0xFF6D4C41), Color(0xFF546E7A),
  ];

  Color _avatarColor(String title) {
    if (title.isEmpty) return _avatarColors[0];
    return _avatarColors[title.codeUnitAt(0) % _avatarColors.length];
  }

  Future<bool> _authorize(String task) async {
    final size = MediaQuery.of(context).size;
    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => PasswordForm(size: size, task: task),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: mainRed,
        elevation: 0,
        title: const Text('Password Manager', style: titleStyle2),
        actions: [
          IconButton(
            tooltip: "Encrypted Backup",
            onPressed: _runBackup,
            color: Colors.white,
            icon: const Icon(FontAwesomeIcons.fileExport, size: 18),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: mainRed,
        foregroundColor: Colors.white,
        icon: const Icon(FontAwesomeIcons.plus, size: 16),
        label: const Text("Add Entry", style: TextStyle(fontWeight: FontWeight.w600)),
        onPressed: () async {
          final authorized = await _authorize("Add Item");
          if (!authorized) {
            if (context.mounted) displaySnackbar(context, "Not authorized. Cannot add item.");
            return;
          }
          if (!context.mounted) return;
          final newItem = await showModalBottomSheet<Item>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => ItemForm(size: size),
          );
          if (newItem == null || !mounted) return;
          final key = await _hiveServices.addToHive(newItem);
          if (!mounted) return;
          setState(() {
            items.add(Item(key: key, title: newItem.title, password: newItem.password));
          });
        },
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: mainRed))
          : items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: mainRed.withAlpha(20),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FontAwesomeIcons.lockOpen,
                          color: mainRed,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "No entries yet",
                        style: TextStyle(
                          color: mainDark,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Tap 'Add Entry' below to store your first password",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 100),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final obscured = item.password.characters.map((_) => "•").join();
                    final avatarColor = _avatarColor(item.title);
                    final initial = item.title.isNotEmpty
                        ? item.title[0].toUpperCase()
                        : "?";

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 1.5,
                      shadowColor: Colors.black.withAlpha(25),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: avatarColor.withAlpha(25),
                              radius: 22,
                              child: Text(
                                initial,
                                style: TextStyle(
                                  color: avatarColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: const TextStyle(
                                      color: mainDark,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        _visiblePasswords.contains(item.key) ? item.password : obscured,
                                        style: TextStyle(
                                          color: const Color(0xFF6B7280),
                                          fontSize: 13,
                                          fontFamily: _visiblePasswords.contains(item.key) ? 'monospace' : null,
                                          letterSpacing: _visiblePasswords.contains(item.key) ? 1.2 : 3.0,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () async {
                                          if (!_visiblePasswords.contains(item.key)) {
                                            final ok = await _authorize("Show Password");
                                            if (ok && context.mounted) {
                                              _revealPassword(item.key);
                                            } else if (context.mounted) {
                                              displaySnackbar(context, "Not authorized.");
                                            }
                                          } else {
                                            setState(() => _visiblePasswords.remove(item.key));
                                          }
                                        },
                                        child: Icon(
                                          _visiblePasswords.contains(item.key)
                                              ? FontAwesomeIcons.eyeSlash
                                              : FontAwesomeIcons.eye,
                                          size: 13,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _trailingButton(
                                  icon: FontAwesomeIcons.copy,
                                  onTap: () async {
                                    final ok = await _authorize("Copy To Clipboard");
                                    if (ok && context.mounted) {
                                      _copyWithAutoClear(item.password);
                                      displaySnackbar(context,
                                          "Password copied. Clears in ${_clipboardClearSeconds}s.");
                                    } else if (context.mounted) {
                                      displaySnackbar(context, "Not authorized.");
                                    }
                                  },
                                ),
                                _trailingButton(
                                  icon: FontAwesomeIcons.penToSquare,
                                  onTap: () async {
                                    final ok = await _authorize("Edit Entry");
                                    if (ok && context.mounted) {
                                      _editItem(item, size);
                                    } else if (context.mounted) {
                                      displaySnackbar(context, "Not authorized.");
                                    }
                                  },
                                ),
                                _trailingButton(
                                  icon: FontAwesomeIcons.trashCan,
                                  color: mainRed,
                                  onTap: () async {
                                    final ok = await _authorize("Delete Entry");
                                    if (ok && context.mounted) {
                                      _deleteItem(item, index);
                                    } else if (context.mounted) {
                                      displaySnackbar(context, "Not authorized.");
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _trailingButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = const Color(0xFF6B7280),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }

  void _deleteItem(Item item, int index) {
    setState(() {
      items.removeAt(index);
      _visiblePasswords.remove(item.key);
    });
    displayRemoveSnackbar(context, item, "Entry removed", () {
      setState(() => items.insert(index, item));
    });
    _hiveServices.deleteFromHive(item);
  }

  Future<void> _editItem(Item item, Size size) async {
    final newItem = await showModalBottomSheet<Item>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditForm(size: size, oldItem: item),
    );

    if (newItem != null) {
      final index = items.indexOf(item);
      setState(() {
        items[index] = newItem;
      });
      _hiveServices.updateInHive(newItem);
    }
  }

  Future<void> _initHive() async {
    setState(() => isLoading = true);
    try {
      final newItems = await _hiveServices.fetchAll();
      setState(() {
        items = newItems;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => items = []);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _initHive();
  }
}
