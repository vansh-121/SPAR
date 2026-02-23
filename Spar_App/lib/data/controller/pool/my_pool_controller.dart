import 'dart:convert';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/pool/my_pool_response_model.dart';
import 'package:hyip_lab/data/repo/pool/pool_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class MypoolController extends GetxController {
  PoolRepo poolRepo;
  MypoolController({required this.poolRepo});

  bool isLoading = false;

  List<Invest> myInvests = [];
  String? nextPageUrl;
  int page = 0;

  String currency = '';
  String curSymbol = '';

  Future<void> loadData() async {
    curSymbol = poolRepo.apiClient.getCurrencyOrUsername(isSymbol: true);
    currency = poolRepo.apiClient.getCurrencyOrUsername(isCurrency: true);
    myInvests.clear();
    nextPageUrl;
    page = 0;
    isLoading = true;
    update();
    await mypoolHistroy();

    isLoading = false;
    update();
  }

  Future<void> mypoolHistroy() async {
    page = page + 1;
    update();

    ResponseModel responseModel = await poolRepo.myPools(page.toString());
    if (responseModel.statusCode == 200) {
      MypoolResponseModel model = MypoolResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status == MyStrings.success) {
        final data = model.data;
        if (data != null) {
          nextPageUrl = data.poolInvests?.nextPageUrl;
          myInvests.clear();
          myInvests.addAll(data.poolInvests?.data?.toList() ?? []);

          update();
        }
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
  }

  Future<void> mypoolHistroyPaginateData() async {
    page = page++;
    update();

    ResponseModel responseModel = await poolRepo.myPools(page.toString());
    if (responseModel.statusCode == 200) {
      MypoolResponseModel model = MypoolResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status == MyStrings.success) {
        final data = model.data;
        if (data != null) {
          nextPageUrl = data.poolInvests?.nextPageUrl;
          myInvests.addAll(data.poolInvests?.data?.toList() ?? []);
          update();
        }
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
  }

  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty ? true : false;
  }
}
