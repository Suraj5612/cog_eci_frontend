import 'dart:io';

abstract class OCREvent {}

class ProcessOCR extends OCREvent {
  final File image;

  ProcessOCR(this.image);
}
