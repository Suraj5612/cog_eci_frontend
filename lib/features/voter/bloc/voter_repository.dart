import '../../../core/exceptions/api_exception.dart';
import '../../../core/services/api_base_helper.dart';
import '../models/voter_model.dart';

class VoterRepository {
  Future<void> saveVoter(Map<String, dynamic> data) async {
    try {
      await ApiBaseHelper.post("/voters", data);
    } on ApiException {
      rethrow; // already clean
    } catch (e) {
      throw ApiException(
        message: "Something went wrong while saving voter",
        statusCode: 500,
      );
    }
  }

  Future<int> getVoterCount() async {
    try {
      final res = await ApiBaseHelper.get("/voters/count");

      return (res['data']?['total'] ?? 0) as int;
    } catch (e) {
      throw Exception("Failed to fetch count");
    }
  }

  Future<List<VoterModel>> getAllVoters() async {
    try {
      final res = await ApiBaseHelper.get("/voters");

      final List data = res['data'];

      return data.map((e) => VoterModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception("Failed to fetch voters");
    }
  }
}
