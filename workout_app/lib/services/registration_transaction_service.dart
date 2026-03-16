import 'package:shared/shared.dart';
import '../services/api_client.dart';

class RegistrationTransactionService {
  final ApiClient _apiClient;

  RegistrationTransactionService({ApiClient? apiClient}): _apiClient = apiClient ?? ApiClient();

  Future<AppUser?> completeRegistration({required SignUpParams signUpParams,required HealthUpdateParams healthParams,}) async {
    final response = await _apiClient.completeRegistration(signUpParams, healthParams);
    if (response['user'] != null) {
      return AppUser.fromJson(response['user'] as Map<String, dynamic>);
    }
    return null;
  }
}
