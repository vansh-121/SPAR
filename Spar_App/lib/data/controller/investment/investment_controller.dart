

import 'dart:convert';

import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/my_investment/my_investment_response_model.dart' as investment;
import 'package:hyip_lab/data/repo/investment_repo/investment_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

import '../../model/authorization/authorization_response_model.dart';
import '../../model/my_investment/my_investment_response_model.dart';

class InvestmentController extends GetxController{

  InvestmentRepo repo;
  InvestmentController({required this.repo});

  bool isActive = true;
  String currency = '';
  String curSymbol = '';
  int page = 1;
  String investmentType = '';
  List<investment.Data>investmentList = [];


  Future<void>loadData()async{
   currency = repo.apiClient.getCurrencyOrUsername();
   curSymbol = repo.apiClient.getCurrencyOrUsername(isCurrency: true,isSymbol:true);
   ResponseModel response = await repo.getInvestmentData(isActive?'active':'closed', page);
   if(response.statusCode == 200){
     MyInvestmentResponseModel model = MyInvestmentResponseModel.fromJson(jsonDecode(response.responseJson));
     if(model.status?.toLowerCase() == 'success'){
       List<investment.Data>?tempList = model.data?.invests?.data;
       nextPageUrl = model.data?.invests?.nextPage;
       if(tempList!=null && tempList.isNotEmpty){
         investmentList.addAll(tempList);
       }
     } else{
       CustomSnackBar.error(errorList: model.message?.error??[MyStrings.somethingWentWrong]);
     }
   } else{
     CustomSnackBar.error(errorList: [response.message]);
   }
   isLoading = false;
   update();
  }


  String? nextPageUrl;
  bool hasNext(){
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null'? true:false;
  }


  Future<void>loadPaginationData()async{
    page = page+1;
    loadData();
  }

  bool isLoading = true;
  void changeIndex()async{
    isActive = !isActive;
    isLoading = true;
    update();
    page = 1;
    investmentList.clear();
    await loadData();
    isLoading = false;
    update();
  }


  String selectedInvestmentCapital = MyStrings.reInvest;
  List<String>investmentCapitalType = [MyStrings.reInvest,MyStrings.capitalBackType];


  void changeInvestmentCapitalType(String selectedCapitalType){
    selectedInvestmentCapital = selectedCapitalType;
    print('selected: $selectedInvestmentCapital');
    update();
  }


  bool isSubmitInvestmentLoading = false;
  Future<void>submitInvestmentData(String investmentId)async{

    isSubmitInvestmentLoading = true;
    update();

    ResponseModel response = await repo.updateInvestmentCapitalType(selectedInvestmentCapital.trim().toLowerCase().replaceAll(" ", "_"),investmentId);
    if(response.statusCode == 200){

      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(response.responseJson));
      if(model.status?.toLowerCase() == MyStrings.success.toLowerCase()){
        page = 1;
        investmentList.clear();
        await loadData();
        Get.back();
        CustomSnackBar.success(successList: model.message?.success??[MyStrings.requestSuccess]);
      } else{
        CustomSnackBar.error(errorList: model.message?.error??[MyStrings.somethingWentWrong]);
      }
    } else{
      CustomSnackBar.error(errorList: [response.message]);
    }
    isSubmitInvestmentLoading = false;
    isLoading = false;
    update();
  }




  String getMessage(int index) {
    String period  = investmentList[index].period =='-1'?MyStrings.lifeTime: '${investmentList[index].period??''} ${investmentList[index].timeName}';
    String message = '${Converter.twoDecimalPlaceFixedWithoutRounding(investmentList[index].interest??'0')} $currency ${MyStrings.every.toLowerCase()} ${investmentList[index].timeName}\nfor $period ';
    return message;
  }

 double getPercent(int index) {
    double percent = 0;
    try{
      percent = (double.tryParse(investmentList[index].nextTimePercent??'0')??0)/100;
    }catch(e){
      percent = 0;
    }
    return percent;
  }
}