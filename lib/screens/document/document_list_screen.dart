import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notai/repositories/document_repository.dart';
import 'package:notai/screens/document/document_inner_screen.dart';
import 'package:notai/utils/file/file_management.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListState();
}

class _DocumentListState extends State<DocumentListScreen> {
  bool _isDocumentLoading = false;
  List<Map<String, dynamic>>? _documents = [];

  late final List<TextEditingController> _documentNameInputControllers;

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
    await fm.saveDocument(id, path!, name);

    _stopLoading();

    setState(() {
      _fetchDocuments();
    });
  }

  void _fetchDocuments() async {
    final dr = DocumentRepository();
    var result = await dr.getDocuments();

    setState(() {
      _documents = result;
      _documentNameInputControllers = result
          .map((item) => TextEditingController(text: item['name']))
          .toList();
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

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(60),
        child: SingleChildScrollView(
            child: Wrap(spacing: 40, runSpacing: 60, children: [
          Container(
              color: Colors.greenAccent,
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
                                const Text('새로 만들기'),
                                const SizedBox(height: 15),
                                TextButton(
                                    onPressed: () {
                                      _importDocument();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('문서(PDF) 불러오기')),
                                const SizedBox(height: 15),
                                TextButton(
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
                        return DocumentInnerScreen(documentId: element['id']);
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
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 0),
                      width: 180,
                      height: 220,
                      child: Column(
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
                                                style: TextStyle(fontSize: 20)),
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
                                                                            border:
                                                                                OutlineInputBorder(),
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
                                                child: const Text('이름 수정')),
                                            const SizedBox(height: 15),
                                            TextButton(
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
                      )));
            })
        ])));
  }
}
