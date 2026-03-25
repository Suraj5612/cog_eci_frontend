import 'dart:io';
import 'package:cog_eci_frontend/features/ocr/bloc/ocr_bloc.dart';
import 'package:cog_eci_frontend/features/ocr/bloc/ocr_event.dart';
import 'package:cog_eci_frontend/features/ocr/bloc/ocr_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_loader.dart';

class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  const ImagePreviewScreen({super.key, required this.imagePath});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  File? imageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    imageFile = File(widget.imagePath);
  }

  Future<void> _cropImage() async {
    final cropped = await ImageCropper().cropImage(
      sourcePath: imageFile!.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
          hideBottomControls: false,
          cropFrameStrokeWidth: 2,
        ),
      ],
    );

    if (cropped != null) {
      setState(() {
        imageFile = File(cropped.path);
      });
    }
  }

  void _retake() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OCRBloc, OCRState>(
      listener: (context, state) {
        if (state is OCRSuccess) {
          context.push(
            '/voter-details',
            extra: {'imagePath': state.imagePath, 'data': state.data},
          );
        }

        if (state is OCRError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final bloc = context.read<OCRBloc>();
        return Stack(
          children: [
            Scaffold(
              backgroundColor: AppColors.secondary,
              appBar: AppBar(title: const Text("Preview")),

              body: Column(
                children: [
                  Expanded(
                    child: imageFile != null
                        ? Image.file(imageFile!, fit: BoxFit.contain)
                        : const Center(child: Text("No Image")),
                  ),

                  Container(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _cropImage,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                child: Text(
                                  "Crop",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _retake,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                child: Text(
                                  "Retake",
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              bloc.add(ProcessOCR(imageFile!));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              "Process OCR",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (state is OCRLoading) const AppLoader(),
          ],
        );
      },
    );
  }
}
