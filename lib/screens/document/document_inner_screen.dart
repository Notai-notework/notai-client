import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:notai/screens/login/login_screen.dart';
import 'package:notai/utils/color/color.dart';
import 'package:notai/utils/http/api_service.dart';
import 'package:notai/utils/time/time_parser.dart';
import 'package:notai/widgets/document/custom_notifier.dart';
import 'package:notai/widgets/global/global_appbar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:scribble/scribble.dart';
import 'package:value_notifier_tools/value_notifier_tools.dart';

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

  void toggleChat() {
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
  late List<dynamic> _messages = [
    {
      "id": 1,
      "user": {"id": 1, "email": "a@test.com", "nickname": "userAnick"},
      "content": "수학이란",
      "createdAt": "2024-10-17T09:57:13.050208",
      "updatedAt": "2024-10-17T09:57:13.050208"
    },
    {
      "id": 2,
      "user": null,
      "content":
          " 수학은 수, 양, 구조, 공간, 변화를 다루는 학문입니다. 수학은 추상적인 개념을 사용하여 패턴을 연구하고, 현실 세계를 설명하고, 문제를 해결합니다. 수학은 과학, 기술, 의학, 경제, 금융, 컴퓨터 과학 등 다양한 분야에서 필수적인 역할을 합니다.\n\n수학은 다음과 같은 주요 분야로 나눌 수 있습니다.\n\n* **산술:** 숫자와 연산을 다루는 분야입니다.\n* **대수:** 변수, 방정식, 함수 등을 다루는 분야입니다.\n* **기하학:** 공간과 도형을 다루는 분야입니다.\n* **미적분:** 변화율, 극한, 무한 등을 다루는 분야입니다.\n* **통계:** 데이터를 수집, 분석, 해석하는 분야입니다.\n\n수학은 인간의 사고 방식을 발전시키고, 문제 해결 능력을 향상시키는 데 도움을 줍니다. 수학은 또한 창의성, 논리적 사고, 분석적 사고, 문제 해결 능력을 개발하는 데 도움을 줍니다.\n\n수학은 인류 역사에서 중요한 역할을 해왔습니다. 수학은 건축, 천문학, 항해, 의학 등 다양한 분야에서 사용되어 왔습니다. 오늘날 수학은 컴퓨터 과학, 인공 지능, 금융, 의학 등 다양한 분야에서 필수적인 역할을 하고 있습니다.\n",
      "createdAt": "2024-10-17T09:57:15.895478",
      "updatedAt": "2024-10-17T09:57:15.895478"
    },
    {
      "id": 3,
      "user": {"id": 1, "email": "a@test.com", "nickname": "userAnick"},
      "content": "과학이란",
      "createdAt": "2024-10-17T09:57:30.627245",
      "updatedAt": "2024-10-17T09:57:30.627245"
    },
    {
      "id": 4,
      "user": null,
      "content":
          "과학은 자연과 우주에 대한 체계적인 지식, 연구 및 응용을 포함하는 광범위한 분야입니다. \n\n**과학의 핵심 특징은 다음과 같습니다.**\n\n* **관찰과 실험:** 과학은 자연 현상을 관찰하고 실험을 통해 데이터를 수집합니다.\n* **가설과 이론:** 관찰과 실험을 통해 얻은 데이터를 기반으로 가설을 세우고 이를 검증하기 위한 이론을 개발합니다.\n* **객관성:** 과학은 객관적인 증거와 논리적 추론에 기반합니다.\n* **검증 가능성:** 과학적 주장은 다른 과학자들에 의해 검증 가능해야 합니다.\n* **체계성:** 과학은 체계적인 방법론을 사용하여 지식을 축적하고 발전시킵니다.\n\n**과학의 주요 분야는 다음과 같습니다.**\n\n* **자연과학:** 물리학, 화학, 생물학, 지구과학 등 자연 현상을 연구합니다.\n* **사회과학:** 심리학, 사회학, 경제학 등 인간 행동과 사회 현상을 연구합니다.\n* **공학:** 과학적 지식을 활용하여 기술적 문제를 해결합니다.\n* **의학:** 질병의 원인과 치료법을 연구합니다.\n\n**과학의 중요성은 다음과 같습니다.**\n\n* **지식과 이해:** 과학은 자연과 우주에 대한 지식을 제공합니다.\n* **기술 발전:** 과학은 새로운 기술 개발을 이끌어 냅니다.\n* **문제 해결:** 과학은 사회적 문제를 해결하는 데 도움이 됩니다.\n* **삶의 질 향상:** 과학은 의료, 식량, 에너지 등 삶의 질을 향상시키는 데 기여합니다.\n\n과학은 지속적으로 발전하고 변화하는 분야이며, 새로운 발견과 기술 개발을 통해 우리의 세상을 더 잘 이해하고 개선할 수 있도록 돕습니다.\n",
      "createdAt": "2024-10-17T09:57:34.221458",
      "updatedAt": "2024-10-17T09:57:34.221458"
    }
  ];

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
  }

  Future<void> _checkUser() async {
    var storage = await FlutterSecureStorage();
    String? access = await storage.read(key: 'Authorization');
    isLoggedIn = access != null;

    if (access != null) {
      setState(() {
        payload = Jwt().decodeJWT(access)!; // 데이터 업데이트
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

    return Scaffold(
        // key: UniqueKey(),
        appBar: GlobalAppbar(
          title: Center(
              child: Text(
            titleName,
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white),
          )),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // 뒤로가기 버튼 눌렀을 때 이벤트 처리
              _save(widget.document['id']);
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
                  onPressed: () async {
                    // print('dd');
                    // FlutterSecureStorage storage = await FlutterSecureStorage();
                    // var response = await ApiService().post('/login',
                    //     data: {'email': 'a@test.com', 'password': '1234'});
                    // // await storage.delete(key: 'Authorization');
                    // await storage.write(
                    //     key: 'Authorization',
                    //     value: response.headers['Authorization']![0]);
                    // await storage.write(
                    //     key: 'refresh',
                    //     value: response.headers['refresh']![0]);
                    // String? auh = await storage.read(key: 'Authorization');
                    // print('auh: $auh');
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
                                                      fit: BoxFit.contain)),
                                              child: Scribble(
                                                  notifier: notifier[index]),
                                            )),
                                      ));
                                    }))),
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
                                      return _buildMessage(_messages[index]);
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
