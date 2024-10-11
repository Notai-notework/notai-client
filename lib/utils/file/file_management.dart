import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class FileManagement {
  static final FileManagement _instance = FileManagement._internal();

  FileManagement._internal();

  factory FileManagement() {
    return _instance;
  }

  // 문서를 로컬에 저장
  // id: DB로부터 부여받은 id
  // file: 문서 파일
  Future<void> saveDocument(int id, String filePath, String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();

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
      final img = await pdf.renderPage(
        pageIndex: i,
        x: 0,
        y: 0,
        width: 450,
        // you can pass a custom size here to crop the image
        height: 640,
        // you can pass a custom size here to crop the image
        scale: 1,
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
}
