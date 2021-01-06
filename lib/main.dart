import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image/image.dart' as im;
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'dart:ui' as ui;
import 'dart:developer';

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

class FileInfo {
  double sizeKB;
  int width, height;
  String name, whatIsIt, ext, path;
  ui.Image decodedImage;
}

class _MyHomePageState extends State<MyHomePage> {
  File img;
  File crpImg;
  String Info = '';
  bool canIWorkWithImg = false;
  bool canIWorkWithVid = false;
  FileInfo ImageInfo = new FileInfo();
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  bool isFileCompressed = false;

  //onlyForVideoDemo

  void pickTheFile() async {
    FilePickerResult result =
        await FilePicker.platform.pickFiles(type: FileType.media);
    img = File(result.files.single.path);
    InfoAboutFile();

    crpImg = img;
  }

  void funcForImage() async {
    cropTheFile();
    while (!isFileCompressed) {
      await Future.delayed(Duration(seconds: 1));
    }
    optimizeImg();
  }

  void funcForVideo(String pathToFile, int width, int q) {
    log('funcForVideo!');
    if (ImageInfo.decodedImage.height > width ||
        ImageInfo.decodedImage.width > width) {
      //cropItCauseItsBIG
      _flutterFFmpeg.execute("-i " +
          pathToFile +
          " -crf " +
          q.toString() +
          'filter:v "crop=w=' +
          width.toString() +
          ":h=" +
          width.toString() +
          ':x=0;y=0" ' +
          pathToFile +
          ".mp4");
    } else {
      //ITS small we will make it large
      //after that, we crop it

      //make it bigger
      _flutterFFmpeg.execute("-i " +
          pathToFile +
          'filter:v "scale=w=' +
          width.toString() +
          ':h=-1" ' +
          pathToFile +
          ".mp4");
      //after that
      //crop
      pathToFile += ".mp4";
      _flutterFFmpeg.execute("-i " +
          pathToFile +
          " -crf " +
          q.toString() +
          ' filter:v "crop=w=' +
          width.toString() +
          ":h=" +
          width.toString() +
          ':x=0;y=0" ' +
          pathToFile +
          ".mp4");
    }
    log("PATH TO FILE IS " + pathToFile + ".mp4");
  }

  void InfoAboutFile() async {
    if (img != null) {
      isFileCompressed = false;
      ImageInfo.sizeKB = img.lengthSync() / 1024;
      ImageInfo.name = img.path.split('/').last;
      ImageInfo.ext = ImageInfo.name.split('.').last;
      ImageInfo.decodedImage = await decodeImageFromList(img.readAsBytesSync());
      log(ImageInfo.name.split('.').last);
      if (ImageInfo.name.split('.').last == 'png' ||
          ImageInfo.name.split('.').last == 'jpg' ||
          ImageInfo.name.split('.').last == 'jpeg') {
        ImageInfo.whatIsIt = 'Image';
        canIWorkWithImg = true;
        canIWorkWithVid = false;
        for (int i = 0; i < 5; i++) log('its an image!');
        funcForImage();
      } else {
        ImageInfo.whatIsIt = 'Video';
        for (int i = 0; i < 5; i++) log('Its a video!');
        canIWorkWithImg = false;
        canIWorkWithVid = true;
        funcForVideo(img.absolute.path, 200, 48);
      }

      ImageInfo.path = img.absolute.path;

      setState(() {
        Info = 'Size (KB): ' +
            (img.lengthSync() / 1024).toString() +
            '\n'
                'Extension: ' +
            img.path.split('/').last.split('.').last;
      });
      print(Info);
    }
  }

  void cropTheFile() {
    print('CALLED FUNC CROP');
    File i = resize(img, 1000);
    ImageCropper.cropImage(
        sourcePath: i.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.lightBlue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        )).then((value) => {
          setState(() {
            crpImg = value;
            isFileCompressed = true;
          })
        });
  }

  File resize(File i, int width) {
    im.Image temp = im.decodeImage(i.readAsBytesSync());
    print(temp);
    im.Image thumbnail = im.copyResize(temp, width: width);
    print(thumbnail);

    File t = new File(img.absolute.path + ".jpg");
    print(t.absolute.path);
    t.create();
    t..writeAsBytesSync(im.encodePng(thumbnail));
    return t;
  }

  void optimizeImg() async {
    print('CALLED FUNC optimize');
    File t = resize(
        await compressTheFile(crpImg, crpImg.absolute.path + ".jpg"), 240);

    setState(() {
      Info = "Was: " +
          img.lengthSync().toString() +
          " AFTER: " +
          t.lengthSync().toString() +
          "\n" +
          (img.lengthSync() / t.lengthSync()).toString();
      crpImg = t;
    });
  }

  Future<File> compressTheFile(File file, pathToSave) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      pathToSave,
      quality: 10,
    );
    print(img.lengthSync());
    print(result.lengthSync());
    setState(() {
      Info = "BEFORE: " +
          img.lengthSync().toString() +
          " AFTER: " +
          result.lengthSync().toString();
    });
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () => pickTheFile(),
                color: Colors.amber,
                child: Text('Выберите файл'),
              ),
              Visibility(
                  visible: canIWorkWithImg,
                  child: (() {
                    if (crpImg == null) {
                      return Icon(Icons.note);
                    } else
                      return Image.file(
                        crpImg,
                        width: MediaQuery.of(context).size.width,
                      );
                  })()),
              Text(Info)
            ],
          ),
        ],
      ),
    );
  }
}
