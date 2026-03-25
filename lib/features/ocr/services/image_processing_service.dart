import 'dart:io';
import 'package:image/image.dart' as img;

class ImageProcessingService {
  static Future<File> enhanceImage(File file) async {
    final bytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) return file;

    image = img.grayscale(image);

    image = img.adjustColor(image, contrast: 1.5);

    image = img.convolution(image, filter: [0, -1, 0, -1, 5, -1, 0, -1, 0]);

    final enhancedBytes = img.encodeJpg(image);

    final newPath = file.path.replaceFirst('.jpg', '_enhanced.jpg');
    final newFile = File(newPath);

    await newFile.writeAsBytes(enhancedBytes);

    return newFile;
  }
}
