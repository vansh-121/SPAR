import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/shared_preference_helper.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/data/model/profile/profile_post_model.dart';
import 'package:hyip_lab/data/model/profile/profile_response_model.dart';
import 'package:hyip_lab/data/repo/account/profile_repo.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';
import '../../model/global/response_model/response_model.dart';
import '../../model/user/user.dart';

class ProfileController extends GetxController {
  ProfileRepo profileRepo;
  ProfileResponseModel model = ProfileResponseModel();

  ProfileController({required this.profileRepo});

  String imageUrl = '';

  bool isLoading = false;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  FocusNode firstNameFocusNode = FocusNode();
  FocusNode lastNameFocusNode = FocusNode();
  FocusNode emailFocusNode = FocusNode();
  FocusNode mobileNoFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode zipCodeFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();

  File? imageFile;

  String depositWallet = "";
  String interestWallet = "";

  loadProfileInfo() async {
    isLoading = true;
    update();
    ProfileResponseModel responseModel = await profileRepo.loadProfileInfo();
    model = responseModel;
    if(model.data!=null && model.status?.toLowerCase()==MyStrings.success.toLowerCase()){
      loadData(model);
    }else{
      isLoading=false;
      update();
    }
  }

  bool isSubmitLoading = false;
  updateProfile()async{

    isSubmitLoading = true;
    update();

    String firstName  =  firstNameController.text;
    String lastName   =  lastNameController.text.toString();
    String address    =  addressController.text.toString();
    String city       =  cityController.text.toString();
    String zip        =  zipCodeController.text.toString();
    String state      =  stateController.text.toString();
    User?  user       =  model.data?.user;

    if(firstName.isNotEmpty && lastName.isNotEmpty){
      isLoading = true;
      update();

      ProfilePostModel model = ProfilePostModel(
          address: address,
          state: state,
          zip: zip,
          city: city,
          firstname: firstName,
          lastName: lastName
      );

      bool b = await profileRepo.updateProfile(model,true);

      if(b){
        await loadProfileInfo();
      }
    }else{
      if(firstName.isEmpty){
        CustomSnackBar.error(errorList: [ MyStrings.kFirstNameNullError.tr]);
      } if(lastName.isEmpty){
        CustomSnackBar.error(errorList: [MyStrings.kLastNameNullError.tr]);
      }
    }

    isSubmitLoading = false;
    update();

  }

  bool user2faIsOne = false;
  void loadData(ProfileResponseModel? model) {
    firstNameController.text = model?.data?.user?.firstname ?? '';
    profileRepo.apiClient.sharedPreferences.setString(SharedPreferenceHelper.userNameKey, '${model?.data?.user?.username}');
    lastNameController.text = model?.data?.user?.lastname ?? '';
    emailController.text = model?.data?.user?.email ?? '';
    mobileNoController.text = model?.data?.user?.mobile ?? '';
    addressController.text = model?.data?.user?.address ?? '';
    stateController.text = model?.data?.user?.state ?? '';
    zipCodeController.text = model?.data?.user?.zip ?? '';
    cityController.text = model?.data?.user?.city ?? '';
    // imageUrl = model?.data?.user?.image == null ? '' : '${model?.data?.user?.image}';
    user2faIsOne = model?.data?.user?.ts == '1' ? true : false;
    depositWallet = model?.data?.user?.depositWallet == null ? '' : '${model?.data?.user?.depositWallet}';
    interestWallet = model?.data?.user?.interestWallet == null ? '' : '${model?.data?.user?.interestWallet}';
    isLoading = false;

    update();
  }
}
