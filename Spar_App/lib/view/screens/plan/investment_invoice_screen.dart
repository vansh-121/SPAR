import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hyip_lab/core/helper/date_converter.dart';
import 'package:hyip_lab/core/helper/string_format_helper.dart';
import 'package:hyip_lab/core/utils/dimensions.dart';
import 'package:hyip_lab/core/utils/my_color.dart';
import 'package:hyip_lab/core/utils/style.dart';
import 'package:hyip_lab/data/controller/plan_detail/plan_detail_controller.dart';
import 'package:hyip_lab/data/model/plan/plan_model.dart';
import 'package:hyip_lab/view/components/appbar/custom_appbar.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:flutter/services.dart';
import 'package:hyip_lab/view/components/show_custom_snackbar.dart';

class InvestmentInvoiceScreen extends StatelessWidget {
  const InvestmentInvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>;
    final InstallmentEntry installment = args['installment'];
    final Plans? plan = args['plan'];
    final String curSymbol = args['currencySymbol'] ?? '';
    final int? investId = args['investId'];

    final date = installment.dateIso.isEmpty
        ? DateTime.now()
        : DateTime.parse(installment.dateIso);
    final formattedDate =
        DateConverter.isoStringToLocalDateOnly(date.toIso8601String());
    final formattedTime =
        DateConverter.isoStringToLocalTimeOnly(date.toIso8601String());

