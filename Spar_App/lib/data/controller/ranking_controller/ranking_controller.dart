import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/repo/ranking/ranking_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

import '../../model/ranking/ranking_response_model.dart';
import '../../model/user/user.dart';

class RankingController extends GetxController{
  RankingRepo rankingRepo;
  RankingController({required this.rankingRepo});

  bool isLoading = true;
  List<UserRankings> allRankList = [];

  String? nextPageUrl;
  int page = 0;
  String searchReferrals = "";
  NextRanking? nextRanking ;
  User? user = User();
  String totalReffered = '0';

  String curSymbol = '';
  String currency = '';

  TextEditingController searchController = TextEditingController();


  void initData() async{

    page = 0;
    allRankList.clear();
    isLoading = true;
    update();
    curSymbol = rankingRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    currency = rankingRepo.apiClient.getCurrencyOrUsername(isCurrency: true,isSymbol: true);

    await allRankData();
    isLoading = false;
    update();

  }

  void loadPaginationData()async{
    await allRankData();
    update();
  }

  Future<void> allRankData() async{
    page = page + 1;
    if(page == 1){
      allRankList.clear();
    }

    ResponseModel responseModel = await rankingRepo.getRankingData(page);

    if(responseModel.statusCode == 200){
      RankingResponseModel rankingResponseModel = RankingResponseModel.fromJson(jsonDecode(responseModel.responseJson));

      nextRanking = rankingResponseModel.data?.nextRanking;
      user = rankingResponseModel.data?.user;
      imagePath = rankingResponseModel.data?.imagePath??'';
      // totalReffered = rankingResponseModel.data?.user?.activeReferrals?.length.toString()??"0";

      if(rankingResponseModel.status.toString().toLowerCase() == "success"){
        List<UserRankings>? tempList = rankingResponseModel.data?.userRankings;
        if(tempList != null && tempList.isNotEmpty){
          allRankList.addAll(tempList);
        }
      }
      else{
        CustomSnackBar.showCustomSnackBar(errorList: rankingResponseModel.message?.error ?? [MyStrings.requestFail.toString()], msg: [], isError: true);
      }
    }
    else{
      CustomSnackBar.showCustomSnackBar(errorList: [responseModel.message.toString()], msg: [], isError: true);
    }

    update();
  }

  bool hasNext(){
    return nextPageUrl != null && nextPageUrl!.isNotEmpty && nextPageUrl != 'null' ? true : false;
  }

  String getUnlockAmount(String minInvestString,String totalInvestString) {



    // Remove any non-numeric characters and parse the values to double
    final numericValue1 = double.tryParse(minInvestString.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    final numericValue2 = double.tryParse(totalInvestString.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;

    // Subtract the values
    final result = numericValue1 - numericValue2;

    final symbol = minInvestString.replaceAll(RegExp(r'[\d.]'), '').replaceAll(',', '');
    final formattedResult = '$symbol${result.toStringAsFixed(2)}';

    print('cur symbol: ${symbol}');

    return formattedResult;
  }

  isCross(int index) {
    int nextRank = int.tryParse( nextRanking?.id.toString()??'100')??0;
    int selectedRankId = int.tryParse(allRankList[index].id.toString()) ?? 0;


    print('user current rank: $nextRank');
    print('select rank id: $selectedRankId');


    bool isCrossCurrentRank = selectedRankId <= nextRank;

    return isCrossCurrentRank;
  }

  String imagePath = "";
  String getImageUrl(String imageUrl) {
    String image = "${UrlContainer.domainUrl}/$imagePath/$imageUrl";
    return image;
  }

}