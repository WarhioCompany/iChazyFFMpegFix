import 'package:barcode/barcode.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:ichazy/domain/model/award.dart';

import 'colors/colors.dart';

class ShowQrScreen extends StatelessWidget {
  final String qrText;
  final AwardShowType barcodeType;
  ShowQrScreen(this.qrText, this.barcodeType);

  @override
  Widget build(BuildContext context) {
    print(barcodeType);
    return SafeArea(
      top: true,
      child: Scaffold(
        body: Stack(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.cancel_sharp,
                    color: AppColor.DARK_BLUE2,
                    size: 42,
                  ),
                ),
              ),
            ),
            if (barcodeType == AwardShowType.EAN13)
              Center(
                child: BarcodeWidget(
                  barcode: Barcode.ean13(drawEndChar: true),
                  data: qrText,
                  width: 400,
                  height: 160,
                ),
              ),
            if (barcodeType == AwardShowType.QR_CODE)
              Center(
                child: BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: qrText,
                  width: 300,
                  height: 300,
                ),
              ),
            if (barcodeType == AwardShowType.STRING)
              Center(
                child: Text(
                  qrText,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
