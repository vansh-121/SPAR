import 'dart:convert';
import 'dart:io';

import 'package:hyip_lab/core/helper/shared_preference_helper.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/authorization/authorization_response_model.dart';
import 'package:hyip_lab/data/model/global/response_model/response_model.dart';
import 'package:hyip_lab/data/model/support/support_ticket_view_response_model.dart';
import 'package:hyip_lab/data/repo/support/support_repo.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../../../view/components/show_custom_snackbar.dart';

class TicketDetailsController extends GetxController {
  SupportRepo repo;
  final String ticketId;
  String username = '';
  bool isRtl = false;

  TicketDetailsController({required this.repo, required this.ticketId});

  loadData() async {
    isLoading = true;
    update();
    String languageCode = repo.apiClient.sharedPreferences.getString(SharedPreferenceHelper.languageCode) ?? 'eng';
    if (languageCode == 'ar') {
      isRtl = true;
    }
    loadUserName();
    await loadTicketDetailsData();
    isLoading = false;
    update();
  }

  void loadUserName() {
    username = repo.apiClient.getCurrencyOrUsername(isCurrency: false);
  }

  bool isLoading = false;

  final TextEditingController replyController = TextEditingController();

  MyTickets? receivedTicketModel;
  List<File> attachmentList = [];

  String noFileChosen = MyStrings.noFileChosen;
  String chooseFile = MyStrings.chooseFile;

  String ticketImagePath = "";

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.custom, allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf', 'doc', 'docx']);

    if (result == null) return;

    if(result.files.length > 5){
      CustomSnackBar.error(errorList: [MyStrings.selectMaxFiveItems]);
      return;
    }

    for (var i = 0; i < result.files.length; i++) {
      attachmentList.add(File(result.files[i].path!));
    }
    update();
    return;
  }



  removeAttachmentFromList(int index) {
    if (attachmentList.length > index) {
      attachmentList.removeAt(index);
      update();
    }
  }

  SupportTicketViewResponseModel model = SupportTicketViewResponseModel();
  List<SupportMessage> messageList = [];
  String ticket = '';
  String subject = '';
  String status = '-1';
  String ticketName = '';

  Future<void> loadTicketDetailsData({bool shouldLoad = true}) async {
    isLoading = shouldLoad;
    update();
    ResponseModel response = await repo.getSingleTicket(ticketId);

    if (response.statusCode == 200) {
      model = SupportTicketViewResponseModel.fromJson(jsonDecode(response.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        ticket = model.data?.myTickets?.ticket ?? '';
        subject = model.data?.myTickets?.subject ?? '';
        status = model.data?.myTickets?.status ?? '';
        ticketName = model.data?.myTickets?.name ?? '';
        receivedTicketModel = model.data?.myTickets;
        List<SupportMessage>? tempTicketList = model.data?.myMessages;
        if (tempTicketList != null && tempTicketList.isNotEmpty) {
          messageList.clear();
          messageList.addAll(tempTicketList);
        }
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      }
    } else {
      CustomSnackBar.error(errorList: [response.message]);
    }

    isLoading = false;
    update();
  }

  bool submitLoading = false;
  Future<void> submitReply() async {
    if (replyController.text.toString().isEmpty) {
      CustomSnackBar.error(errorList: [MyStrings.replyTicketEmptyMsg]);
      return;
    }
    submitLoading = true;
    update();

    try {
      bool b = await repo.replyTicket(replyController.text, attachmentList, receivedTicketModel?.id.toString() ?? "-1");

      if (b) {
        await loadTicketDetailsData(shouldLoad: false);
        CustomSnackBar.success(successList: [MyStrings.repliedSuccessfully]);
        replyController.text = '';
        refreshAttachmentList();
      }
    } catch (e) {
      submitLoading = false;
      update();
    } finally {
      submitLoading = false;
      update();
    }
  }

  setTicketModel(MyTickets? ticketModel) {
    receivedTicketModel = ticketModel;
    update();
  }

  void clearAllData() {
    refreshAttachmentList();
    replyController.clear();
    messageList.clear();
  }

  void refreshAttachmentList() {
    attachmentList.clear();
    update();
  }

  bool closeLoading = false;
  void closeTicket(String supportTicketID) async {
    closeLoading = true;
    update();
    ResponseModel responseModel = await repo.closeTicket(supportTicketID);
    if (responseModel.statusCode == 200) {
      AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(responseModel.responseJson));
      if (model.status?.toLowerCase() == MyStrings.success.toLowerCase()) {
        clearAllData();
        Get.back(result: "updated");
        CustomSnackBar.success(successList: model.message?.success ?? [MyStrings.requestSuccess]);
      } else {
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.requestFail]);
      }
    } else {
      CustomSnackBar.error(errorList: [responseModel.message]);
    }

    closeLoading = false;
    update();
  }

  //download pdf
  TargetPlatform? platform;
  String downLoadId = "";

  Future<String?> _findLocalPath() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        return directory.path;
      } else {
        return (await getExternalStorageDirectory())?.path ?? "";
      }
    } else if (Platform.isIOS) {
      return (await getApplicationDocumentsDirectory()).path;
    } else {
      return null;
    }
  }

  bool isSubmitLoading = false;
  int selectedIndex = -1;

  String _localPath = '';
  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }
  }

  Future<void> downloadAttachment(String url, int index, String extention, Attachment attachment) async {
    selectedIndex = index;
    isSubmitLoading = true;
    attachment.isLoading = true;
    update();

    _prepareSaveDir();

    final headers = {
      'Authorization': "Bearer ${repo.apiClient.token}",
      'content-type': "application/pdf",
    };

    final response = await http.get(Uri.parse(url), headers: headers);
    print(url);
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;

      await saveAndOpenPDF(bytes, '${MyStrings.appName} ${DateTime.now()}.$extention');
    } else {
      try {
        AuthorizationResponseModel model = AuthorizationResponseModel.fromJson(jsonDecode(response.body));
        CustomSnackBar.error(errorList: model.message?.error ?? [MyStrings.somethingWentWrong]);
      } catch (e) {
        CustomSnackBar.error(errorList: [MyStrings.somethingWentWrong]);
      }
    }
    selectedIndex = -1;
    attachment.isLoading = false;
    isSubmitLoading = false;
    update();
  }

  Future<void> saveAndOpenPDF(List<int> bytes, String fileName) async {
    final path = '$_localPath/$fileName';
    final file = File(path);
    await file.writeAsBytes(bytes);
    await openPDF(path);
  }

  Future<void> openPDF(String path) async {
    final file = File(path);
    if (await file.exists()) {
      final result = await OpenFile.open(path);
      if (result.type == ResultType.done) {
      } else {
        CustomSnackBar.error(errorList: [MyStrings.fileNotFound]);
      }
    } else {
      CustomSnackBar.error(errorList: [MyStrings.fileNotFound]);
    }
  }
 
}
