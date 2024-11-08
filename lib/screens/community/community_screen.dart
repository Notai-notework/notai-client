import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:notai/repositories/document_repository.dart';
import 'package:notai/utils/file/file_management.dart';
import 'package:notai/utils/http/api_service.dart';
import 'package:path_provider/path_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  List<Map<String, dynamic>> _docs = [
    {
      'id': 1,
      'title': "title1",
      'user': {'id': 1, 'email': "a@test.com", 'nickname': "userAnick"},
      'content': "content1",
      "documentFileUrl":
          "https://notai.s3.ap-northeast-2.amazonaws.com/document/07468a77-3880-4267-a80d-681ed9783785/%E1%84%89%E1%85%A9%E1%84%91%E1%85%B3%E1%84%90%E1%85%B3%E1%84%8B%E1%85%B0%E1%84%8B%E1%85%A5%20%E1%84%80%E1%85%A9%E1%86%BC%E1%84%92%E1%85%A1%E1%86%A8%20%E1%84%8C%E1%85%A5%E1%86%BC%E1%84%85%E1%85%B5%E1%84%87%E1%85%A9%E1%86%AB.pdf.pdf",
      "previewImageUrl":
          "https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8JTIzaW1hZ2V8ZW58MHx8MHx8fDA%3D",
      'tagName': "CS",
      'createdAt': "2024-10-22T10:49:29.27212",
      "updatedAt": "2024-10-22T10:49:29.27212"
    },
    {
      'id': 2,
      'title': "title1",
      'user': {'id': 1, 'email': "a@test.com", 'nickname': "userAnick"},
      'content': "content1",
      "documentFileUrl":
          "https://notai.s3.ap-northeast-2.amazonaws.com/document/07468a77-3880-4267-a80d-681ed9783785/%E1%84%89%E1%85%A9%E1%84%91%E1%85%B3%E1%84%90%E1%85%B3%E1%84%8B%E1%85%B0%E1%84%8B%E1%85%A5%20%E1%84%80%E1%85%A9%E1%86%BC%E1%84%92%E1%85%A1%E1%86%A8%20%E1%84%8C%E1%85%A5%E1%86%BC%E1%84%85%E1%85%B5%E1%84%87%E1%85%A9%E1%86%AB.pdf.pdf",
      "previewImageUrl":
          "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp",
      'tagName': "CS",
      'createdAt': "2024-10-22T10:49:29.27212",
      "updatedAt": "2024-10-22T10:49:29.27212"
    },
    {
      'id': 3,
      'title': "title1",
      'user': {'id': 1, 'email': "a@test.com", 'nickname': "userAnick"},
      'content': "content1",
      "documentFileUrl":
          "https://notai.s3.ap-northeast-2.amazonaws.com/document/07468a77-3880-4267-a80d-681ed9783785/%E1%84%89%E1%85%A9%E1%84%91%E1%85%B3%E1%84%90%E1%85%B3%E1%84%8B%E1%85%B0%E1%84%8B%E1%85%A5%20%E1%84%80%E1%85%A9%E1%86%BC%E1%84%92%E1%85%A1%E1%86%A8%20%E1%84%8C%E1%85%A5%E1%86%BC%E1%84%85%E1%85%B5%E1%84%87%E1%85%A9%E1%86%AB.pdf.pdf",
      "previewImageUrl":
          "https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8JTIzaW1hZ2V8ZW58MHx8MHx8fDA%3D",
      'tagName': "CS",
      'createdAt': "2024-10-22T10:49:29.27212",
      "updatedAt": "2024-10-22T10:49:29.27212"
    },
    {
      'id': 4,
      'title': "title1",
      'user': {'id': 1, 'email': "a@test.com", 'nickname': "userAnick"},
      'content': "content1",
      "documentFileUrl":
          "https://notai.s3.ap-northeast-2.amazonaws.com/document/07468a77-3880-4267-a80d-681ed9783785/%E1%84%89%E1%85%A9%E1%84%91%E1%85%B3%E1%84%90%E1%85%B3%E1%84%8B%E1%85%B0%E1%84%8B%E1%85%A5%20%E1%84%80%E1%85%A9%E1%86%BC%E1%84%92%E1%85%A1%E1%86%A8%20%E1%84%8C%E1%85%A5%E1%86%BC%E1%84%85%E1%85%B5%E1%84%87%E1%85%A9%E1%86%AB.pdf.pdf",
      "previewImageUrl":
          "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp",
      'tagName': "CS",
      'createdAt': "2024-10-22T10:49:29.27212",
      "updatedAt": "2024-10-22T10:49:29.27212"
    },
    {
      'id': 5,
      'title': "title1",
      'user': {'id': 1, 'email': "a@test.com", 'nickname': "userAnick"},
      'content': "content1",
      "documentFileUrl":
          "https://notai.s3.ap-northeast-2.amazonaws.com/document/07468a77-3880-4267-a80d-681ed9783785/%E1%84%89%E1%85%A9%E1%84%91%E1%85%B3%E1%84%90%E1%85%B3%E1%84%8B%E1%85%B0%E1%84%8B%E1%85%A5%20%E1%84%80%E1%85%A9%E1%86%BC%E1%84%92%E1%85%A1%E1%86%A8%20%E1%84%8C%E1%85%A5%E1%86%BC%E1%84%85%E1%85%B5%E1%84%87%E1%85%A9%E1%86%AB.pdf.pdf",
      "previewImageUrl":
          "https://plus.unsplash.com/premium_photo-1664474619075-644dd191935f?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8JTIzaW1hZ2V8ZW58MHx8MHx8fDA%3D",
      'tagName': "CS",
      'createdAt': "2024-10-22T10:49:29.27212",
      "updatedAt": "2024-10-22T10:49:29.27212"
    },
    {
      'id': 6,
      'title': "title1",
      'user': {'id': 1, 'email': "a@test.com", 'nickname': "userAnick"},
      'content': "content1",
      "documentFileUrl":
          "https://notai.s3.ap-northeast-2.amazonaws.com/document/07468a77-3880-4267-a80d-681ed9783785/%E1%84%89%E1%85%A9%E1%84%91%E1%85%B3%E1%84%90%E1%85%B3%E1%84%8B%E1%85%B0%E1%84%8B%E1%85%A5%20%E1%84%80%E1%85%A9%E1%86%BC%E1%84%92%E1%85%A1%E1%86%A8%20%E1%84%8C%E1%85%A5%E1%86%BC%E1%84%85%E1%85%B5%E1%84%87%E1%85%A9%E1%86%AB.pdf.pdf",
      "previewImageUrl":
          "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp",
      'tagName': "CS",
      'createdAt': "2024-10-22T10:49:29.27212",
      "updatedAt": "2024-10-22T10:49:29.27212"
    },
  ];

  Future<void> fetchCommunityDocs() async {
    final as = await ApiService();
    Response response = await as.get("/api/documents");
    _docs = response.data;
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
    // fetchCommunityDocs();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('최신순'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('인기순'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text('스크랩'),
              ),
              const Spacer(),
              const SizedBox(
                width: 300,
                child: SearchBar(
                  trailing: [Icon(Icons.search)],
                  backgroundColor:
                      WidgetStatePropertyAll<Color>(Color(0xFFF5EFFF)),
                  hintText: "검색어를 입력해주세요.",
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < 3; i++) const DocumentItem(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DocumentItem extends StatefulWidget {
  const DocumentItem({super.key});

  @override
  _DocumentItemState createState() => _DocumentItemState();
}

class _DocumentItemState extends State<DocumentItem> {
  bool isLiked = false;

  void _showDocumentInfo(BuildContext context) {
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
                const Text(
                  '작성자: 작성자 이름',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                const Text(
                  '등록일: 2024-10-28',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 5),
                const Text(
                  '태그: 문서 태그1, 문서 태그2, 문서 태그3',
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
              CircleAvatar(
                child: Image.network(
                    "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp"),
              ),
              const SizedBox(width: 10),
              const Text(
                '작성자 이름',
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
                child: Image.network(
                    "https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp"),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(20.0),
                //   image: DecorationImage(
                //     image: Image.network(
                //         'https://img-cdn.pixlr.com/image-generator/history/65bb506dcb310754719cf81f/ede935de-1138-4f66-8ed7-44bd16efc709/medium.webp'),
                //     fit: BoxFit.cover,
                //   ),
                // ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      isLiked = !isLiked;
                    });
                  },
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.black,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '문서 제목',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
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
                  const PopupMenuItem<String>(
                    value: 'block',
                    child: Text('차단하기'),
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
          const Text(
            '문서 태그1, 문서 태그2, 문서 태그3',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
