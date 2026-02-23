import 'package:hyip_lab/core/utils/method.dart';
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/services/api_service.dart';

class TwoFactorRepo {

  ApiClient apiClient;
  TwoFactorRepo({required this.apiClient});

  Future<ResponseModel> verify(String code) async {
    final map = {
      'code': code,
    };
    String url = '${UrlContainer.baseUrl}${UrlContainer.verify2FAUrl}';
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, map, passHeader: true);
    return responseModel;
  }

  Future<ResponseModel> get2FaData() async {
    String url = '${UrlContainer.baseUrl}${UrlContainer.twoFactor}';
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);

    return responseModel;
  }

  Future<ResponseModel> enable2fa(String key, String code) async {
    final map = {
      'secret': key,
      'code': code,
    };

    String url = '${UrlContainer.baseUrl}${UrlContainer.twoFactorEnable}';
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, map, passHeader: true);

    return responseModel;
  }

  Future<ResponseModel> disable2fa(String code) async {
    final map = {
      'code': code,
    };

    String url = '${UrlContainer.baseUrl}${UrlContainer.twoFactorDisable}';
    ResponseModel responseModel = await apiClient.request(url, Method.postMethod, map, passHeader: true);

    return responseModel;
  }

}
