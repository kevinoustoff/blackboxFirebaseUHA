import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  //await FirebaseStorage.instance.ref();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSwatch().copyWith(secondary: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  FilePickerResult? result;

  void _incrementCounter() {
    setState(() async {
      result = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);
      if (result == null) {
        print("No file selected");
      } else {
        setState(() {});
        int index = 0;
        for (var element in result!.files) {
          try {
            String imageName = DateTime.now().millisecondsSinceEpoch.toString();
            Reference storageReference =
                FirebaseStorage.instance.ref().child('images/$imageName');
            // Upload the file to Firebase Storage
            await storageReference
                .putFile(File(result?.files[index].path ?? ''));
            // Get the download URL for the uploaded image
            String downloadURL = await storageReference.getDownloadURL();
          } catch (e) {
            print('Error uploading image: $e');
            return null;
          }
          print("hellllllllllllllllll");
          print(element.name);
          index++;
        }
      }
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline6,
            ),
            if (result != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Selected file:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      itemCount: result?.files.length ?? 0,
                      itemBuilder: (context, index) {
                        String filePath = result?.files[index].path ?? '';
                        return filePath.isNotEmpty
                            ? Image.file(
                                File(filePath),
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              )
                            : Container();
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: 5,
                        );
                      },
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
