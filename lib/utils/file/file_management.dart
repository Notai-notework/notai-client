import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:notai/repositories/document_repository.dart';
import 'package:notai/utils/http/api_service.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class FileManagement {
  static final FileManagement _instance = FileManagement._internal();

  FileManagement._internal();

  factory FileManagement() {
    return _instance;
  }

  Future<void> saveDownloadedDocument(
      String downloadUrl, Map<String, dynamic> data) async {
    final dr = await DocumentRepository();
    int id = await dr.insert(data['title']);

    Directory directory = await getApplicationDocumentsDirectory();
    String basePath = "${directory.path}/$id";

    Response response =
        await Dio().download(downloadUrl, "$basePath/${data['title']}.pdf");

    if (response.statusCode == 200) {
      await saveDocument(
          id, "$basePath/${data['title']}.pdf", data['title'], true);
    }
  }

  // 문서를 로컬에 저장
  // id: DB로부터 부여받은 id
  // file: 문서 파일
  Future<void> saveDocument(
      int id, String filePath, String fileName, bool isDown) async {
    Directory directory = await getApplicationDocumentsDirectory();
    print(directory.path);

    String newFilePath = p.join(directory.path, id.toString());
    if (!await Directory(newFilePath).exists()) {
      Directory(newFilePath).create(recursive: true);
    }

    newFilePath = p.join(newFilePath, fileName);
    await File(newFilePath).create(recursive: true);
    final originFile = await File(filePath);
    await originFile.copy(newFilePath); // 저장된 문서

    // return;
    final pdf = PdfImageRendererPdf(path: filePath);
    await pdf.open();

    int pageCount = await pdf.getPageCount();
    for (int i = 0; i < pageCount; i++) {
      final size = await pdf.getPageSize(pageIndex: i);
      print("${i} ${size.width}");
      print("${i} ${size.height}");

      final img = await pdf.renderPage(
        pageIndex: i,
        x: 0,
        y: 0,
        width: size.width,
        // you can pass a custom size here to crop the image
        height: size.height,
        // you can pass a custom size here to crop the image
        scale: isDown ? 1 : 1,
        // increase the scale for better quality (e.g. for zooming)
        background: Colors.white,
      );

      // final imagePath = directory.path + "/$id/images/page_$i.png";
      var imagePath = p.join(directory.path, id.toString(), 'images');
      if (!await Directory(imagePath).exists()) {
        Directory(imagePath).create(recursive: true);
      }

      imagePath = p.join(imagePath, 'page_${i + 1}.png');
      await File(imagePath).create(recursive: true);
      final newImg = await File(imagePath);
      await newImg.writeAsBytes(img as List<int>);
    }
  }

  // pdf 파일 모든 페이지를 이미지로 변환 후 로컬에 저장
  // 예외 처리는 나중에,,
  Future<void> _documentToImages(int id, File file) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String basePath = directory.path + "/" + id.toString() + "/images/";

    final pdf = PdfImageRendererPdf(path: file.path);
    await pdf.open();

    final pageCount = await pdf.getPageCount();
    for (int i = 0; i < pageCount; i++) {
      await pdf.openPage(pageIndex: i);
      final size = await pdf.getPageSize(pageIndex: i);

      final image = await pdf.renderPage(
          pageIndex: i,
          x: 0,
          y: 0,
          width: size.width,
          height: size.height,
          scale: 1,
          background: Colors.white);

      final imageFile = File(basePath + "page_$id.png");
      imageFile.writeAsBytes(image!);
    }

    print('file images saved!');
    print(Directory(basePath));
  }

  // 페이지 이미지들을 pdf로 병합
  Future<void> convertImagesToPdf(
      int id, String fileName, List<List<double>> sizes) async {
    final pdf = pw.Document();

    Directory directory = await getApplicationDocumentsDirectory();
    String path = "${directory.path}/$id/images";

    List<FileSystemEntity> pdfs =
        Directory("${directory.path}/$id").listSync(); // 해당 폴더의 파일 목록

    // .pdf 파일만 선택하여 삭제
    for (var file in pdfs) {
      if (file is File && file.path.endsWith('.pdf')) {
        try {
          await file.delete(); // 파일 삭제
          print('Deleted: ${file.path}');
        } catch (e) {
          print('Error deleting file: ${file.path}, error: $e');
        }
      }
    }

    List<FileSystemEntity> files = Directory(path).listSync(); // 해당 폴더의 파일 목록

    // PNG 파일만 필터링
    List<File> pngFiles = files
        .whereType<File>()
        .where((file) => file.path.endsWith('.png'))
        .toList();

    pngFiles.sort((a, b) {
      // 파일명에서 숫자 추출을 위한 정규 표현식
      final int numA = int.parse(
          RegExp(r'\d+').firstMatch(a.path.split('/').last)!.group(0)!);
      final int numB = int.parse(
          RegExp(r'\d+').firstMatch(b.path.split('/').last)!.group(0)!);

      // 숫자 기준 비교
      return numA.compareTo(numB);
    }); // 정렬

    // 각 PNG 파일을 PDF의 페이지로 추가
    for (int i = 0; i < pngFiles.length; i++) {
      final image = pw.MemoryImage(
        File(pngFiles[i].path).readAsBytesSync(), // PNG 파일을 바이트로 읽기
      );

      // PDF에 페이지 추가
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(image, width: sizes[i][0], height: sizes[i][1]),
            );
          },
        ),
      );
    }

    // PDF 저장 경로 설정
    String pdfPath = '${directory.path}/$id/$fileName.pdf';
    final outputFile = File(pdfPath);

    // PDF 파일 저장
    await outputFile.writeAsBytes(await pdf.save());
    print("PDF 파일이 생성되었습니다: $pdfPath");
  }

  Future<void> removeDocument(int id) async {
    Directory directory = await getApplicationDocumentsDirectory();
    Directory path = Directory("${directory.path}/$id");

    if (await path.exists()) {
      // 내부 파일과 하위 디렉토리 삭제
      await path.delete(recursive: true);
      print('폴더와 내부 파일이 성공적으로 삭제되었습니다.');
    } else {
      print('지정한 경로에 폴더가 존재하지 않습니다.');
    }
  }
}
