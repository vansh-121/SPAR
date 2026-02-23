import '../../../core/utils/method.dart';
import '../../../core/utils/url.dart';
import '../../model/auth/sign_up_model/sign_up_model.dart';
import '../../model/global/response_model/response_model.dart';
import '../../services/api_service.dart';

class RegistrationRepo {
  ApiClient apiClient;

  RegistrationRepo({required this.apiClient});

  Future<ResponseModel> registerUser(SignUpModel model) async {
    final map = model.toMap();
    String url ='${UrlContainer.baseUrl}${UrlContainer.registrationEndPoint}';
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, map,passHeader: true,isOnlyAcceptType: true);
    return responseModel;
  }

  Future<ResponseModel> getMetaMaskLoginMessage(String address) async {
    Map<String, String> map = {
      'wallet_address': address,
    };
    String url = '${UrlContainer.baseUrl}${UrlContainer.metamaskGetMessageEndPoint}';

    ResponseModel model = await apiClient.request(url, Method.postMethod, map, passHeader: false);

    return model;
  }

  Future<ResponseModel> verifyMetaMaskLoginSignature({
    required String walletAddress,
    required String message,
    required String signature,
    required String nonce,
  }) async {
    Map<String, String> map = {
      'message': message,
      'wallet': walletAddress,
      'nonce': nonce,
      'signature': signature,
    };
    String url = '${UrlContainer.baseUrl}${UrlContainer.metamaskMessageVerifyEndPoint}';

    ResponseModel model = await apiClient.request(url, Method.postMethod, map, passHeader: false);

    return model;
  }

}