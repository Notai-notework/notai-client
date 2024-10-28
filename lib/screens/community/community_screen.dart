import 'package:flutter/material.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {

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
          const Row(
            children: [
              CircleAvatar(
                backgroundImage: AssetImage('assets/user.jpeg'),
              ),
              SizedBox(width: 10),
              Text(
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  image: const DecorationImage(
                    image: AssetImage('assets/ex.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
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
