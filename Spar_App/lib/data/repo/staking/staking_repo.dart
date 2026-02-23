import 'package:hyip_lab/core/utils/method.dart';
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/services/api_service.dart';

class StakingRepo {
  ApiClient apiClient;
  StakingRepo({required this.apiClient});
  Future<ResponseModel> getStakData(int page) {
    String url = "${UrlContainer.baseUrl}${UrlContainer.staking}?page=$page";
    final response = apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> submitStak({required String duration, required String amount, required String wallet}) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.staking}/${UrlContainer.save}";
    Map<String, String> params = {'duration': duration, 'amount': amount, 'wallet': wallet.toLowerCase()};
    final response = apiClient.request(url, Method.postMethod, params, passHeader: true);
    return response;
  }
}
