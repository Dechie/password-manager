#!/bin/bash

# Resolve the script directory
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$( readlink "$SOURCE" )"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"


if [[ $1 == "new" ]]; then

flutter create $2
cd $2
PROJECT_DIR=$(pwd)
echo "project dir: $PROJECT_DIR"
mkdir -p assets/images

sed -i '/# assets:/s/^# //' pubspec.yaml
sed -i '/#   - images\/a_dot_burr.jpeg/s/^#.*$/  - assets\/images\//' pubspec.yaml

#sed -i -e '/# assets/ s/#//' pubspec.yaml

cd lib
mkdir widgets screens models 

echo 'import '\''package:flutter/material.dart'\'';
import '\''home.dart'\'';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
       colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
' > main.dart

echo 'import '\''package:flutter/material.dart'\'';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
       title: const Text('\''sample text'\''),
      ),
      body: const Center(
       child: Text('\''demo app'\''),      
       ),
    );
  }
}

' > home.dart 
mv home.dart screens/home.dart

cp $SCRIPT_DIR/flutil.sh $PROJECT_DIR

if [[ $3 == "withide" ]]; then
  $4 $2
  exit
fi

elif [[ $1 == "makemodel" ]]; then
file_name=$2

words=$(echo $file_name | tr "_" "\n")

model_name=""
for word in $words
do
    #echo "> [$word]"
    # Capitalize the first letter and concatenate with the rest of the word
    capitalized_word="$(echo ${word:0:1} | tr '[:lower:]' '[:upper:]')${word:1}"
    model_name=$model_name$capitalized_word
done
#echo $model_name

if [[ -d "lib/models" ]]; then
  echo "folder exists, no need to create"
else
  echo "folder doesn't exist, creating folder"
  mkdir -p lib/models
fi
cd lib/models
 echo "class ${model_name} {
  const ${model_name}({
    required this.field1,
    required this.field2,
    required this.field3,
  });

  final String field1, field2, field3; 

  factory ${model_name}.fromJson(Map<String, dynamic> json) {
    return ${model_name}(
      field1: json['field1'],
      field2: json['field2'],
      field3: json['field3'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field1': field1,
      'field2': field2,
      'field3': field3,
    };
  }
}
" > $file_name".dart" 

elif [[ $1 == "makewidget" ]]; then

file_name=$2

words=$(echo $file_name | tr "_" "\n")

model_name=""
for word in $words
do
    #echo "> [$word]"
    # Capitalize the first letter and concatenate with the rest of the word
    capitalized_word="$(echo ${word:0:1} | tr '[:lower:]' '[:upper:]')${word:1}"
    model_name=$model_name$capitalized_word
done

if [[ -d "lib/widgets" ]]; then
  echo "folder exists, no need to create"
else
  echo "folder doesn't exist, creating folder"
  mkdir -p lib/widgets 
fi
 
 echo "import 'package:flutter/material.dart';

class ${model_name} extends StatelessWidget {
  const ${model_name}({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: Text(
          'new widget',
        ),
      ),
    );
  }
}
 
 " > lib/widgets/${file_name}.dart 

elif [[ $1 == "makescreen" ]]; then

file_name=$2

words=$(echo $file_name | tr "_" "\n")

model_name=""
for word in $words
do
    #echo "> [$word]"
    # Capitalize the first letter and concatenate with the rest of the word
    capitalized_word="$(echo ${word:0:1} | tr '[:lower:]' '[:upper:]')${word:1}"
    model_name=$model_name$capitalized_word
done

if [[ -d "lib/screens" ]]; then
  echo "folder exists, no need to create"
else
  echo "folder doesn't exist, creating folder"
  mkdir -p lib/screens 
fi
 
 echo "import 'package:flutter/material.dart';

class ${model_name} extends StatefulWidget {
  const ${model_name}({super.key});

  @override
  State<${model_name}> createState() => _${model_name}State();
}

class _${model_name}State extends State<${model_name}> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const SafeArea(
        child: SizedBox(),
      ),
    );
  }
}
 
 " > lib/screens/${file_name}.dart 

elif [[ $1 == "packs" ]]; then

package_list=$2

packages=$(echo $package_list | tr " " "\n")

for package in $packages
do
    echo "> Adding package: $package"
    flutter pub add $package
done
 
elif [[ $1 == "help" ]]; then
echo -e "\tFLUTILS: A COMMAND LINE TOOL FOR FLUTTER UTILITIES"
echo -e "\tCOMMANDS:"
echo -e "\t\tnew - creates a new project, with basic folder structure, and also adds 'assets/images' folder by default"
echo -e "\t\tmakemodel [e.g.: cre.sh makemodel <model_name>] \n\t\t\tcreates a new model class, using specified file name. file name shall be specified in snake case, and the model's identifier name will be inferred from that. i.e., it will be a pascal-case version of the former"
echo -e "\t\tmakewidget [e.g.: cre.sh makewidget <widget_name>] \n\t\t\tcreates a basic StatefulWidget. again the name will be inferred from file name provided in snake case"
echo -e "\t\tpacks [e.g.: cre.sh packs \"package1\" \"package2\"] \n\t\t\texpects a list of package names surrounded by \" \" separated by spaces, it will add each of the packages to the project."
   
else
 echo '' 
fi

