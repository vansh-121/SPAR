

import 'package:hyip_lab/data/services/api_service.dart';

import '../../../core/utils/method.dart';
import '../../../core/utils/url.dart';
import '../../model/global/response_model/response_model.dart';

class RankingRepo {

  ApiClient apiClient;

  RankingRepo({ required this.apiClient});

  Future<ResponseModel> getRankingData(int page) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.rankingEndpoint}?page=$page";
    ResponseModel responseModel = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return responseModel;
  }

}