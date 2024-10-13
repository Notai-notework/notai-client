import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:notai/widgets/document/custom_notifier.dart';
import 'package:notai/widgets/global/global_appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scribble/scribble.dart';
import 'package:value_notifier_tools/value_notifier_tools.dart';

class DocumentInnerScreen extends StatefulWidget {
  final int documentId;

  const DocumentInnerScreen({super.key, required this.documentId});

  @override
  State<DocumentInnerScreen> createState() => _DocumentInnerScreenState();
}

class _DocumentInnerScreenState extends State<DocumentInnerScreen> {
  List<Uint8List> _images = [];
  List<List<double>> _imagesSizes = [];
  List<CustomNotifier> notifier = [];
  final TransformationController _controller = TransformationController();
  late final PageController _pageController;
  double _currentScale = 1.0;
  int _currentImageIndex = 0;

  List<GlobalKey> _globalKeys = [];
  final GlobalKey _globalKey = GlobalKey();
  bool isLoading = true;
  bool isSaving = false;

  void _fetchImages(int id) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}/$id/images/";

    final List<FileSystemEntity> imageFiles = Directory(path).listSync();
    if (imageFiles.isEmpty) return;
    List<Uint8List> images = [];
    for (int i = 0; i < imageFiles.length; i++) {
      var file = await File("${path}page_${i + 1}.png").readAsBytes();
      images.add(file);

      final ui.Codec codec = await ui.instantiateImageCodec(file);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      final ui.Image image = frameInfo.image;

      _imagesSizes.add([image.width.toDouble(), image.height.toDouble()]);

      _globalKeys.add(GlobalKey());
    }

    _images = images;
    notifier = List.generate(_images.length,
        (index) => CustomNotifier([1, 3, 5], ScribblePointerMode.penOnly));

    _controller.addListener(() {
      setState(() {
        _currentScale = _controller.value.getMaxScaleOnAxis();
        notifier[_currentImageIndex].setWidths(
            [5 / _currentScale, 10 / _currentScale, 15 / _currentScale]);
      });
    });
    setState(() {
      isLoading = false;
    });
    // setState(() {
    //   _images = images;
    //   // 각 이미지에 대한 CustomNotifier를 생성
    //   notifier = List.generate(_images.length,
    //       (index) => CustomNotifier([1, 3, 5], ScribblePointerMode.penOnly));
    // });
  }

  @override
  void initState() {
    super.initState();
    _fetchImages(widget.documentId);
    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    // 화면의 가로 및 세로 크기 가져오기
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // 가로 세로에 따라 width 차별화
    double containerWidth;
    if (screenWidth > screenHeight) {
      // 가로 모드
      containerWidth = screenWidth * 0.6; // 화면의 60% 너비
    } else {
      // 세로 모드
      containerWidth = screenWidth * 1.0; // 화면의 80% 너비
    }
    return Scaffold(
        key: UniqueKey(),
        appBar: GlobalAppbar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // 뒤로가기 버튼 눌렀을 때 이벤트 처리
              _save(widget.documentId);
            },
          ),
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: SizedBox(
                      width: containerWidth,
                      height: double.infinity,
                      child: isLoading
                          ? const Center(
                              child: Column(children: [
                              const SizedBox(height: 300),
                              CircularProgressIndicator(),
                              const SizedBox(height: 50),
                              Text('문서를 불러오고 있습니다..')
                            ]))
                          : isSaving
                              ? const Center(
                                  child: Column(children: [
                                  const SizedBox(height: 300),
                                  CircularProgressIndicator(),
                                  const SizedBox(height: 50),
                                  Text('문서를 저장 중 입니다..')
                                ]))
                              : PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    _currentImageIndex = index;
                                    // notifier[index].clear();
                                  },
                                  itemCount: _images.length,
                                  itemBuilder: (context, index) {
                                    return Center(
                                        child: InteractiveViewer(
                                      boundaryMargin:
                                          const EdgeInsets.all(20.0),
                                      minScale: 1.0,
                                      maxScale: 4.0,
                                      child: RepaintBoundary(
                                          key: _globalKeys[index],
                                          child: Container(
                                            // width: 450,
                                            // height: 640,
                                            width: _imagesSizes[index][0],
                                            height: _imagesSizes[index][1],
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                image: DecorationImage(
                                                    image: MemoryImage(
                                                        _images[index]),
                                                    fit: BoxFit.scaleDown)),
                                            child: Scribble(
                                                notifier: notifier[index]),
                                          )),
                                    ));
                                  }))),
              SizedBox(
                  height: 100,
                  child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _buildColorToolbar(context),
                          const VerticalDivider(width: 32),
                          _buildStrokeToolbar(context),
                          const Expanded(child: SizedBox()),
                          _buildPointerModeSwitcher(context),
                          const Expanded(child: SizedBox()),
                        ],
                      )))
            ]));
    // );
  }

  List<Widget> _buildActions(context, Uint8List imageFile) {
    return [
      ValueListenableBuilder(
        valueListenable: notifier[_currentImageIndex],
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: "Undo",
          onPressed: notifier[_currentImageIndex].canUndo
              ? notifier[_currentImageIndex].undo
              : null,
        ),
        child: const Icon(Icons.undo),
      ),
      ValueListenableBuilder(
        valueListenable: notifier[_currentImageIndex],
        builder: (context, value, child) => IconButton(
          icon: child as Icon,
          tooltip: "Redo",
          onPressed: notifier[_currentImageIndex].canRedo
              ? notifier[_currentImageIndex].redo
              : null,
        ),
        child: const Icon(Icons.redo),
      ),
      IconButton(
        icon: const Icon(Icons.clear),
        tooltip: "Clear",
        onPressed: notifier[_currentImageIndex].clear,
      ),
      IconButton(
        icon: const Icon(Icons.image),
        tooltip: "Show PNG Image",
        onPressed: () => _showImage(context, imageFile!),
      ),
      IconButton(
        icon: const Icon(Icons.data_object),
        tooltip: "Show JSON",
        onPressed: () => _showJson(context),
      ),
    ];
  }

  Future<void> _save(int id) async {
    setState(() {
      isSaving = true;
    });
    try {
      for (int i = 0; i < _globalKeys.length; i++) {
        RenderRepaintBoundary boundary = _globalKeys[i]
            .currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 3.0);
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // 파일 시스템 경로 찾기
        final directory = await getApplicationDocumentsDirectory();
        final imagePath = '${directory.path}/$id/images/page_${i + 1}.png';
        // print(directory.path);
        // print('ddd');
        // return;

        await File(imagePath).writeAsBytes(pngBytes);

        // 이미지 저장
        // final result = await ImageGallerySaver.saveImage(pngBytes,
        //     quality: 100, name: "my_scribble_image");
      }
      print("Image saved");
    } catch (e) {
      print("Error saving image: $e");
    }
    Navigator.pop(context);

    setState(() {
      isSaving = false;
    });
  }

  void _showImage(BuildContext context, Uint8List imageFile) async {
    final image = notifier[_currentImageIndex].renderImage();
    Directory directory = await getApplicationDocumentsDirectory();
    print(directory.path);
    return;
    // final a  =  File(directory.path + "/1/a.png");
    // await a.writeAsBytes(imageFile);
    // return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Generated Image"),
        content: SizedBox.expand(
          child: FutureBuilder(
            future: image,
            builder: (context, snapshot) => snapshot.hasData
                ? Stack(children: [
                    Image.memory(
                      imageFile,
                      fit: BoxFit.contain,
                    ),
                    Image.memory(snapshot.data!.buffer.asUint8List()),
                  ])
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  void _showJson(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sketch as JSON"),
        content: SizedBox.expand(
          child: SelectableText(
            jsonEncode(notifier[_currentImageIndex].currentSketch.toJson()),
            autofocus: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  Widget _buildStrokeToolbar(BuildContext context) {
    try {
      return ValueListenableBuilder<ScribbleState>(
        valueListenable: notifier[_currentImageIndex],
        builder: (context, state, _) => Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (final w in notifier[_currentImageIndex].widths)
              _buildStrokeButton(
                context,
                strokeWidth: w,
                state: state,
              ),
          ],
        ),
      );
    } catch (e) {
      return Container(); // 에러가 발생하지 않도록 기본값 반환
    }
  }

  Widget _buildStrokeButton(
    BuildContext context, {
    required double strokeWidth,
    required ScribbleState state,
  }) {
    final selected = state.selectedWidth == strokeWidth;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        elevation: selected ? 4 : 0,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => notifier[_currentImageIndex].setStrokeWidth(strokeWidth),
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: kThemeAnimationDuration,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                color: state.map(
                  drawing: (s) => Color(s.selectedColor),
                  erasing: (_) => Colors.transparent,
                ),
                border: state.map(
                  drawing: (_) => null,
                  erasing: (_) => Border.all(width: 1),
                ),
                borderRadius: BorderRadius.circular(50.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildColorToolbar(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildColorButton(context, color: Colors.black),
        _buildColorButton(context, color: Colors.red),
        _buildColorButton(context, color: Colors.green),
        _buildColorButton(context, color: Colors.blue),
        _buildColorButton(context, color: Colors.yellow),
        _buildEraserButton(context),
      ],
    );
  }

  Widget _buildPointerModeSwitcher(BuildContext context) {
    try {
      return ValueListenableBuilder(
          valueListenable: notifier[_currentImageIndex].select(
            (value) => value.allowedPointersMode,
          ),
          builder: (context, value, child) {
            return SegmentedButton<ScribblePointerMode>(
              multiSelectionEnabled: false,
              emptySelectionAllowed: false,
              onSelectionChanged: (v) =>
                  notifier[_currentImageIndex].setAllowedPointersMode(v.first),
              segments: const [
                ButtonSegment(
                  value: ScribblePointerMode.all,
                  icon: Icon(Icons.touch_app),
                  label: Text("All pointers"),
                ),
                ButtonSegment(
                  value: ScribblePointerMode.penOnly,
                  icon: Icon(Icons.draw),
                  label: Text("Pen only"),
                ),
              ],
              selected: {value},
            );
          });
    } catch (e) {
      return Container(); // 에러가 발생하지 않도록 기본값 반환
    }
  }

  Widget _buildEraserButton(BuildContext context) {
    try {
      return ValueListenableBuilder(
        valueListenable:
            notifier[_currentImageIndex].select((value) => value is Erasing),
        builder: (context, value, child) => ColorButton(
          color: Colors.transparent,
          outlineColor: Colors.black,
          isActive: value,
          onPressed: () => notifier[_currentImageIndex].setEraser(),
          child: const Icon(Icons.cleaning_services),
        ),
      );
    } catch (e) {
      return Container(); // 에러가 발생하지 않도록 기본값 반환
    }
  }

  Widget _buildColorButton(
    BuildContext context, {
    required Color color,
  }) {
    try {
      return ValueListenableBuilder(
        valueListenable: notifier[_currentImageIndex].select(
            (value) => value is Drawing && value.selectedColor == color.value),
        builder: (context, value, child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ColorButton(
            color: color,
            isActive: value,
            onPressed: () => notifier[_currentImageIndex].setColor(color),
          ),
        ),
      );
    } catch (e) {
      return Container();
    }
  }
}

class ColorButton extends StatelessWidget {
  const ColorButton({
    required this.color,
    required this.isActive,
    required this.onPressed,
    this.outlineColor,
    this.child,
    super.key,
  });

  final Color color;

  final Color? outlineColor;

  final bool isActive;

  final VoidCallback onPressed;

  final Icon? child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: kThemeAnimationDuration,
      decoration: ShapeDecoration(
        shape: CircleBorder(
          side: BorderSide(
            color: switch (isActive) {
              true => outlineColor ?? color,
              false => Colors.transparent,
            },
            width: 2,
          ),
        ),
      ),
      child: IconButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          shape: const CircleBorder(),
          side: isActive
              ? const BorderSide(color: Colors.white, width: 2)
              : const BorderSide(color: Colors.transparent),
        ),
        onPressed: onPressed,
        icon: child ?? const SizedBox(),
      ),
    );
  }
}
