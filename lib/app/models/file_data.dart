import 'dart:io';
import 'dart:typed_data';

class FileData {
  FileData(
      this.name,
      this.data,
      this.file,
      );

  final String name;
  final Uint8List? data;
  final File? file;
}