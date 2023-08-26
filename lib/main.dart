import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Ivan Image Generation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  bool isLoading = false;
  String apiKey = "";

  static String url = "https://api.openai.com/v1/images/generations";

  String? image;

  void generateImageFunc() async {
    setState(() {
      isLoading = true;
      image = null;
    });
    if (_controller.text.isNotEmpty) {
      var data = {"prompt": _controller.text, "n": 1, "size": "256x256"};

      var response = await http.post(Uri.parse(url),
          headers: {
            "Authorization": "Bearer $apiKey",
            "Content-Type": "application/json"
          },
          body: jsonEncode(data));

      var jsonResponse = jsonDecode(response.body);

      setState(() {
        image = jsonResponse['data'][0]['url'];
        isLoading = false;
        _controller.clear();
      });
    } else {
      print("Input text cannot be empty!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              isLoading ? const CircularProgressIndicator() : Container(),
              image != null
                  ? Image.network(
                      image!,
                      width: 256,
                      height: 256,
                    )
                  : Container(),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                    hintText: "Enter text to generate image",
                    filled: true,
                    fillColor: Colors.purpleAccent.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    )),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          generateImageFunc();
        },
        tooltip: "Generate Image",
        child: const Icon(Icons.add),
      ),
    );
  }
}
