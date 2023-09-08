import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloudinary_api/uploader/cloudinary_uploader.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  Cloudinary.fromCloudName(cloudName: "ddcrefyem");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  String? _imageUrl;

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

    setState(() {
      if (pickedImage != null) _imageFile = File(pickedImage.path);
    });
  }

  Future<void> uploadImage() async {
    print('message');
    final url = Uri.parse('https://api.cloudinary.com/v1_1/ddcrefyem/upload');
    //  qj9uibnk
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'qj9uibnk'
      ..files.add(
        await http.MultipartFile.fromPath('file', _imageFile!.path),
      );
    print(_imageFile!.path);
    print(request);

    final response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);
      setState(() {
        final url = jsonMap['url'];
        _imageUrl = url;
      });
    }
  }

  Future<void> uploadImage2() async {
    var cloudinary = Cloudinary.fromStringUrl(
        'cloudinary://618741654814823:WJLK75MJ_Sg3XDJeh24h6GvOu1Q@ddcrefyem');
    var response = await cloudinary
        .uploader()
        .upload(File(_imageFile!.path))
        ?.then((value) {
      print(value.data!.url);
      setState(() {
        _imageUrl = value.data?.url ?? '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.gallery),
              child: const Text('Take Picture'),
            ),
            if (_imageFile != null) ...[
              Image.file(
                _imageFile!,
                height: 200,
              ),
              ElevatedButton(
                onPressed: () => uploadImage(),
                child: const Text('Upload image to cloud'),
              ),
            ],
            if (_imageUrl != null) ...[
              Image.network(
                _imageUrl!,
                height: 200,
              ),
              Text("Cloudninary URL: $_imageUrl"),
              const Padding(
                padding: EdgeInsets.only(left: 20, top: 60, bottom: 100),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
