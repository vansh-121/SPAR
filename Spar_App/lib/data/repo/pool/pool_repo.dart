import 'package:hyip_lab/core/utils/method.dart';
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/services/api_service.dart';

class PoolRepo {
  ApiClient apiClient;
  PoolRepo({required this.apiClient});

  Future<ResponseModel> myPools(String id) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.pools}?page=$id";
    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> getPoolPlans() async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.poolPlan}";
    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> savePool({required String poolID, required String amount, required String wallet}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.pool}/${UrlContainer.save}";
    Map<String, String> params = {
      'pool_id': poolID,
      'amount': amount,
      'wallet': wallet.toLowerCase(),
    };
    final response = await apiClient.request(url, Method.postMethod, params, passHeader: true);
    return response;
  }
}
