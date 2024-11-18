import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:notai/screens/login/login_screen.dart';
import 'package:notai/screens/main_screen.dart';
import 'package:notai/utils/color/color.dart';
import 'package:notai/utils/file/file_management.dart';
import 'package:notai/utils/http/api_service.dart';
import 'package:notai/utils/time/time_parser.dart';
import 'package:notai/widgets/document/custom_notifier.dart';
import 'package:notai/widgets/global/global_appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scribble/scribble.dart';
import 'package:value_notifier_tools/value_notifier_tools.dart';
import 'package:image/image.dart' as img;

import '../../utils/jwt/jwt.dart';

class DocumentInnerScreen extends StatefulWidget {
  final Map<String, dynamic> document;

  const DocumentInnerScreen({super.key, required this.document});

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
  bool _isChatVisible = false;

  List<GlobalKey> _globalKeys = [];
  final GlobalKey _globalKey = GlobalKey();
  bool isLoading = true;
  bool isSaving = false;
  bool isMessagesLoading = true;
  bool isSendLoading = false;

  bool isLoggedIn = false;
  Map<String, dynamic> payload = {};

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
        (index) => CustomNotifier([1, 3, 5], ScribblePointerMode.mouseAndPen));

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

  void toggleChat() {
    if (!isLoggedIn) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
      return;
    }

    if (!_isChatVisible) {
      var api = ApiService();
      // const storage = FlutterSecureStorage();
      // storage.read(key: 'Authorization').then((val) {
      //   api.dio.options.headers['Authorization'] = val;
      api.post('/api/chat-rooms').then((res) {
        api.get('/api/chat-rooms/messages').then((val) {
          setState(() {
            _messages = val.data;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
          });
        });
      });
      // });
      // print('hea: ${api.dio.options.headers}');
      // api.dio.get('/api/chat-rooms/1/messages').then((val) => print(val));
    }

    setState(() {
      isMessagesLoading = false;
      _isChatVisible = !_isChatVisible;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    });
  }

  final TextEditingController _chatInputController = TextEditingController();
  late List<dynamic> _messages = [];

  final ScrollController _scrollController = ScrollController();

  // final FocusNode _focusNode = FocusNode();

  void _sendMessage() async {
    if (_chatInputController.text.isNotEmpty) {
      String text = _chatInputController.text;
      _chatInputController.clear(); // 입력창 비우기
      setState(() {
        _messages.add({
          'content': text,
          'createdAt': null,
          'user': 1,
        });
        _messages.add({
          'content': '',
          'createdAt': null,
          'user': null,
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      });

      var response = await ApiService()
          .post('/api/chat-rooms/messages', data: {'content': text});
      setState(() {
        _messages[_messages.length - 2]['createdAt'] =
            response.data['sendMessageCreatedAt'];
        _messages[_messages.length - 1]['content'] = response.data['aiMessage'];
        _messages[_messages.length - 1]['createdAt'] =
            response.data['aiMessageCreatedAt'];
        // WidgetsBinding.instance.addPostFrameCallback((_) {
        //   _scrollToBottom();
        // });
      });
    }

    // _focusNode.requestFocus();
  }

  // 리스트의 맨 아래로 스크롤하는 함수
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    return Wrap(
      // alignment:,
      alignment:
          message['user'] != null ? WrapAlignment.end : WrapAlignment.start,
      children: [
        // if (message['user'] != null)
        // CircleAvatar(
        //   radius: 15,
        //   backgroundImage: NetworkImage(
        //       'https://cdn.prod.website-files.com/5ee12d8d7f840543bde883de/5ef3a1148ac97166a06253c1_flutter-logo-white-inset.svg'), // 프로필 이미지
        // ),
        SizedBox(width: 8),
        // 여백 추가
        Container(
          padding: EdgeInsets.fromLTRB(10, 10, 30, 10),
          margin: EdgeInsets.symmetric(vertical: 5),
          decoration: BoxDecoration(
            color: message['user'] != null ? fourColor : twoColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              message['content'] != null && message['content'] != ''
                  ? RichText(
                      text: TextSpan(children: parseText(message['content'])),
                      softWrap: true, // 자동 줄바꿈 허용
                      // overflow: TextOverflow.visible, // 초과 텍스트 처리 방식
                      // maxLines: 3, // 최대 3줄까지만 표시
                    )
                  : Center(child: CircularProgressIndicator()),
              SizedBox(height: 4),
              Text(
                message['createdAt'] != null
                    ? TimeParser().toFormat(message['createdAt'])
                    : '시간 계산 중..',
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // '**'로 감싸진 부분만 진하게 만들기
  List<TextSpan> parseText(String text) {
    List<TextSpan> spans = [];
    RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    Iterable<RegExpMatch> matches = regex.allMatches(text);

    int lastMatchEnd = 0;
    for (var match in matches) {
      // '**'로 감싸지지 않은 일반 텍스트 부분 추가
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: TextStyle(color: Colors.black),
        ));
      }

      // '**'로 감싸진 부분을 bold로 추가
      spans.add(TextSpan(
        text: match.group(1), // '**' 안의 텍스트
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ));

      lastMatchEnd = match.end;
    }

    // 마지막 매치 이후의 텍스트 추가
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: TextStyle(color: Colors.black),
      ));
    }

    return spans;
  }

  @override
  void initState() {
    super.initState();
    _fetchImages(widget.document['id']);
    _pageController = PageController();
    _checkUser();
    // delete();
  }

  Future<void> delete() async {
    final fr = FlutterSecureStorage();
    fr.delete(key: "Authorization");
  }

  Future<void> _checkUser() async {
    var storage = await FlutterSecureStorage();
    final check = await storage.read(key: "isLoggedIn");

    isLoggedIn = check == "true";

    String? access = await storage.read(key: 'Authorization');

    if (isLoggedIn) {
      setState(() {
        payload = Jwt().decodeJWT(access!)!; // 데이터 업데이트
      });
    }
  }

  @override
  void dispose() {
    // _focusNode.dispose();
    super.dispose();
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

    String titleName = widget.document['name'];

    return WillPopScope(
        onWillPop: () async {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Center(
                      child: Text("페이지를 벗어나시겠습니까?",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  actions: [
                    Center(
                        child: isSaving
                            ? CircularProgressIndicator()
                            : Text(
                                "이 페이지를 벗어나면 모든 내용이 저장되며,\n이후 수정할 수 없습니다. 그래도 진행하시겠습니까?",
                                style: TextStyle(fontSize: 20))),
                    SizedBox(height: 30),
                    Center(
                        child: Container(
                            width: 200,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.all(twoColor),
                                    // 배경 색
                                    padding: WidgetStateProperty.all(
                                        EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 24)),
                                    shape: WidgetStateProperty.all(
                                        RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(8), // 둥근 모서리
                                    )),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);

                                    setState(() {
                                      isSaving = true;
                                    });

                                    await _save(widget.document['id'],
                                        widget.document['name']);

                                    setState(() {
                                      isSaving = false;
                                    });
                                  },
                                  child: const Text('확인'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('취소'),
                                ),
                              ],
                            )))
                  ],
                );
              });
          // _save(widget.document['id'], widget.document['name']);
          return false;
        },
        child: Scaffold(
            // key: UniqueKey(),
            appBar: GlobalAppbar(
              title: Center(
                  child: Text(
                titleName,
                style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Colors.white),
              )),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  print('dd');
                  // 뒤로가기 버튼 눌렀을 때 이벤트 처리
                  // _save(widget.document['id'], widget.document['name']);
                },
              ),
              actions: [
                Container(
                    child: IconButton(
                        onPressed: () {
                          toggleChat();
                        },
                        color: _isChatVisible ? Colors.black : Colors.white,
                        icon: Icon(Icons.live_help))),
                Container(
                    child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginScreen()));
                  },
                  child: TextButton(
                      onPressed: () {
                        if (!isLoggedIn) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoginScreen()));
                          return;
                        }
                      },
                      child: Text(isLoggedIn ? payload['name'] : '로그인',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600))),
                ))
              ],
            ),
            body: Row(children: [
              Flexible(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Expanded(
                        child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: SizedBox(
                                width: double.infinity,
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
                                              print(_imagesSizes[index]);
                                              return SingleChildScrollView(
                                                  child: Center(
                                                      child: InteractiveViewer(
                                                // boundaryMargin:
                                                //     const EdgeInsets.all(20.0), f
                                                minScale: 1.0,
                                                maxScale: 4.0,
                                                child: RepaintBoundary(
                                                    key: _globalKeys[index],
                                                    child: Container(
                                                      // width: 400.0,
                                                      // height: 300.0,
                                                      width: _imagesSizes[index]
                                                          [0],
                                                      // width: 2000,
                                                      height:
                                                          _imagesSizes[index]
                                                              [1],
                                                      decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          image: DecorationImage(
                                                              image: MemoryImage(
                                                                  _images[
                                                                      index]),
                                                              fit: BoxFit
                                                                  .contain)),
                                                      child: Scribble(
                                                          notifier:
                                                              notifier[index]),
                                                    )),
                                              )));
                                            })))),
                    SizedBox(
                        width: _isChatVisible ? 800 : double.infinity,
                        height: 100,
                        child: Container(
                            margin: EdgeInsets.fromLTRB(
                                _isChatVisible ? 150 : 350, 0, 0, 0),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _buildColorToolbar(context),
                                const VerticalDivider(width: 32),
                                _buildStrokeToolbar(context),
                                const Expanded(child: SizedBox()),
                                // _buildPointerModeSwitcher(context),
                                // const Expanded(child: SizedBox()),
                              ],
                            )))
                  ])),
              _isChatVisible
                  ? isMessagesLoading
                      ? Center(child: CircularProgressIndicator())
                      : Container(
                          width: 400,
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: Column(
                            children: [
                              _messages.isEmpty
                                  ? Center(child: Text('채팅을 시작해보세요!'))
                                  : Expanded(
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        itemCount: _messages.length,
                                        itemBuilder: (context, index) {
                                          return _buildMessage(
                                              _messages[index]);
                                        },
                                        physics: BouncingScrollPhysics(),
                                      ),
                                    ),
                              Container(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        // focusNode: _focusNode,
                                        controller: _chatInputController,
                                        decoration: const InputDecoration(
                                          hintText: '메시지를 입력하세요...',
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: _sendMessage,
                                      child: Text('전송'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ))
                  : Container(width: 0)
            ])));
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

  Future<void> _save(int id, String fileName) async {
    try {
      for (int i = 0; i < _globalKeys.length; i++) {
        RenderRepaintBoundary boundary = _globalKeys[i]
            .currentContext!
            .findRenderObject() as RenderRepaintBoundary;
        ui.Image image = await boundary.toImage(pixelRatio: 1.0);
        final a = image.width;
        final b = image.height;
        ByteData? byteData =
            await image.toByteData(format: ui.ImageByteFormat.png);
        Uint8List pngBytes = byteData!.buffer.asUint8List();

        // 지정한 크기로 조정 (size.width, size.height에 맞게)
        // pngBytes = await resizeImage(
        //     pngBytes, _imagesSizes[i][0], _imagesSizes[i][1]);

        // 파일 시스템 경로 찾기
        final directory = await getApplicationDocumentsDirectory();
        print(directory.path);
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

    final fm = await FileManagement();
    await fm.convertImagesToPdf(id, fileName, _imagesSizes);

    // Navigator.pushReplacement(
    //     context, MaterialPageRoute(builder: (context) => MainScreen()));
    Navigator.pop(context);

    setState(() {
      isSaving = false;
    });
  }

  // 이미지 크기 조정 함수
  Future<Uint8List> resizeImage(
      Uint8List data, double targetWidth, double targetHeight) async {
    final originalImage = img.decodeImage(data);
    if (originalImage == null) return data;

    // 원본 이미지의 가로 세로 비율 계산
    double aspectRatio = originalImage.width / originalImage.height;

    // 목표 크기와 비율을 고려하여 리사이즈
    double newWidth = targetWidth;
    double newHeight = (newWidth / aspectRatio);

    // 높이가 목표 높이를 넘으면, 높이에 맞게 가로 크기 조정
    if (newHeight > targetHeight) {
      newHeight = targetHeight;
      newWidth = (newHeight * aspectRatio);
    }

    // 비율을 유지하며 리사이즈
    final resizedImage = img.copyResize(originalImage,
        width: newWidth.toInt(), height: newHeight.toInt());
    return Uint8List.fromList(img.encodePng(resizedImage));
  }

  void _showImage(BuildContext context, Uint8List imageFile) async {
    final image = notifier[_currentImageIndex].renderImage(pixelRatio: 2.0);
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
          onTap: () async {
            for (CustomNotifier i in notifier) {
              i.setStrokeWidth(strokeWidth);
            }
          },
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: kThemeAnimationDuration,
            width: strokeWidth * 8,
            height: strokeWidth * 8,
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
        valueListenable: notifier[0].select(
            (value) => value is Drawing && value.selectedColor == color.value),
        builder: (context, value, child) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ColorButton(
            color: color,
            isActive: value,
            // onPressed: () => notifier[_currentImageIndex].setColor(color),
            onPressed: () async {
              for (CustomNotifier i in notifier) {
                i.setColor(color);
              }
            },
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
