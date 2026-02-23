import 'package:flutter/material.dart';
import 'package:hyip_lab/core/utils/my_color.dart';

class CustomLoader extends StatelessWidget {

  const CustomLoader({Key? key,this.indicatorColor = MyColor.primaryColor,this.isPagination = false,this.isFullScreen = false}) : super(key: key);

  final bool isFullScreen;
  final bool isPagination;
  final Color indicatorColor;

  @override
  Widget build(BuildContext context) {
    return isFullScreen?Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      child: Center(
        child: CircularProgressIndicator(
          color: indicatorColor,
        ),
      ),
    ): isPagination?
    Center(
      child:  Padding(
        padding: const EdgeInsets.all(10),
        child: CircularProgressIndicator(
          color: indicatorColor,
        ),
      ),
    ):
    Center(
      child: CircularProgressIndicator(
        color: indicatorColor,
      ),
    );
  }
}
