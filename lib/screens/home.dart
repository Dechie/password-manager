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
  var itemsBox;
  final HiveServices _hiveServices = HiveServices();

  bool isLoading = false;

  Future<bool> authorizeMethod(BuildContext context, Size size,
      {required String task}) async {
    return await showModalBottomSheet(
      context: context,
      builder: (context) => PasswordForm(
        size: size,
        task: task,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgGrey,
      appBar: AppBar(
        backgroundColor: mainRed,
        title: const Text(
          'Password Manager',
          style: titleStyle2,
        ),
        // actions: [
        //   IconButton(
        //     tooltip: "Sync Data With Devices.",
        //     onPressed: () {},
        //     color: Colors.white,
        //     icon: const Icon(
        //       FontAwesomeIcons.arrowsRotate,
        //     ),
        //   )
        // ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool authorized =
              await authorizeMethod(context, size, task: "Add Item");

          if (authorized && context.mounted) {
            showModalBottomSheet<Item>(
              context: context,
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
          } else {
            if (context.mounted) {
              displaySnackbar(context, "Not Authorized! Cannot add item.");
            }
          }
        },
        child: const Icon(FontAwesomeIcons.plus),
      ),
      body: SizedBox(
        height: size.height * .9,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : items.isEmpty
                  ? Center(
                      child: SizedBox(
                        height: 80,
                        child: Column(
                          children: [
                            Text(
                              "No Items So far",
                              style: titleStyle1.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              "Click Below To Add New",
                              style: titleStyle1.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        String obscuredPassword = items[index]
                            .password
                            .characters
                            .map((char) => "*")
                            .join();
                        return Card(
                          elevation: 4.5,
                          color: Colors.white,
                          child: ListTile(
                            title: Text(
                              items[index].title,
                              style: titleStyle1,
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  textAlign: TextAlign.start,
                                  showPasswords[index]
                                      ? items[index].password
                                      : obscuredPassword,
                                  style: titleStyle1.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    if (!showPasswords[index]) {
                                      bool isAuthorized =
                                          await showModalBottomSheet(
                                        context: context,
                                        builder: (context) => PasswordForm(
                                          size: size,
                                          task: "Show Password",
                                        ),
                                      );
                                      if (isAuthorized && context.mounted) {
                                        displaySnackbar(
                                          context,
                                          "authorized",
                                        );
                                        setState(() {
                                          showPasswords[index] = true;
                                        });
                                      } else {
                                        if (context.mounted) {
                                          displaySnackbar(
                                            context,
                                            "Not Authorized! Cannot Show Password",
                                          );
                                        }
                                      }
                                    } else {
                                      setState(() {
                                        showPasswords[index] = false;
                                      });
                                    }
                                  },
                                  icon: Icon(
                                    showPasswords[index]
                                        ? FontAwesomeIcons.eyeSlash
                                        : FontAwesomeIcons.eye,
                                    size: 14,
                                    weight: 50,
                                  ),
                                ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 150,
                              child: Row(
                                children: [
                                  iconButton(
                                    index: index,
                                    size: size,
                                    onPress: () async {
                                      bool isAuthorized = await authorizeMethod(
                                        context,
                                        size,
                                        task: "Copy To Clipboard",
                                      );
                                      if (isAuthorized && context.mounted) {
                                        Clipboard.setData(
                                          ClipboardData(
                                            text: items[index].password,
                                          ),
                                        );

                                        displaySnackbar(
                                          context,
                                          "Password copied to clipboard.",
                                        );
                                      } else {
                                        if (context.mounted) {
                                          displaySnackbar(
                                            context,
                                            "Not Authorized! Cannot copy to clipboard.",
                                          );
                                        }
                                      }
                                    },
                                    iconData: FontAwesomeIcons.copy,
                                  ),
                                  iconButton(
                                    index: index,
                                    size: size,
                                    onPress: () async {
                                      bool isAuthorized = await authorizeMethod(
                                        context,
                                        size,
                                        task: "Edit Password",
                                      );
                                      if (isAuthorized && context.mounted) {
                                        editItem(items[index], size);
                                      } else {
                                        if (context.mounted) {
                                          displaySnackbar(
                                            context,
                                            "Not authorized!, cannot edit",
                                          );
                                        }
                                      }
                                    },
                                    iconData: FontAwesomeIcons.penToSquare,
                                  ),
                                  iconButton(
                                    index: index,
                                    size: size,
                                    color: mainRed,
                                    onPress: () async {
                                      bool isAuthored = await authorizeMethod(
                                        context,
                                        size,
                                        task: "Delete Item",
                                      );
                                      if (isAuthored && context.mounted) {
                                        deleteMethod(
                                            items[index], index, context);
                                      } else {
                                        if (context.mounted) {
                                          displaySnackbar(
                                            context,
                                            "Not authorized!. cannot delete",
                                          );
                                        }
                                      }
                                    },
                                    iconData: FontAwesomeIcons.trashCan,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  void deleteMethod(Item item, int index, BuildContext context) {
    bool stillDeleted = true;
    Item deletedItem = items[index];

    setState(() {
      showPasswords.removeAt(index);
      items.removeAt(index);
    });
    displayRemoveSnackbar(
      context,
      deletedItem,
      "Item successfully removed",
      () {
        stillDeleted = false;
        setState(() {
          items.insert(index, deletedItem);
          showPasswords.insert(index, false);
        });
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
      },
    );
    if (stillDeleted) {
      _hiveServices.deleteFromHive(deletedItem);
    }
  }

  editItem(Item item, Size size) async {
    Item? newItem = await showModalBottomSheet<Item>(
      context: context,
      builder: (context) => EditForm(
        size: size,
        oldItem: item,
      ),
    );

    if (newItem != null) {
      print("title: ${newItem.title}, pass: ${newItem.password}");
      var index = items.indexOf(item);
      setState(() {
        items.removeAt(index);
        items.insert(index, newItem);
      });

      _hiveServices.updateInHive(newItem);
    }
  }

  IconButton iconButton({
    required int index,
    required Size size,
    required void Function() onPress,
    required IconData iconData,
    Color? color,
  }) {
    return IconButton(
      onPressed: onPress,
      icon: Icon(
        iconData,
        size: 22,
        weight: 14,
      ),
      color: color ?? mainDark,
    );
  }

  void initHive() async {
    setState(() {
      isLoading = true;
    });
    //await Future.delayed(const Duration(seconds: 3));

    print("items length: ${items.length}");
    try {
      
      List<Item> newItems = await _hiveServices.fetchAll();
      print("newItems length: ${newItems.length}");
      setState(() {
        items = newItems;
      });
      for (int i = 0; i < items.length; i++) {
        showPasswords.add(false);
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      String exc = e.toString();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: Text(exc),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  items = [];
                });
              },
              child: const Text("Ok"),
            )
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initHive();
  }
}