    return Scaffold(
      backgroundColor: MyColor.getScreenBgColor(),
      appBar: CustomAppBar(
        title: 'Investment Invoice',
        isTitleCenter: true,
        isShowBackBtn: true,
        bgColor: MyColor.getAppbarBgColor(),
        actionsList: [
          IconButton(
            icon: Icon(Icons.download, color: MyColor.getPrimaryColor()),
            onPressed: () => _generateAndDownloadPDF(
              context,
              installment,
              plan,
              curSymbol,
              investId,
              formattedDate,
              formattedTime,
            ),
            tooltip: 'Download PDF',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimensions.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.space20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    MyColor.getPrimaryColor(),
                    MyColor.getPrimaryColor().withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(Dimensions.mediumRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INVESTMENT INVOICE',
                            style: interBoldDefault.copyWith(
                              color: MyColor.getButtonTextColor(),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: Dimensions.space5),
                          Text(
                            '${_ordinal(installment.index)} Installment',
                            style: interRegularDefault.copyWith(
                              color:
                                  MyColor.getButtonTextColor().withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.receipt_long,
                        color: MyColor.getButtonTextColor(),
                        size: 40,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.space25),

            // Invoice Number Section
            Container(
              padding: const EdgeInsets.all(Dimensions.space15),
              decoration: BoxDecoration(
                color: MyColor.getCardBg(),
                borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                border: Border.all(color: MyColor.getPrimaryColor(), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #',
                        style: interRegularSmall.copyWith(
                          color: MyColor.getTextColor1(),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space5),
                      Text(
                        installment.transactionId ??
                            'INV-${investId ?? ""}-${installment.index}',
                        style: interBoldDefault.copyWith(
                          color: MyColor.getPrimaryColor(),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Date',
                        style: interRegularSmall.copyWith(
                          color: MyColor.getTextColor1(),
                        ),
                      ),
                      const SizedBox(height: Dimensions.space5),
                      Text(
                        formattedDate,
                        style: interBoldDefault.copyWith(
                          color: MyColor.getTextColor(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.space20),

            // Investment Details Section
            _sectionCard(
              title: 'Investment Details',
              children: [
                _detailRow('Plan Name', plan?.name ?? '-'),
                _divider(),
                _detailRow('Installment Number',
                    '${_ordinal(installment.index)} Installment'),
                _divider(),
                _detailRow('Transaction ID', installment.transactionId ?? 'N/A',
                    isHighlighted: true),
                _divider(),
                _detailRow('Investment Date', formattedDate),
                _divider(),
                _detailRow('Investment Time', formattedTime),
                _divider(),
                _detailRow('Investment ID', '#${investId ?? "-"}'),
              ],
            ),

            const SizedBox(height: Dimensions.space20),

            // Amount Details Section
            _sectionCard(
              title: 'Amount Details',
              children: [
                _detailRow(
                  'Amount Invested',
                  '$curSymbol${Converter.twoDecimalPlaceFixedWithoutRounding(installment.amount.toString())}',
                  isHighlighted: true,
                ),
                _divider(),
                _detailRow(
                  'Running Total',
                  '$curSymbol${Converter.twoDecimalPlaceFixedWithoutRounding(installment.runningTotal.toString())}',
                ),
                _divider(),
                _detailRow(
                  'Source',
                  _getSourceDisplayText(installment.source ?? ''),
                  isHighlighted: true,
                  source: installment.source ?? '',
                ),
              ],
            ),

            const SizedBox(height: Dimensions.space20),

            // Plan Information Section
            if (plan != null)
              _sectionCard(
                title: 'Plan Information',
                children: [
                  _detailRow(
                      'Minimum Investment', '$curSymbol${plan.minimum ?? "-"}'),
                  _divider(),
                  _detailRow(
                      'Maximum Investment', '$curSymbol${plan.maximum ?? "-"}'),
                  _divider(),
                  _detailRow('Interest Rate', plan.return_ ?? '-'),
                  _divider(),
                  _detailRow('Interest Period', plan.interestDuration ?? '-'),
                  if (plan.totalReturn != null) ...[
                    _divider(),
                    _detailRow('Total Returns', plan.totalReturn ?? '-'),
                  ],
                ],
              ),

            if (plan != null) const SizedBox(height: Dimensions.space20),

            const SizedBox(height: Dimensions.space30),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Dimensions.space15),
              decoration: BoxDecoration(
                color: MyColor.getCardBg(),
                borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
                border: Border.all(
                  color: MyColor.getPrimaryColor().withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.verified,
                    color: MyColor.getPrimaryColor(),
                    size: 24,
                  ),
                  const SizedBox(height: Dimensions.space10),
                  Text(
                    'This is an official investment invoice',
                    textAlign: TextAlign.center,
                    style: interRegularSmall.copyWith(
                      color: MyColor.getTextColor1(),
                    ),
                  ),
                  const SizedBox(height: Dimensions.space5),
                  Text(
                    'Generated on ${DateConverter.isoStringToLocalDateOnly(DateTime.now().toIso8601String())}',
                    textAlign: TextAlign.center,
                    style: interRegularExtraSmall.copyWith(
                      color: MyColor.getTextColor1().withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getCardBg(),
        borderRadius: BorderRadius.circular(Dimensions.defaultRadius),
        border: Border.all(
          color: MyColor.getPrimaryColor().withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: interBoldDefault.copyWith(
              color: MyColor.getTextColor(),
            ),
          ),
          const SizedBox(height: Dimensions.space15),
          ...children,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool isHighlighted = false, Color? valueColor, String? source}) {
    // Determine color based on source if provided
    Color? finalColor = valueColor;
    if (source != null && valueColor == null) {
      switch (source) {
        case 'wire_transfer':
        case 'initial_investment':
          finalColor = MyColor.primaryColor;
          break;
        case 'manual_topup':
          finalColor = Colors.blue;
          break;
        case 'interest_gained':
        case 'auto_compound':
          finalColor = MyColor.green;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: interRegularDefault.copyWith(
                color: MyColor.getTextColor1(),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.space10),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: (isHighlighted ? interBoldDefault : interRegularDefault)
                  .copyWith(
                color: finalColor ??
                    (isHighlighted
                        ? MyColor.getPrimaryColor()
                        : MyColor.getTextColor()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSourceDisplayText(String source) {
    switch (source) {
      case 'wire_transfer':
      case 'initial_investment':
        return 'Wire Transfer';
      case 'manual_topup':
        return 'Manual Top-up';
      case 'interest_gained':
      case 'auto_compound':
        return 'Interest Gained';
      default:
        return source.isNotEmpty ? source : 'Unknown';
    }
  }

  Widget _divider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.space10),
      child: Divider(
        color: MyColor.getBorderColor().withOpacity(0.3),
        height: 1,
      ),
    );
  }

  String _ordinal(int number) {
    if (number % 100 >= 11 && number % 100 <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  Future<void> _generateAndDownloadPDF(
    BuildContext context,
    InstallmentEntry installment,
    Plans? plan,
    String curSymbol,
    int? investId,
    String formattedDate,
    String formattedTime,
  ) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => SafeArea(
          child: const Center(child: CircularProgressIndicator()),
        ),
      );

      // Create PDF document
      final pdf = pw.Document();
      final invoiceNumber = installment.transactionId ??
          'INV-${investId ?? ""}-${installment.index}';
      final now = DateTime.now();
      final generatedDate =
          DateConverter.isoStringToLocalDateOnly(now.toIso8601String());

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVESTMENT INVOICE',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        '${_ordinal(installment.index)} Installment',
                        style: pw.TextStyle(
                            fontSize: 14, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Invoice #: $invoiceNumber',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Date: $generatedDate',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),

              // Investment Details Section
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Investment Details',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    _buildPdfRow('Plan Name', plan?.name ?? '-'),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Installment Number',
                        '${_ordinal(installment.index)} Installment'),
                    pw.SizedBox(height: 8),
                    _buildPdfRow(
                        'Transaction ID', installment.transactionId ?? 'N/A',
                        isBold: true),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Investment Date', formattedDate),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Investment Time', formattedTime),
                    pw.SizedBox(height: 8),
                    _buildPdfRow('Investment ID', '#${investId ?? "-"}'),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Amount Details Section
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Amount Details',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 15),
                    _buildPdfRow(
                      'Amount Invested',
                      '$curSymbol${Converter.twoDecimalPlaceFixedWithoutRounding(installment.amount.toString())}',
                      isBold: true,
                    ),
                    pw.SizedBox(height: 8),
                    _buildPdfRow(
                      'Running Total',
                      '$curSymbol${Converter.twoDecimalPlaceFixedWithoutRounding(installment.runningTotal.toString())}',
                    ),
                    pw.SizedBox(height: 8),
                    _buildPdfRow(
                      'Source',
                      _getSourceDisplayText(installment.source ?? ''),
                      isBold: true,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),

              // Plan Information (if available)
              if (plan != null) ...[
                pw.SizedBox(height: 20),
                pw.Container(
                  padding: const pw.EdgeInsets.all(15),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey300),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Plan Information',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 15),
                      _buildPdfRow('Minimum Investment',
                          '$curSymbol${plan.minimum ?? "-"}'),
                      pw.SizedBox(height: 8),
                      _buildPdfRow('Maximum Investment',
                          '$curSymbol${plan.maximum ?? "-"}'),
                      pw.SizedBox(height: 8),
                      _buildPdfRow('Interest Rate', plan.return_ ?? '-'),
                      pw.SizedBox(height: 8),
                      _buildPdfRow(
                          'Interest Period', plan.interestDuration ?? '-'),
                      if (plan.totalReturn != null) ...[
                        pw.SizedBox(height: 8),
                        _buildPdfRow('Total Returns', plan.totalReturn ?? '-'),
                      ],
                    ],
                  ),
                ),
              ],

              pw.SizedBox(height: 30),

              // Footer
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        'This is an official investment invoice',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontStyle: pw.FontStyle.italic,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'Generated on $generatedDate',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
        ),
      );

      // Save PDF to file
      final directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getApplicationDocumentsDirectory();

      if (directory == null) {
        Navigator.pop(context); // Close loading
        CustomSnackBar.error(errorList: ['Failed to access storage directory']);
        return;
      }

      final fileName =
          'Invoice_${invoiceNumber.replaceAll(' ', '_')}_$generatedDate.pdf';
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      Navigator.pop(context); // Close loading

      // Open file
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        // If couldn't open, try to share
        await Printing.sharePdf(
          bytes: await pdf.save(),
          filename: fileName,
        );
      }

      CustomSnackBar.success(
        successList: ['Invoice downloaded successfully: $fileName'],
      );
    } catch (e) {
      Navigator.pop(context); // Close loading if still open
      CustomSnackBar.error(
          errorList: ['Failed to generate PDF: ${e.toString()}']);
      print('PDF Generation Error: $e');
    }
  }

  pw.Widget _buildPdfRow(String label, String value,
      {bool isBold = false, bool isHighlighted = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey700,
            ),
          ),
        ),
        pw.SizedBox(width: 20),
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              fontSize: isHighlighted ? 14 : 12,
              fontWeight: (isBold || isHighlighted)
                  ? pw.FontWeight.bold
                  : pw.FontWeight.normal,
              color: isHighlighted ? PdfColors.blue900 : PdfColors.black,
            ),
          ),
        ),
      ],
    );
  }
}
