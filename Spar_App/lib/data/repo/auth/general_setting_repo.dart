import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/url.dart';

import '../../../core/utils/method.dart';
import '../../../data/services/api_service.dart';
import '../../model/global/response_model/response_model.dart';


class GeneralSettingRepo {

  ApiClient apiClient;
  GeneralSettingRepo({required this.apiClient});

  Future<dynamic> getGeneralSetting() async {
    try{
      String url='${UrlContainer.baseUrl}${UrlContainer.generalSettingEndPoint}';
      ResponseModel response= await apiClient.request(url,Method.getMethod, null,passHeader: false);
      return response;
    }catch(e){
      return ResponseModel(false, MyStrings.somethingWentWrong.tr, 300, '');
    }
  }

  Future<dynamic> deleteAccount(String password) async {

    try{
      String url='${UrlContainer.baseUrl}${UrlContainer.accountDelete}';
      final params = {"password": password};
      ResponseModel response= await apiClient.request(url,Method.postMethod, params,passHeader: true);
      return response;
    }catch(e){
      return ResponseModel(false, MyStrings.somethingWentWrong.tr, 300, '');
    }

  }

  Future<dynamic> getLanguage(String languageCode) async {
    try{
      String url='${UrlContainer.baseUrl}${UrlContainer.languageUrl}$languageCode';
      ResponseModel response= await apiClient.request(url,Method.getMethod, null,passHeader: false);
      return response;
    }catch(e){
      return ResponseModel(false, MyStrings.somethingWentWrong, 300, '');
    }
  }

  Future<dynamic>getUserInfo() async {
    String url='${UrlContainer.baseUrl}${UrlContainer.getProfileEndPoint}';
    ResponseModel response= await apiClient.request(url,Method.getMethod, null,passHeader: true);
    return response;
  }

}
