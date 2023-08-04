import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CameraApp(),
    );
  }
}


// 메인 화면(카메라로 촬영)
class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {
  late CameraController controller;
  String decodeResult = "NULL";

  @override
  void initState() {
    super.initState();
    controller = CameraController(_cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          // Handle access errors here.
            break;
          default:
          // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return Scaffold(
        body: Center(
          child: Column(
            children: [
              Expanded(flex: 1, child: Container()),
              Expanded(flex: 9, child: CameraPreview(controller)),
              Expanded(
                  flex: 1,
                  child: IconButton(
                      onPressed: () async {
                        // 경로 생성
                        final path = join(
                            ( await getTemporaryDirectory() ).path,
                            '${DateTime.now()}.png'
                        );
                        // 사진 촬영
                        XFile picture = await controller.takePicture();
                        // 사진 저장
                        picture.saveTo(path);
                        if (!mounted) return;
                        // 검사 화면으로 전환
                        Navigator.push(context,
                            MaterialPageRoute(
                                builder: ( context ) => ChkAndSend( imagePath: path )
                            )
                        );
                      },
                      icon: Image.asset("assets/images/photo_capture.png")
                  )
              ),
              Expanded(child: Text("Result : $decodeResult"))
            ],
          ),
        )
    );
  }
}

// 촬영 후 확인 및 전송
class ChkAndSend extends StatefulWidget {
  final String imagePath;

  const ChkAndSend({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ChkAndSend> createState() => _ChkAndSendState();
}

class _ChkAndSendState extends State<ChkAndSend> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 29),
          SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.file( File(widget.imagePath) , fit: BoxFit.fitHeight)
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                    flex: 1,
                    child: TextButton(
                      onPressed: () { Navigator.pop(context); },
                      child: const Text("다시 찍기",style: TextStyle(color: Colors.black)),
                    )
                ),
                VerticalDivider(color: Color(0x676767FF),width: 2),
                Expanded(
                    child: TextButton(
                      onPressed: () {  },
                      child: const Text("스캔 시작",style: TextStyle(color: Colors.black)),
                    )
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

