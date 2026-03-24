import '../../../core/services/api_base_helper.dart';
import '../models/user_model.dart';

class AuthRepository {
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await ApiBaseHelper.post('/auth/login', {
      "username": username,
      "password": password,
    });

    return response;
  }

  Future<UserModel> getProfile() async {
    final response = await ApiBaseHelper.get('/auth/getUser');

    return UserModel.fromJson(response['data']);
  }
}
