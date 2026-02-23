import 'package:hyip_lab/core/utils/method.dart';
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/data/services/api_service.dart';

class FaqRepo{

  ApiClient apiClient;
  FaqRepo({required this.apiClient});

  Future<dynamic>loadFaq()async{
    String url='${UrlContainer.baseUrl}${UrlContainer.faqEndPoint}';
    final response=await apiClient.request(url,Method.getMethod,null);
    return response;
  }

}