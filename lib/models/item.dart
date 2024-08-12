class Item {
  final String title;

  final String password;
  final int key;

  const Item({
    required this.title,
    required this.password,
    this.key = -1,
    //required this.field3,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      key: json['key'],
      title: json['title'],
      password: json['password'],
      //field3: json['field3'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'password': password,
//      'field3': field3,
    };
  }
}
