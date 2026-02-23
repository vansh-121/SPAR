import 'package:hyip_lab/core/utils/method.dart';
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/services/api_service.dart';

class SheduleRepo {
  ApiClient apiClient;
  SheduleRepo({required this.apiClient});

  Future<ResponseModel> getSheduleData(int page) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.sheduleEndPoint}?page=$page";

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }

  Future<ResponseModel> getSheduleStatus(int id) async {
    String url = "${UrlContainer.baseUrl}${UrlContainer.sheduleStatusEndPoint}/$id";

    final response = await apiClient.request(url, Method.getMethod, null, passHeader: true);
    return response;
  }
}
