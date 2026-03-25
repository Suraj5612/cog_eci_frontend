import '../../voter/models/parsed_voter_detail.dart';

abstract class OCRState {}

class OCRInitial extends OCRState {}

class OCRLoading extends OCRState {}

class OCRSuccess extends OCRState {
  final String imagePath;
  final ParsedVoterData data;

  OCRSuccess({required this.imagePath, required this.data});
}

class OCRError extends OCRState {
  final String message;

  OCRError(this.message);
}
