import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/view/components/checkbox/custom_check_box.dart';
import 'package:hyip_lab/view/components/custom_drop_down_button_with_text_field.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/custom_no_data_found_class.dart';
import 'package:hyip_lab/view/components/custom_radio_button.dart';
import 'package:hyip_lab/view/components/text-field/custom_text_field.dart';
import '../../../../core/utils/dimensions.dart';
import '../../../../data/controller/kyc_controller/kyc_controller.dart';
import '../../../../data/model/kyc/kyc_response_model.dart' as kyc;
import '../../../../data/repo/kyc/kyc_repo.dart';
import '../../../../data/services/api_service.dart';
import '../../../components/rounded_button.dart';
import '../../../components/text/label_text_with_instructions.dart';
import '../../withdraw/withdraw_money/confirm_withdraw_screen/widget/choose_file_list_item.dart';
import 'widget/already_verifed.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({Key? key}) : super(key: key);

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(KycRepo(apiClient: Get.find()));
    Get.put(KycController(repo: Get.find()));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<KycController>().beforeInitLoadKycData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<KycController>(
      builder: (controller) => Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: CustomAppBar(
          title: MyStrings.kyc.tr,
          bgColor: MyColor.getAppbarBgColor(),
        ),
        body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: controller.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(Dimensions.defaultPadding),
                    child: CustomLoader())
                : controller.isAlreadyVerified
                    ? const AlreadyVerifiedWidget()
                    : controller.isAlreadyPending
                        ? const AlreadyVerifiedWidget(
                            isPending: true,
                          )
                        : controller.isNoDataFound
                            ? const NoDataOrInternetScreen(
                                message: '',
                                message2: MyStrings.goBackLogMsg,
                              )
                            : Center(
                                child: SingleChildScrollView(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    margin: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: MyColor.getScreenBgColor(),
                                        boxShadow: [
                                          BoxShadow(
                                            color: MyColor.getBorderColor()
                                                .withOpacity(0.3),
                                            spreadRadius: 1,
                                            blurRadius: 1,
                                            offset: const Offset(0,
                                                1), // changes position of shadow
                                          ),
                                        ]),
                                    child: Form(
                                      key: formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 35,
                                          ),
                                          ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              scrollDirection: Axis.vertical,
                                              itemCount:
                                                  controller.formList.length,
                                              itemBuilder: (ctx, index) {
                                                kyc.KycFormModel? model =
                                                    controller.formList[index];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      model.type == 'text' ||
                                                              model.type ==
                                                                  'number' ||
                                                              model.type ==
                                                                  'email' ||
                                                              model.type ==
                                                                  'url'
                                                          ? Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                CustomTextField(
                                                                  hintText: (model
                                                                              .name ??
                                                                          '')
                                                                      .toLowerCase()
                                                                      .capitalizeFirst,
                                                                  needLabel:
                                                                      true,
                                                                  isShowInstructionWidget:
                                                                      true,
                                                                  instructions:
                                                                      model
                                                                          .instruction,
                                                                  needOutlineBorder:
                                                                      true,
                                                                  labelText:
                                                                      model.name ??
                                                                          '',
                                                                  isRequired:
                                                                      model.isRequired ==
                                                                              'optional'
                                                                          ? false
                                                                          : true,
                                                                  textInputType: model
                                                                              .type ==
                                                                          'number'
                                                                      ? TextInputType
                                                                          .number
                                                                      : model.type ==
                                                                              'email'
                                                                          ? TextInputType
                                                                              .emailAddress
                                                                          : model.type == 'url'
                                                                              ? TextInputType.url
                                                                              : TextInputType.text,
                                                                  onChanged:
                                                                      (value) {
                                                                    controller
                                                                        .changeSelectedValue(
                                                                            value,
                                                                            index);
                                                                  },
                                                                  validator:
                                                                      (value) {
                                                                    if (model.isRequired !=
                                                                            'optional' &&
                                                                        value
                                                                            .toString()
                                                                            .isEmpty) {
                                                                      return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                    } else {
                                                                      return null;
                                                                    }
                                                                  },
                                                                ),
                                                                const SizedBox(
                                                                  height: 10,
                                                                ),
                                                              ],
                                                            )
                                                          : model.type ==
                                                                  'textarea'
                                                              ? Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    CustomTextField(
                                                                      needLabel:
                                                                          true,
                                                                      instructions:
                                                                          model
                                                                              .instruction,
                                                                      needOutlineBorder:
                                                                          true,
                                                                      isShowInstructionWidget:
                                                                          true,
                                                                      labelText:
                                                                          model.name ??
                                                                              '',
                                                                      isRequired: model.isRequired ==
                                                                              'optional'
                                                                          ? false
                                                                          : true,
                                                                      hintText: (model.name ??
                                                                              '')
                                                                          .capitalizeFirst,
                                                                      textInputType:
                                                                          TextInputType
                                                                              .multiline,
                                                                      maxLines:
                                                                          5,
                                                                      onChanged:
                                                                          (value) {
                                                                        controller.changeSelectedValue(
                                                                            value,
                                                                            index);
                                                                      },
                                                                      validator:
                                                                          (value) {
                                                                        if (model.isRequired !=
                                                                                'optional' &&
                                                                            value.toString().isEmpty) {
                                                                          return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                        } else {
                                                                          return null;
                                                                        }
                                                                      },
                                                                    ),
                                                                    const SizedBox(
                                                                      height:
                                                                          10,
                                                                    ),
                                                                  ],
                                                                )
                                                              : model.type ==
                                                                      'select'
                                                                  ? Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        LabelTextInstruction(
                                                                          text: model.name ??
                                                                              '',
                                                                          isRequired: model.isRequired == 'optional'
                                                                              ? false
                                                                              : true,
                                                                          instructions:
                                                                              model.instruction,
                                                                        ),
                                                                        const SizedBox(
                                                                          height:
                                                                              Dimensions.textToTextSpace,
                                                                        ),
                                                                        CustomDropDownTextField(
                                                                          list: model.options ??
                                                                              [],
                                                                          onChanged:
                                                                              (value) {
                                                                            controller.changeSelectedValue(value,
                                                                                index);
                                                                          },
                                                                          selectedValue:
                                                                              model.selectedValue,
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : model.type ==
                                                                          'radio'
                                                                      ? Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            LabelTextInstruction(
                                                                              text: model.name ?? '',
                                                                              isRequired: model.isRequired == 'optional' ? false : true,
                                                                              instructions: model.instruction,
                                                                            ),
                                                                            CustomRadioButton(
                                                                              title: model.name,
                                                                              selectedIndex: controller.formList[index].options?.indexOf(model.selectedValue ?? '') ?? 0,
                                                                              list: model.options ?? [],
                                                                              onChanged: (selectedIndex) {
                                                                                controller.changeSelectedRadioBtnValue(index, selectedIndex);
                                                                              },
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : model.type ==
                                                                              'checkbox'
                                                                          ? Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                LabelTextInstruction(
                                                                                  text: model.name ?? '',
                                                                                  isRequired: model.isRequired == 'optional' ? false : true,
                                                                                  instructions: model.instruction,
                                                                                ),
                                                                                CustomCheckBox(
                                                                                  selectedValue: controller.formList[index].cbSelected,
                                                                                  list: model.options ?? [],
                                                                                  onChanged: (value) {
                                                                                    controller.changeSelectedCheckBoxValue(index, value);
                                                                                  },
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : model.type == 'file'
                                                                              ? Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    LabelTextInstruction(
                                                                                      text: model.name ?? '',
                                                                                      isRequired: model.isRequired == 'optional' ? false : true,
                                                                                      instructions: model.instruction,
                                                                                    ),
                                                                                    Padding(
                                                                                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                                                                                        child: SizedBox(
                                                                                          child: InkWell(
                                                                                              onTap: () {
                                                                                                controller.pickFile(index);
                                                                                              },
                                                                                              child: ChooseFileItem(
                                                                                                fileName: model.selectedValue ?? MyStrings.chooseFile.tr,
                                                                                              )),
                                                                                        ))
                                                                                  ],
                                                                                )
                                                                              : model.type == 'datetime'
                                                                                  ? Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                                          child: CustomTextField(
                                                                                              isShowInstructionWidget: true,
                                                                                              instructions: model.instruction,
                                                                                              isRequired: model.isRequired == 'optional' ? false : true,
                                                                                              hintText: (model.name ?? '').toString().capitalizeFirst,
                                                                                              needOutlineBorder: true,
                                                                                              labelText: model.name ?? '',
                                                                                              controller: controller.formList[index].textEditingController,
                                                                                              // initialValue: controller.formList[index].selectedValue == "" ? (model.name ?? '').toString().capitalizeFirst : controller.formList[index].selectedValue,
                                                                                              textInputType: TextInputType.datetime,
                                                                                              readOnly: true,
                                                                                              validator: (value) {
                                                                                                if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                                                  return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                                                } else {
                                                                                                  return null;
                                                                                                }
                                                                                              },
                                                                                              onTap: () {
                                                                                                controller.changeSelectedDateTimeValue(index, context);
                                                                                              },
                                                                                              onChanged: (value) {
                                                                                                controller.changeSelectedValue(value, index);
                                                                                              }),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : model.type == 'date'
                                                                                      ? Column(
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                                              child: CustomTextField(
                                                                                                  isShowInstructionWidget: true,
                                                                                                  instructions: model.instruction,
                                                                                                  isRequired: model.isRequired == 'optional' ? false : true,
                                                                                                  hintText: (model.name ?? '').toString().capitalizeFirst,
                                                                                                  needOutlineBorder: true,
                                                                                                  labelText: model.name ?? '',
                                                                                                  controller: controller.formList[index].textEditingController,
                                                                                                  // initialValue: controller.formList[index].selectedValue == "" ? (model.name ?? '').toString().capitalizeFirst : controller.formList[index].selectedValue,
                                                                                                  textInputType: TextInputType.datetime,
                                                                                                  readOnly: true,
                                                                                                  validator: (value) {
                                                                                                    print(model.isRequired);
                                                                                                    if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                                                      return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                                                    } else {
                                                                                                      return null;
                                                                                                    }
                                                                                                  },
                                                                                                  onTap: () {
                                                                                                    controller.changeSelectedDateOnlyValue(index, context);
                                                                                                  },
                                                                                                  onChanged: (value) {
                                                                                                    print(value);
                                                                                                    controller.changeSelectedValue(value, index);
                                                                                                  }),
                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                                      : model.type == 'time'
                                                                                          ? Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                Padding(
                                                                                                  padding: const EdgeInsets.symmetric(vertical: Dimensions.textToTextSpace),
                                                                                                  child: CustomTextField(
                                                                                                      isShowInstructionWidget: true,
                                                                                                      instructions: model.instruction,
                                                                                                      isRequired: model.isRequired == 'optional' ? false : true,
                                                                                                      hintText: (model.name ?? '').toString().capitalizeFirst,
                                                                                                      needOutlineBorder: true,
                                                                                                      labelText: model.name ?? '',
                                                                                                      controller: controller.formList[index].textEditingController,
                                                                                                      // initialValue: controller.formList[index].selectedValue == "" ? (model.name ?? '').toString().capitalizeFirst : controller.formList[index].selectedValue,
                                                                                                      textInputType: TextInputType.datetime,
                                                                                                      readOnly: true,
                                                                                                      validator: (value) {
                                                                                                        print(model.isRequired);
                                                                                                        if (model.isRequired != 'optional' && value.toString().isEmpty) {
                                                                                                          return '${model.name.toString().capitalizeFirst} ${MyStrings.isRequired}';
                                                                                                        } else {
                                                                                                          return null;
                                                                                                        }
                                                                                                      },
                                                                                                      onTap: () {
                                                                                                        controller.changeSelectedTimeOnlyValue(index, context);
                                                                                                      },
                                                                                                      onChanged: (value) {
                                                                                                        print(value);
                                                                                                        controller.changeSelectedValue(value, index);
                                                                                                      }),
                                                                                                ),
                                                                                              ],
                                                                                            )
                                                                                          : const SizedBox(),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }),
                                          const SizedBox(
                                            height: 30,
                                          ),
                                          Center(
                                            child: controller.submitLoading
                                                ? const RoundedLoadingBtn()
                                                : RoundedButton(
                                                    press: () {
                                                      if (formKey.currentState!
                                                          .validate()) {
                                                        controller
                                                            .submitKycData();
                                                      }
                                                    },
                                                    text: MyStrings.submit.tr,
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )),
      ),
    );
  }
}
