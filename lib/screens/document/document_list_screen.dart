import 'dart:io';

import 'package:dio/src/response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:notai/repositories/document_repository.dart';
import 'package:notai/screens/document/document_inner_screen.dart';
import 'package:notai/screens/login/login_screen.dart';
import 'package:notai/utils/color/color.dart';
import 'package:notai/utils/file/file_management.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/http/api_service.dart';
import '../../utils/jwt/jwt.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListState();
}

class _DocumentListState extends State<DocumentListScreen> {
  bool _isDocumentLoading = false;
  List<Map<String, dynamic>>? _documents = [];
  bool isLoggedIn = false;
  Map<String, dynamic> payload = {};
  bool isUploading = false;
  List<ValueNotifier<bool>> _bookmarks = [];

  late final List<TextEditingController> _documentNameInputControllers;

  TextEditingController _descInput = TextEditingController();
  TextEditingController _tagInput = TextEditingController();

  void toggleIsDocumentLoading() {
    _isDocumentLoading = !_isDocumentLoading;
  }

  void _showModalDialog(BuildContext context) {
    // 모달 창을 표시하고 로딩 애니메이션을 활성화
    showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 클릭 시 닫기 방지
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로딩 중'),
          content: const Row(
            mainAxisSize: MainAxisSize.min, // 최소 크기 유지
            children: [
              SizedBox(
                width: 24, // 원하는 너비 설정
                height: 24, // 원하는 높이 설정
                child: CircularProgressIndicator(),
              ),
              SizedBox(width: 20), // 아이콘과 텍스트 사이 간격
              Expanded(child: Text('문서를 가져오고 있습니다...')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // 로딩을 중단하고 모달 창 닫기
                toggleIsDocumentLoading();
                Navigator.of(context).pop();
              },
              child: Text('중단'),
            ),
          ],
        );
      },
    );

    // 로딩 상태 관리
    setState(() {
      _isDocumentLoading = true;
    });

    // 로딩을 계속 표시
    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    // 조건이 충족될 때까지 계속 대기
    while (_isDocumentLoading) {
      await Future.delayed(Duration(seconds: 1)); // 1초 간격으로 대기
      // 필요한 비즈니스 로직을 추가할 수 있습니다.
    }
  }

  void _stopLoading() {
    // 다른 곳에서 호출하여 로딩을 중단
    setState(() {
      _isDocumentLoading = false; // 로딩 상태를 false로 설정
    });
    // 모달을 닫기
    Navigator.of(context).pop(); // 모달을 닫음
  }

  Future<void> _importDocument() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) {
      return;
    }

    _showModalDialog(context);

    PlatformFile file = result.files.first;
    String name = file.name;
    String? path = file.path;

    final dr = DocumentRepository();
    int id = await dr.insert(name);
    final fm = FileManagement();
    await fm.saveDocument(id, path!, name, false);

    setState(() {
      dr.getDocuments().then((e) {
        _documents = e;
        _documentNameInputControllers
            .add(TextEditingController(text: file.name.split('.').first));
        _stopLoading();
      });
    });
  }

  Future<void> _fetchDocuments() async {
    final dr = DocumentRepository();
    var result = await dr.getDocuments();

    setState(() {
      _documents = result;
      _documentNameInputControllers = result
          .map((item) => TextEditingController(text: item['name']))
          .toList();

      for (var e in _documents!) {
        _bookmarks.add(ValueNotifier(e['is_bookmark'] == 1));
      }

      // print(_bookmarks);
    });
  }

  Future<File> _getPreviewImage(int id) async {
    Directory directory = await getApplicationDocumentsDirectory();
    return await File(directory.path + "/$id/images/page_1.png");
  }

  // 문서 이름 수정
  Future<void> _modifyDocumentName(int id, String newName, int index) async {
    final dr = DocumentRepository();
    await dr.updateName(id, newName);
    setState(() {
      _documents?[index].update('name', (value) => newName);
    });
  }

  // 문서 삭제
  Future<void> _removeDocument(int id) async {
    final dr = DocumentRepository();
    final fm = FileManagement();

    await dr.remove(id);
    await fm.removeDocument(id);

    setState(() {
      _documents?.removeWhere((e) => e['id'] == id);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
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
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(60),
        child: SingleChildScrollView(
            child: Wrap(spacing: 40, runSpacing: 60, children: [
          Container(
              decoration: BoxDecoration(
                color: twoColor,
                border: Border.all(
                  color: twoColor,
                  width: 3,
                  style: BorderStyle.solid, // 기본 스타일은 solid
                ),
                borderRadius: BorderRadius.circular(8), // 둥근 모서리
              ),
              // color: twoColor,
              width: 180,
              height: 220,
              child: TextButton(
                  onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Text('문서 추가',
                                    style: TextStyle(fontSize: 25)),
                                const SizedBox(height: 15),
                                TextButton(
                                    onPressed: () async {
                                      await _importDocument();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('문서(PDF) 불러오기')),
                                const SizedBox(height: 15),
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
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('닫기'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 150,
                        height: 160,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                            style: BorderStyle.solid, // 기본 스타일은 solid
                          ),
                        ),
                        child: const Align(
                          child: Icon(Icons.add),
                        ),
                      ),
                      const Text('문서 불러오기..')
                    ],
                  ))),
          if (!_documents!.isEmpty)
            ...?_documents?.asMap().entries.map((entry) {
              int index = entry.key;
              var element = entry.value;
              return GestureDetector(
                  onTap: () {
                    // _showOptionsModal(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      if (element != null && element.containsKey('id')) {
                        return DocumentInnerScreen(document: element);
                      } else {
                        // element가 null이거나 id가 없으면 에러 처리 혹은 다른 로직 실행
                        return Container(); // ErrorScreen은 예시이며, 상황에 맞는 다른 위젯을 반환할 수 있습니다.
                      }
                    }));
                  },
                  child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white54, // 배경 색상
                        border: Border.all(
                          color: Colors.black, // 테두리 색상
                          width: 1, // 테두리 두께
                        ),
                        borderRadius: BorderRadius.circular(10), // 모서리 둥글기
                      ),
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      width: 180,
                      height: 220,
                      child: Stack(children: [
                        Column(
                          children: [
                            FutureBuilder(
                                future: _getPreviewImage(element['id']),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator(); // 로딩 중인 경우
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        'Error: ${snapshot.error}'); // 에러가 발생한 경우
                                  }
                                  return Expanded(
                                      child: Image.file(
                                    fit: BoxFit.contain,
                                    snapshot.data!,
                                    width: double.infinity,
                                  )); // 이미지를 성공적으로 가져온 경우
                                }),
                            TextButton(
                                onPressed: () => showDialog<String>(
                                      context: context,
                                      builder: (BuildContext context) => Dialog(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              const SizedBox(height: 15),
                                              Text(element['name'],
                                                  style:
                                                      TextStyle(fontSize: 20)),
                                              const SizedBox(height: 15),
                                              TextButton(
                                                  onPressed: () => showDialog(
                                                      context: context,
                                                      builder:
                                                          (BuildContext
                                                                  context) =>
                                                              Dialog(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const Text(
                                                                          '문서 이름 수정'),
                                                                      const SizedBox(
                                                                          height:
                                                                              15),
                                                                      Container(
                                                                          width:
                                                                              400,
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              10.0),
                                                                          child:
                                                                              TextField(
                                                                            controller:
                                                                                _documentNameInputControllers[index],
                                                                            decoration:
                                                                                const InputDecoration(
                                                                              border: OutlineInputBorder(),
                                                                            ),
                                                                          )),
                                                                      const SizedBox(
                                                                          height:
                                                                              15),
                                                                      Container(
                                                                          width:
                                                                              300,
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              TextButton(
                                                                                style: ButtonStyle(
                                                                                  backgroundColor: WidgetStateProperty.all(twoColor),
                                                                                  // 배경 색
                                                                                  padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
                                                                                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(8), // 둥근 모서리
                                                                                  )),
                                                                                ),
                                                                                onPressed: () {
                                                                                  _modifyDocumentName(element['id'], _documentNameInputControllers[index].text, index);
                                                                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                                                                },
                                                                                child: const Text('저장'),
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: const Text('닫기'),
                                                                              )
                                                                            ],
                                                                          ))
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                  child:
                                                      const Text('문서 이름 수정')),
                                              TextButton(
                                                  onPressed: () => showDialog(
                                                      context: context,
                                                      builder:
                                                          (BuildContext
                                                                  context) =>
                                                              Dialog(
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      const Text(
                                                                          '문서 삭제'),
                                                                      const SizedBox(
                                                                          height:
                                                                              15),
                                                                      Container(
                                                                          width:
                                                                              400,
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              10.0),
                                                                          child:
                                                                              Text('해당 문서를 삭제하시겠습니까?')),
                                                                      const SizedBox(
                                                                          height:
                                                                              15),
                                                                      Container(
                                                                          width:
                                                                              300,
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              TextButton(
                                                                                style: ButtonStyle(
                                                                                  backgroundColor: WidgetStateProperty.all(twoColor),
                                                                                  // 배경 색
                                                                                  padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
                                                                                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                                                                    borderRadius: BorderRadius.circular(8), // 둥근 모서리
                                                                                  )),
                                                                                ),
                                                                                onPressed: () {
                                                                                  _removeDocument(element['id']);
                                                                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                                                                },
                                                                                child: const Text('삭제'),
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: const Text('취소'),
                                                                              )
                                                                            ],
                                                                          ))
                                                                    ],
                                                                  ),
                                                                ),
                                                              )),
                                                  child: const Text('문서 삭제')),
                                              TextButton(
                                                  onPressed: () {
                                                    if (!isLoggedIn) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            content: SizedBox(
                                                                height: 100,
                                                                child: Center(
                                                                    child: Text(
                                                                        "로그인이 필요합니다"))),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pushReplacement(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              LoginScreen())); // 모달 창 닫기
                                                                },
                                                                child: Center(
                                                                    child: Text(
                                                                        '확인')),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      return;
                                                    }
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            Dialog(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Column(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                        width:
                                                                            900,
                                                                        height:
                                                                            450,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            FutureBuilder(
                                                                                future: _getPreviewImage(element['id']),
                                                                                builder: (context, snapshot) {
                                                                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                                                                    return CircularProgressIndicator(); // 로딩 중인 경우
                                                                                  } else if (snapshot.hasError) {
                                                                                    return Text('Error: ${snapshot.error}'); // 에러가 발생한 경우
                                                                                  }
                                                                                  return Container(
                                                                                      width: 300,
                                                                                      height: 350,
                                                                                      // color: Colors.pink,
                                                                                      child: Center(
                                                                                          child: Image.file(
                                                                                        fit: BoxFit.contain,
                                                                                        snapshot.data!,
                                                                                        width: double.infinity,
                                                                                      ))); // 이미지를 성공적으로 가져온 경우
                                                                                }),
                                                                            Container(
                                                                              width: 600,
                                                                              child: Padding(
                                                                                  padding: EdgeInsets.fromLTRB(30, 40, 20, 20),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      SizedBox(
                                                                                          width: double.infinity,
                                                                                          child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                                                            Text(
                                                                                              element['name'],
                                                                                              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                            Text(
                                                                                              "작성자: ${payload['name']}",
                                                                                              style: TextStyle(fontSize: 20),
                                                                                            )
                                                                                          ])),
                                                                                      SizedBox(height: 20),
                                                                                      TextField(
                                                                                        controller: _descInput,
                                                                                        maxLines: 3,
                                                                                        // 최대 줄 수 설정
                                                                                        decoration: InputDecoration(
                                                                                          border: OutlineInputBorder(),
                                                                                          hintText: '해당 문서에 대한 간단한 소개를 입력해주세요..',
                                                                                        ),
                                                                                        keyboardType: TextInputType.multiline, // 키보드 타입 설정
                                                                                      ),
                                                                                      SizedBox(height: 20),
                                                                                      TextField(
                                                                                        controller: _tagInput,
                                                                                        maxLines: 1,
                                                                                        // 최대 줄 수 설정
                                                                                        decoration: InputDecoration(
                                                                                          border: OutlineInputBorder(),
                                                                                          hintText: '해시태그를 입력해주세요.. (ex. 수학)',
                                                                                        ),
                                                                                        keyboardType: TextInputType.multiline, // 키보드 타입 설정
                                                                                      ),
                                                                                      SizedBox(height: 30),
                                                                                      SizedBox(
                                                                                          width: double.infinity,
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                            children: [
                                                                                              SizedBox(
                                                                                                  width: 200,
                                                                                                  child: TextButton(
                                                                                                    style: ButtonStyle(
                                                                                                      backgroundColor: WidgetStateProperty.all(threeColor),
                                                                                                      // 배경 색
                                                                                                      padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
                                                                                                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(8), // 둥근 모서리
                                                                                                      )),
                                                                                                    ),
                                                                                                    onPressed: () {
                                                                                                      if (_descInput.text.isEmpty || _tagInput.text.isEmpty) {
                                                                                                        showDialog(
                                                                                                          context: context,
                                                                                                          builder: (BuildContext context) {
                                                                                                            return AlertDialog(
                                                                                                              // title: Text(''),
                                                                                                              content: SizedBox(
                                                                                                                  height: 100,
                                                                                                                  child: Center(
                                                                                                                      child: Text(
                                                                                                                    '내용을 입력해주세요',
                                                                                                                    style: TextStyle(fontSize: 20),
                                                                                                                  ))),
                                                                                                              actions: [
                                                                                                                TextButton(
                                                                                                                  onPressed: () {
                                                                                                                    Navigator.of(context).pop(); // 모달 창 닫기
                                                                                                                  },
                                                                                                                  child: Center(child: Text('닫기')),
                                                                                                                ),
                                                                                                              ],
                                                                                                            );
                                                                                                          },
                                                                                                        );
                                                                                                        return;
                                                                                                      }
                                                                                                      showDialog(
                                                                                                          context: context,
                                                                                                          builder: (context) => Dialog(
                                                                                                                child: Padding(
                                                                                                                  padding: const EdgeInsets.all(8.0),
                                                                                                                  child: Column(
                                                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                    children: [
                                                                                                                      const SizedBox(height: 15),
                                                                                                                      const Text(
                                                                                                                        '문서 공유',
                                                                                                                        style: TextStyle(fontSize: 20),
                                                                                                                      ),
                                                                                                                      const SizedBox(height: 15),
                                                                                                                      Container(width: 400, padding: const EdgeInsets.all(10.0), child: Center(child: Text('해당 문서를 공유 하시겠습니까?'))),
                                                                                                                      const SizedBox(height: 15),
                                                                                                                      Container(
                                                                                                                          width: 300,
                                                                                                                          child: isUploading
                                                                                                                              ? Center(child: CircularProgressIndicator())
                                                                                                                              : Row(
                                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                                  children: [
                                                                                                                                    TextButton(
                                                                                                                                      style: ButtonStyle(
                                                                                                                                        backgroundColor: WidgetStateProperty.all(twoColor),
                                                                                                                                        // 배경 색
                                                                                                                                        padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
                                                                                                                                        shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                                                                                                                          borderRadius: BorderRadius.circular(8), // 둥근 모서리
                                                                                                                                        )),
                                                                                                                                      ),
                                                                                                                                      onPressed: () async {
                                                                                                                                        showDialog(
                                                                                                                                          context: context,
                                                                                                                                          builder: (BuildContext context) {
                                                                                                                                            return AlertDialog(
                                                                                                                                              // title: Text(''),
                                                                                                                                              content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                                                                                                                                            );
                                                                                                                                          },
                                                                                                                                        );

                                                                                                                                        setState(() {
                                                                                                                                          isUploading = true;
                                                                                                                                        });

                                                                                                                                        final as = await ApiService();
                                                                                                                                        var response = await as.uploadDocument(element['id'], _descInput.text, _tagInput.text);

                                                                                                                                        setState(() {
                                                                                                                                          isUploading = false;
                                                                                                                                          _descInput.text = "";
                                                                                                                                          _tagInput.text = "";
                                                                                                                                        });

                                                                                                                                        Navigator.of(context).pop();

                                                                                                                                        showDialog(
                                                                                                                                          context: context,
                                                                                                                                          builder: (BuildContext context) {
                                                                                                                                            return AlertDialog(
                                                                                                                                              // title: Text(''),
                                                                                                                                              content: SizedBox(height: 100, child: Center(child: Text("등록 되었습니다"))),
                                                                                                                                              actions: [
                                                                                                                                                if (!isUploading)
                                                                                                                                                  TextButton(
                                                                                                                                                    onPressed: () {
                                                                                                                                                      Navigator.of(context).popUntil((route) => route.isFirst); // 모달 창 닫기
                                                                                                                                                    },
                                                                                                                                                    child: Center(child: Text('닫기')),
                                                                                                                                                  ),
                                                                                                                                              ],
                                                                                                                                            );
                                                                                                                                          },
                                                                                                                                        );
                                                                                                                                      },
                                                                                                                                      child: const Text('확인'),
                                                                                                                                    ),
                                                                                                                                    TextButton(
                                                                                                                                      onPressed: () {
                                                                                                                                        Navigator.pop(context);
                                                                                                                                      },
                                                                                                                                      child: const Text('취소'),
                                                                                                                                    )
                                                                                                                                  ],
                                                                                                                                ))
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ));
                                                                                                      // await ApiService().uploadDocument(element['id']);
                                                                                                    },
                                                                                                    child: const Text('공유하기'),
                                                                                                  )),
                                                                                              SizedBox(
                                                                                                  width: 200,
                                                                                                  child: TextButton(
                                                                                                    style: ButtonStyle(
                                                                                                      backgroundColor: WidgetStateProperty.all(twoColor),
                                                                                                      // 배경 색
                                                                                                      padding: WidgetStateProperty.all(EdgeInsets.symmetric(vertical: 12, horizontal: 24)),
                                                                                                      shape: WidgetStateProperty.all(RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(8), // 둥근 모서리
                                                                                                      )),
                                                                                                    ),
                                                                                                    onPressed: () {
                                                                                                      Navigator.pop(context);
                                                                                                    },
                                                                                                    child: const Text('취소'),
                                                                                                  ))
                                                                                            ],
                                                                                          ))
                                                                                    ],
                                                                                  )),
                                                                            )
                                                                          ],
                                                                        ))
                                                                  ],
                                                                ),
                                                              ),
                                                            ));
                                                  },
                                                  child: const Text('문서 공유')),
                                              const SizedBox(height: 15),
                                              TextButton(
                                                style: ButtonStyle(
                                                  backgroundColor:
                                                      WidgetStateProperty.all(
                                                          twoColor),
                                                  // 배경 색
                                                  padding:
                                                      WidgetStateProperty.all(
                                                          EdgeInsets.symmetric(
                                                              vertical: 12,
                                                              horizontal: 24)),
                                                  shape: WidgetStateProperty.all(
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8), // 둥근 모서리
                                                  )),
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('닫기'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                child: Text(element['name']))
                          ],
                        ),
                        Positioned(
                            top: -10,
                            right: 0,
                            child: IconButton(
                              icon: Icon(
                                element['is_bookmark'] == 0
                                    ? Icons.star_outline
                                    : Icons.star,
                                size: 30,
                                color: Colors.yellow,
                              ),
                              onPressed: () async {
                                final dr = await DocumentRepository();
                                int result =
                                    await dr.updateBookmark(element['id']);
                                setState(() {
                                  element['is_bookmark'] = result;
                                });
                              },
                            ))
                      ])));
            })
        ])));
  }
}
