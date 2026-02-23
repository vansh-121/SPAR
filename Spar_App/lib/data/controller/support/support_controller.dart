import 'dart:convert';
import 'dart:io';

import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/support/support_ticket_response_model.dart';
import 'package:hyip_lab/data/repo/support/support_repo.dart';
import 'package:get/get.dart';

import '../../../view/components/show_custom_snackbar.dart';

class SupportController extends GetxController {
  SupportRepo repo;
  SupportController({required this.repo});

  List<FileChooserModel> attachmentList = [FileChooserModel(fileName: MyStrings.noFileChosen)];

  String noFileChosen = MyStrings.noFileChosen;
  String chooseFile = MyStrings.chooseFile;


  bool isLoading = false;

  int page = 0;
  String? nextPageUrl;
  List<TicketData> ticketList = [];
  String imagePath = '';
  loadData() async {
    ticketList.clear();
    page = 0;
    isLoading = true;
    update();
    await getSupportTicket();
    isLoading = false;
    update();
  }

  Future<void> getSupportTicket() async {
    page = page + 1;

    if (page == 1) {
      ticketList.clear();
      update();
    }
    isLoading = true;
    update();

    ResponseModel responseModel = await repo.getSupportTicketList(page.toString());
    if (responseModel.statusCode == 200) {
      SupportTicketListResponseModel model = SupportTicketListResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status == MyStrings.success) {
        nextPageUrl = model.data?.tickets?.nextPageUrl;
        List<TicketData>? tempList = model.data?.tickets?.data;
        imagePath = model.data?.tickets?.path.toString() ?? '';
        if (tempList != null && tempList.isNotEmpty) {
          ticketList.addAll(tempList);
        }
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }
    isLoading = false;
    update();
  }



  bool hasNext() {
    return nextPageUrl != null && nextPageUrl!.isNotEmpty ? true : false;
  }
}

class FileChooserModel {
  late String fileName;
  late File? choosenFile;
  FileChooserModel({required this.fileName, this.choosenFile});
}
