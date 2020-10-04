import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        primarySwatch: Colors.blue,
        
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  File _image;
  final picker = ImagePicker();

  // Variables
  List _salida;
  bool _estado = false;

  void initState() {
    loadModel();
    super.initState();
  }

  getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('Imagen no encontrada');
      }
    });

    classifyImage(pickedFile);
  }

  // Cargar el modelo
  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt"
      );
  }

  // Clasificador
  classifyImage(image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5
      );

      setState(() {
        _salida = output;
        _estado = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Clasificador de imagenes'),
      ),
      body: _estado == false ? Container(
        alignment: Alignment.center,
        child: CircularProgressIndicator(),
      ): Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            _image == null ? Container() : Image.file(_image),
            SizedBox(height: 30),
            _salida != null ? Text("${_salida[0]["label"]}",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.0))
            
            : Container(),
          ],
        ),
      ) ,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          getImage();
        },
        child: Icon(Icons.image),
        ),


    );
  }
}
