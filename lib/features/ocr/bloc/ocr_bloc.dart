import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/ocr_service.dart';
import '../../voter/models/parsed_voter_detail.dart';
import '../services/image_processing_service.dart';
import '../services/voter_form_roi.dart';
import 'ocr_event.dart';
import 'ocr_state.dart';

class OCRBloc extends Bloc<OCREvent, OCRState> {
  OCRBloc() : super(OCRInitial()) {
    on<ProcessOCR>(_processOCR);
  }

  Future<void> _processOCR(ProcessOCR event, Emitter<OCRState> emit) async {
    emit(OCRLoading());

    try {
      // STEP 1: Enhance image
      final enhancedFile = await ImageProcessingService.enhanceImage(
        event.image,
      );
      // STEP 2: Extract ROI FROM ENHANCED IMAGE
      final roiFile = await VoterFormRoiExtractor.extractTopInfoBand(
        enhancedFile.path,
      );
      // STEP 3: OCR on ROI
      final ocrService = OcrService();
      final rawText = await ocrService.extractTextFromImage(enhancedFile.path);
      // DEBUG
      print("FINAL OCR TEXT:");
      print(rawText);
      final parsedData = ParsedVoterData.parse(rawText);
      // STEP 4: Emit success
      emit(OCRSuccess(imagePath: enhancedFile.path, data: parsedData));
    } catch (e) {
      emit(OCRError(e.toString()));
    }
  }
}
