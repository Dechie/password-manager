import 'package:flutter/material.dart';

import '../models/item.dart';
import '../utils/constans.dart';
import '../utils/functions.dart';

class ItemForm extends StatefulWidget {
  final Size size;
  final void Function(Item item) onAddItem;

  const ItemForm({
    super.key,
    required this.size,
    required this.onAddItem,
  });

  @override
  State<ItemForm> createState() => _ItemFormState();
}

class _ItemFormState extends State<ItemForm> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  String passwordStrength = "";
  bool _generateActivated = false;
  String? generatedPassword;
  String title = "", password = "";
  bool passwordObscure = true;

  static const Map<String, Color> _strengthColor = {
    "weak": Color(0xFFEF4444),
    "medium": Color(0xFFF59E0B),
    "strong": Color(0xFF22C55E),
  };

  @override
  void dispose() {
    _titleController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _strengthBar() {
    if (passwordStrength.isEmpty) return const SizedBox.shrink();
    final levels = {"weak": 1, "medium": 2, "strong": 3};
    final filled = levels[passwordStrength] ?? 0;
    final color = _strengthColor[passwordStrength] ?? Colors.grey;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const SizedBox(height: 6),
        Row(
          children: List.generate(3, (i) {
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(left: i == 0 ? 0 : 4),
                height: 4,
                decoration: BoxDecoration(
                  color: i < filled ? color : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          passwordStrength,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      height: widget.size.height * 0.72,
      decoration: const BoxDecoration(
        color: bgGrey,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "New Entry",
            style: TextStyle(
              color: mainDark,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: kTextFieldDecoration.copyWith(hintText: "Title (e.g. Gmail)"),
                    onChanged: (v) => title = v,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passwordController,
                    keyboardType: TextInputType.text,
                    obscureText: passwordObscure,
                    decoration: kTextFieldDecoration.copyWith(
                      hintText: "Password",
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => passwordObscure = !passwordObscure),
                        icon: Icon(
                          passwordObscure ? Icons.visibility : Icons.visibility_off,
                          color: mainRed,
                          size: 20,
                        ),
                      ),
                    ),
                    onChanged: (v) {
                      password = v;
                      setState(() => passwordStrength = v.isEmpty ? "" : checkPasswordStrength(v));
                    },
                  ),
                  _strengthBar(),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      if (!_generateActivated) ...[
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: mainRed,
                              side: const BorderSide(color: mainRed),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              setState(() {
                                _generateActivated = true;
                                generatedPassword = generatePassword();
                              });
                            },
                            child: const Text("Generate", style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: mainRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () {
                            if (title.isEmpty || password.isEmpty) return;
                            widget.onAddItem(Item(title: title, password: password));
                            Navigator.pop(context);
                          },
                          child: const Text("Save", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  if (_generateActivated) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE5E5EA), width: 1.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            generatedPassword ?? "",
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: mainDark,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: mainDark2,
                                    side: const BorderSide(color: mainDark2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => setState(() => generatedPassword = generatePassword()),
                                  child: const Text("New", style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: mainDark2,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordController.text = generatedPassword!;
                                      password = generatedPassword!;
                                      passwordStrength = checkPasswordStrength(password);
                                      _generateActivated = false;
                                    });
                                  },
                                  child: const Text("Use This", style: TextStyle(fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
