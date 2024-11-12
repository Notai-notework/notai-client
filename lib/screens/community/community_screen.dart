import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notai/repositories/document_repository.dart';
import 'package:notai/utils/file/file_management.dart';
import 'package:notai/utils/http/api_service.dart';
import 'package:notai/utils/time/time_parser.dart';
import 'package:path_provider/path_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<dynamic> _docs = [];

  Future<void> fetchCommunityDocs() async {
    final as = await ApiService();
    Response response = await as.get("/api/documents");

    setState(() {
      _docs = response.data;
    });
  }

  Future<void> downloadDocument() async {
    // 문서 db 데이터 생성
    String url = "dd";
    // url을 사용해서 문서를 다운로드 하고,
    // 그 다운된 문서가 어떤 객체에 저장. 예를들어 뭐.. File
    //
    final dr = await DocumentRepository();
    int id = await dr.insert("문서 이름");

    // 로컬에 문서가 저장될 때
    // documents/id/document.pdf
    // documents/id/images/page_0.png

    // 문서 다운 및 로컬 저장
    final fm = await FileManagement();
    final document = await getApplicationDocumentsDirectory();
    String path = document.path;

    "$path/$id/"; // 문서 파일 자체를 저장
    "$path/$id/images/"; // page_0.png .... page_n.png
  }

  @override
  void initState() {
    super.initState();
    fetchCommunityDocs();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row(
          //   mainAxisSize: MainAxisSize.max,
          //   children: [
          //     ElevatedButton(
          //       onPressed: () {},
          //       style: ElevatedButton.styleFrom(
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(15),
          //         ),
          //       ),
          //       child: const Text('최신순'),
          //     ),
          //     const SizedBox(width: 20),
          //     ElevatedButton(
          //       onPressed: () {},
          //       style: ElevatedButton.styleFrom(
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(15),
          //         ),
          //       ),
          //       child: const Text('인기순'),
          //     ),
          //     const SizedBox(width: 20),
          //     ElevatedButton(
          //       onPressed: () {},
          //       style: ElevatedButton.styleFrom(
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(15),
          //         ),
          //       ),
          //       child: const Text('스크랩'),
          //     ),
          //     const Spacer(),
          //     const SizedBox(
          //       width: 300,
          //       child: SearchBar(
          //         trailing: [Icon(Icons.search)],
          //         backgroundColor:
          //             WidgetStatePropertyAll<Color>(Color(0xFFF5EFFF)),
          //         hintText: "검색어를 입력해주세요.",
          //       ),
          //     ),
          //   ],
          // ),
          // const SizedBox(height: 20),
          Expanded(
              child: SingleChildScrollView(
                  // scrollDirection: Axis.horizontal,
                  child: Column(
            children: [
              const SizedBox(height: 20),
              Wrap(
                spacing: 40,
                runSpacing: 60,
                children: [
                  if (!_docs.isEmpty)
                    for (int i = 0; i < _docs.length; i++)
                      DocumentItem(
                        data: _docs[i],
                        index: i,
                      )
                ],
              ),
              const SizedBox(height: 20),
            ],
          )))
        ],
      ),
    );
  }
}

class DocumentItem extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;

  const DocumentItem({super.key, required this.data, required this.index});

  @override
  _DocumentItemState createState() => _DocumentItemState();
}

class _DocumentItemState extends State<DocumentItem> {
  bool isLiked = false;
  bool isDownloading = false;

  void _showDocumentInfo(BuildContext context) {
    final tp = TimeParser();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '문서 정보',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '작성자: ${widget.data['user']['nickname']}',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  '등록일: ${tp.toFormat(widget.data['createdAt'])}',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  '태그: ${widget.data['tagName']}',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 230,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person)
                  // Image.network(
                  //     "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp"),
                  ),
              const SizedBox(width: 10),
              Text(
                widget.data['user']['nickname'],
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                child: Image.network(widget.data['previewImageUrl']
                    // "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp"
                    ),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(20.0),
                //   image: DecorationImage(
                //     image: Image.network(
                //         'https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp'),
                //     fit: BoxFit.cover,
                //   ),
                // ),
              ),
              // Positioned(
              //   top: 10,
              //   right: 10,
              //   child: IconButton(
              //     onPressed: () {
              //       setState(() {
              //         isLiked = !isLiked;
              //       });
              //     },
              //     icon: Icon(
              //       isLiked ? Icons.favorite : Icons.favorite_border,
              //       color: isLiked ? Colors.red : Colors.black,
              //       size: 30,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                widget.data['title'],
                overflow: TextOverflow.ellipsis,
                // maxLines: 1,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  if (value == 'viewInfo') {
                    _showDocumentInfo(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'scrap',
                    child: Text('스크랩하기'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'viewInfo',
                    child: Text('문서 정보 보기'),
                  ),
                  PopupMenuItem<String>(
                    onTap: () async {
                      setState(() {
                        isDownloading = true;
                      });

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('다운로드 중..'),
                          content: Center(
                              child: Column(
                            children: [
                              SizedBox(height: 30),
                              CircularProgressIndicator()
                            ],
                          )),
                          actions: [
                            if (!isDownloading)
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("닫기"))
                          ],
                        ),
                      );

                      final fm = await FileManagement();
                      fm.saveDownloadedDocument(
                          widget.data['documentFileUrl'], widget.data);

                      Navigator.pop(context);

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('다운로드 완료'),
                          content: Container(),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text("닫기"))
                          ],
                        ),
                      );
                    },
                    value: 'block',
                    child: const Text('다운로드'),
                  ),
                ],
                icon: const Icon(Icons.more_vert, color: Colors.purple),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.data['tagName'],
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
