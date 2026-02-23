import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/core/utils/util.dart';
import 'package:hyip_lab/data/controller/account/profile_complete_controller.dart';

import '../../../../../core/utils/url.dart';
import '../../../../../data/controller/account/profile_complete_controller.dart';
import '../../../../../data/model/country_model/country_model.dart';
import '../../../../components/bottom-sheet/bottom_sheet_bar.dart';
import '../../../../components/bottom-sheet/custom_bottom_sheet_plus.dart';
import '../../../../components/card/bottom_sheet_card.dart';
import '../../../../components/image/my_image_widget.dart';
import '../../../../components/text-field/label_text_field.dart';

class CountryBottomSheet {
  static void profileCompleteCountryBottomSheet(
      BuildContext context, ProfileCompleteController controller) {
    CustomBottomSheetPlus(
        isNeedPadding: false,
        child: StatefulBuilder(builder: (context, setState) {
          if (controller.filteredCountries.isEmpty) {
            controller.filteredCountries = controller.countryList;
          }
          // Function to filter countries based on the search input.
          void filterCountries(String query) {
            if (query.isEmpty) {
              controller.filteredCountries = controller.countryList;
            } else {
              List<Countries> filterData = controller.filteredCountries
                  .where((country) => country.country!
                      .toLowerCase()
                      .contains(query.toLowerCase()))
                  .toList();
              setState(() {
                controller.filteredCountries = filterData;
              });
            }
          }

          return Container(
            height: MediaQuery.of(context).size.height * .9,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            decoration: BoxDecoration(
              color: MyColor.getScreenBgColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: MyUtils.getShadow(),
            ),
            child: Column(
              children: [
                const BottomSheetBar(),
                const SizedBox(height: 10),
                LabelTextField(
                  labelText: '',
                  hintText: MyStrings.searchCountry.tr,
                  controller: controller.countryController,
                  textInputType: TextInputType.text,
                  onChanged: filterCountries,
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  labelTextStyle: interBoldDefault.copyWith(),
                  fillColor: MyColor.colorGrey.withOpacity(0.01),
                ),
                const SizedBox(height: 15),
                Flexible(
                  child: ListView.builder(
                      itemCount: controller.filteredCountries.length,
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        var countryItem = controller.filteredCountries[index];

                        return GestureDetector(
                          onTap: () {
                            controller.countryController.text =
                                controller.filteredCountries[index].country ??
                                    '';
                            controller.setCountryNameAndCode(
                                controller.filteredCountries[index].country ??
                                    '',
                                controller
                                        .filteredCountries[index].countryCode ??
                                    '',
                                controller.filteredCountries[index].dialCode ??
                                    '');

                            Navigator.pop(context);

                            FocusScopeNode currentFocus =
                                FocusScope.of(context);
                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          child: BottomSheetCard(
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.only(
                                      end: Dimensions.space10),
                                  child: MyImageWidget(
                                    imageUrl: UrlContainer.countryFlagImageLink
                                        .replaceAll(
                                            "{countryCode}",
                                            countryItem.countryCode
                                                .toString()
                                                .toLowerCase()),
                                    height: Dimensions.space25,
                                    width: Dimensions.space40 + 2,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    '+${controller.filteredCountries[index].dialCode}  ${controller.filteredCountries[index].country?.tr ?? ''}',
                                    style: interRegularDefault.copyWith(
                                        color: MyColor.getTextColor()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                )
              ],
            ),
          );
        })).show(context);
  }
}
