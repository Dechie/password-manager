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
  List<bool> showPasswords = [];
  final HiveServices _hiveServices = HiveServices();
  bool isLoading = false;

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
            tooltip: "Backup Data",
            onPressed: () async {
              await _hiveServices.backupHiveData();
              if (context.mounted) displaySnackbar(context, "Backup completed.");
            },
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
          if (context.mounted) {
            showModalBottomSheet<Item>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ItemForm(
                size: size,
                onAddItem: (item) {
                  items.add(item);
                  _hiveServices.addToHive(item);
                  showPasswords.add(false);
                  setState(() {});
                },
              ),
            );
          }
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
                                        showPasswords[index] ? item.password : obscured,
                                        style: TextStyle(
                                          color: const Color(0xFF6B7280),
                                          fontSize: 13,
                                          fontFamily: showPasswords[index] ? 'monospace' : null,
                                          letterSpacing: showPasswords[index] ? 1.2 : 3.0,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () async {
                                          if (!showPasswords[index]) {
                                            final ok = await _authorize("Show Password");
                                            if (ok && context.mounted) {
                                              setState(() => showPasswords[index] = true);
                                            } else if (context.mounted) {
                                              displaySnackbar(context, "Not authorized.");
                                            }
                                          } else {
                                            setState(() => showPasswords[index] = false);
                                          }
                                        },
                                        child: Icon(
                                          showPasswords[index]
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
                                      Clipboard.setData(ClipboardData(text: item.password));
                                      displaySnackbar(context, "Password copied.");
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
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  void _deleteItem(Item item, int index) {
    setState(() {
      showPasswords.removeAt(index);
      items.removeAt(index);
    });
    displayRemoveSnackbar(context, item, "Entry removed", () {
      setState(() {
        items.insert(index, item);
        showPasswords.insert(index, false);
      });
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
        showPasswords = List.filled(newItems.length, false);
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
