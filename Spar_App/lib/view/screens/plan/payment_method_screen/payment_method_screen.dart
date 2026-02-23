import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/plan_payment_method_screen/payment_method_controller.dart';
import 'package:hyip_lab/data/repo/deposit_repo.dart';
import 'package:hyip_lab/data/services/api_service.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:hyip_lab/view/components/buttons/rounded_loading_button.dart';
import 'package:hyip_lab/view/components/custom_loader/custom_loader.dart';
import 'package:hyip_lab/view/components/rounded_button.dart';
import 'package:hyip_lab/view/components/text-field/custom_amount_text_field.dart';
import 'package:hyip_lab/view/components/text/label_text.dart';
import '../../../../data/model/plan/plan_model.dart';
import 'widget/payment_method_info.dart';

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  @override
  void dispose() {
    Get.find<PaymentMethodController>().clearData();
    super.dispose();
  }

  @override
  void initState() {
    dynamic args = Get.arguments;
    Plans p;
    int? topupInvestId;
    bool isTopup = false;
    if (args is List && args.isNotEmpty) {
      p = args[0] as Plans;
      if (args.length > 1) {
        topupInvestId = args[1] as int?;
      }
      if (args.length > 2) {
        isTopup = (args[2] == true);
      }
    } else {
      p = args as Plans;
    }

    Get.put(ApiClient(sharedPreferences: Get.find()));
    Get.put(DepositRepo(apiClient: Get.find()));
    final controller = Get.put(PaymentMethodController(repo: Get.find()));

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadData(p);
      if (isTopup) {
        controller.setTopupMode(isTopup: true, investId: topupInvestId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentMethodController>(
        builder: (controller) => Scaffold(
              backgroundColor: MyColor.getScreenBgColor(),
              appBar: CustomAppBar(
                title:
                    "${MyStrings.confirmToInvestOn.tr} ${controller.plan.name.toString().tr}",
                isTitleCenter: true,
                isShowBackBtn: true,
                bgColor: MyColor.getAppbarBgColor(),
              ),
              body: controller.isLoading
                  ? const CustomLoader()
                  : SingleChildScrollView(
                      child: Padding(
                        padding: Dimensions.screenPaddingHV,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: Dimensions.space30,
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text("${MyStrings.invest.tr} : ",
                                        style: interBoldDefault.copyWith(
                                            color: MyColor.getTextColor())),
                                    Text(
                                      controller.isFixed
                                          ? controller.curSymbol +
                                              Converter
                                                  .twoDecimalPlaceFixedWithoutRounding(
                                                      controller.plan
                                                              .fixedAmount ??
                                                          " ")
                                          : "${controller.curSymbol + Converter.twoDecimalPlaceFixedWithoutRounding(controller.plan.minimum ?? " ")} - "
                                              "${controller.curSymbol + Converter.twoDecimalPlaceFixedWithoutRounding(controller.plan.maximum ?? " ")}",
                                      style: interBoldDefault.copyWith(
                                          color: MyColor.getTextColor()),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: Dimensions.space5,
                                ),
                                Text(
                                  "${MyStrings.interest.tr} : ${controller.interestAmount}",
                                  style: interBoldDefault.copyWith(
                                      color: MyColor.getTextColor()),
                                ),
                                const SizedBox(
                                  height: Dimensions.space5,
                                ),
                                Text(
                                  "${controller.getFormattedInterestValidity()}",
                                  style: interBoldDefault.copyWith(
                                      color: MyColor.getTextColor()),
                                ),
                                const SizedBox(
                                  height: Dimensions.space5,
                                ),
                                Text(
                                  "${controller.plan.totalReturn}",
                                  style: interBoldDefault.copyWith(
                                      color: MyColor.getTextColor()),
                                ),
                                const SizedBox(
                                  height: Dimensions.space10,
                                ),
                              ],
                            ),
                            const SizedBox(height: 25),
                            LabelText(
                                text: MyStrings.payVia.tr, required: true),
                            const SizedBox(height: 8),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: Dimensions.space15,
                                  vertical: Dimensions.space12),
                              decoration: BoxDecoration(
                                color: MyColor.transparentColor,
                                borderRadius: BorderRadius.circular(
                                    Dimensions.defaultRadius),
                                border: Border.all(
                                    color: controller.paymentMethod == null
                                        ? MyColor.getFieldDisableBorderColor()
                                        : MyColor.getPrimaryColor(),
                                    width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.account_balance_wallet,
                                      color: MyColor.primaryColor, size: 20),
                                  const SizedBox(width: Dimensions.space10),
                                  Expanded(
                                    child: Text(
                                      Converter.replaceUnderscoreWithSpace(
                                              controller.paymentMethod?.name
                                                      ?.toString() ??
                                                  'Payment Gateway')
                                          .tr,
                                      overflow: TextOverflow.ellipsis,
                                      style: interRegularDefault.copyWith(
                                          color: MyColor.getTextColor(),
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            CustomAmountTextField(
                              labelText: MyStrings.investAmount.tr,
                              currency: controller.currency,
                              hintText: '0.0',
                              readOnly: controller.isFixed,
                              inputAction: TextInputAction.done,
                              controller: controller.amountController,
                              onChanged: (value) {
                                if (value.toString().isEmpty) {
                                  controller.changeInfoWidgetValue(0);
                                } else {
                                  double amount =
                                      double.tryParse(value.toString()) ?? 0;
                                  controller.changeInfoWidgetValue(amount);
                                }
                                return;
                              },
                            ),
                            // Show SIP frequency fields when SIP is enabled (regardless of compound interest)
                            Visibility(
                                visible: controller.isScheduleInvestOn == "1" &&
                                        !controller.isTopup
                                    ? true
                                    : false,
                                child: Column(
                                  children: [
                                    LabelText(
                                        text: 'SIP Frequency', required: true),
                                    const SizedBox(height: 8),
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: Dimensions.space10,
                                          vertical: 0),
                                      decoration: BoxDecoration(
                                          color: MyColor.transparentColor,
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.defaultRadius),
                                          border: Border.all(
                                              color: MyColor.getPrimaryColor(),
                                              width: 0.5)),
                                      child: DropdownButton<String>(
                                        hint: Text('Select SIP Frequency'),
                                        value: controller.sipFrequency,
                                        elevation: 8,
                                        icon: Icon(Icons.keyboard_arrow_down,
                                            color: MyColor.getTextColor()),
                                        iconEnabledColor: MyColor.primaryColor,
                                        dropdownColor: MyColor.getCardBg(),
                                        isExpanded: true,
                                        underline: Container(height: 0),
                                        onChanged: (String? newValue) {
                                          if (newValue != null) {
                                            controller
                                                .setSipFrequency(newValue);
                                          }
                                        },
                                        items: [
                                          'Hourly',
                                          'Weekly',
                                          'Monthly',
                                          'Quarterly'
                                        ].map((String frequency) {
                                          return DropdownMenuItem<String>(
                                            value: frequency,
                                            child: Text(frequency,
                                                style: interRegularDefault
                                                    .copyWith(
                                                        color: MyColor
                                                            .getTextColor())),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(height: Dimensions.space10),
                                    CustomAmountTextField(
                                      labelText: 'Investment Period (months)',
                                      hintText: 'Enter total months',
                                      controller:
                                          controller.investmentPeriodController,
                                      currency: 'Months',
                                      enforceHundredMultiples: false,
                                      onChanged: controller.setInvestmentPeriod,
                                    ),
                                    const SizedBox(height: 20),
                                  ],
                                )),
                            controller.isShowPreview()
                                ? const InfoWidget()
                                : const SizedBox(),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
              bottomNavigationBar: controller.isLoading
                  ? null
                  : SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(Dimensions.space15),
                        child: controller.submitLoading
                            ? const RoundedLoadingBtn()
                            : RoundedButton(
                                press: () {
                                  controller.submitDeposit();
                                },
                                text: MyStrings.submit.tr,
                              ),
                      ),
                    ),
            ));
  }
}
