import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pass_mgr/screens/edit_form.dart';
import 'package:pass_mgr/utils/constans.dart';
import 'package:pass_mgr/utils/functions.dart';
import 'package:pass_mgr/utils/hive_services.dart';

import '../models/item.dart';
import '../widgets/item_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item> items = [];
  var itemsBox;
  final HiveServices _hiveServices = HiveServices();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    bool passwordObscured = true;
    return Scaffold(
      backgroundColor: bgGrey,
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.place), label: "$isLoading"),
          BottomNavigationBarItem(
              icon: const Icon(Icons.place), label: "${items.length}"),
        ],
      ),
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
        onPressed: () {
          showModalBottomSheet<Item>(
            context: context,
            builder: (context) => ItemForm(
              size: size,
              onAddItem: (item) {
                items.add(item);
                _hiveServices.addToHive(item);
                setState(() {});
              },
            ),
          );
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
                    ))
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        String passwordObscure = items[index]
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
                            subtitle: TextButton(
                              onPressed: () {
                                passwordObscured = !passwordObscured;
                              },
                              child: Text(
                                passwordObscured
                                    ? items[index].password
                                    : passwordObscure,
                                style: titleStyle1.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            trailing: SizedBox(
                              width: 150,
                              child: Row(
                                children: [
                                  iconButton(
                                    index: index,
                                    size: size,
                                    onPress: () {
                                      Clipboard.setData(
                                        ClipboardData(
                                          text: items[index].password,
                                        ),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              "Password copied to clipboard."),
                                        ),
                                      );
                                    },
                                    iconData: FontAwesomeIcons.copy,
                                  ),
                                  iconButton(
                                    index: index,
                                    size: size,
                                    onPress: () {
                                      editItem(items[index], size);
                                    },
                                    iconData: FontAwesomeIcons.penToSquare,
                                  ),
                                  iconButton(
                                    index: index,
                                    size: size,
                                    color: mainRed,
                                    onPress: () {
                                      Item deletedItem = items[index];
                                      items.remove(items[index]);
                                      _hiveServices
                                          .deleteFromHive(items[index]);
                                      setState(() {});
                                      displayRemoveSnackbar(
                                        context,
                                        deletedItem,
                                        "Item successfully removed",
                                        () {
                                          items.add(deletedItem);
                                          _hiveServices.addToHive(deletedItem);
                                          setState(() {});
                                        },
                                      );
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
      items.removeAt(index);
      items.insert(index, newItem);

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
