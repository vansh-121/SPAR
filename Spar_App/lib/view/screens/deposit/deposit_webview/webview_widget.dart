import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/routes/route.dart';
import 'package:hyip_lab/core/utils/my_strings.dart';
import 'package:hyip_lab/core/utils/url.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class MyWebViewWidget extends StatefulWidget {
  const MyWebViewWidget({super.key, required this.url});

  final String url;

  @override
  State<MyWebViewWidget> createState() => _MyWebViewWidgetState();
}

class _MyWebViewWidgetState extends State<MyWebViewWidget> {
  @override
  void initState() {
    url = widget.url;
    super.initState();
  }

  String url = '';
  final GlobalKey webViewKey = GlobalKey();

  InAppWebViewController? webViewController;
  InAppWebViewSettings options = InAppWebViewSettings(
    allowFileAccess: true,
    allowsInlineMediaPlayback: true,
    useHybridComposition: true,
    useShouldOverrideUrlLoading: true,
    mediaPlaybackRequiresUserGesture: false,
  );

  bool isKycPending = false;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      InAppWebViewController.setWebContentsDebuggingEnabled(true);
    }
    return Stack(
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : const SizedBox(),
        InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(url: WebUri(url)),
          initialSettings: options,
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStart: (controller, url) {
            if (url.toString() ==
                "${UrlContainer.domainUrl}/user/deposit/history") {
              Get.offAndToNamed(RouteHelper.depositScreen);
              CustomSnackBar.success(
                  successList: [MyStrings.paymentCaptureMsg]);
            } else if (url.toString() ==
                "${UrlContainer.domainUrl}/user/deposit/history") {}
            setState(() {
              this.url = url.toString();
            });
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;

            if (![
              "http",
              "https",
              "file",
              "chrome",
              "data",
              "javascript",
              "about"
            ].contains(uri.scheme)) {
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(
                  Uri.parse(url),
                );
                return NavigationActionPolicy.CANCEL;
              }
            }

            return NavigationActionPolicy.ALLOW;
          },
          onLoadStop: (controller, url) async {
            setState(() {
              isLoading = false;
              this.url = url.toString();
            });
          },
          onReceivedError: (controller, resourceRequest, resourceError) {
            CustomSnackBar.error(errorList: [
              'Error loading page: ${resourceError.description}'
            ]);
          },
          onUpdateVisitedHistory: (controller, url, androidIsReload) {
            setState(() {
              this.url = url.toString();
            });
          },
          onProgressChanged: (controller, progress) {},
          onConsoleMessage: (controller, consoleMessage) {},
        )
      ],
    );
  }
}
