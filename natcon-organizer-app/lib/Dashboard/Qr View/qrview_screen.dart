import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:magicmate_organizer/Getx_controller.dart/eventdetails_controller.dart';
import 'package:magicmate_organizer/Model%20class/ticket_info.dart';
import 'package:magicmate_organizer/api_screens/Api_werper.dart';
import 'package:magicmate_organizer/api_screens/data_store.dart';
import 'package:magicmate_organizer/utils/Colors.dart';
import 'package:magicmate_organizer/utils/Custom_widget.dart';
import 'package:magicmate_organizer/utils/Fontfamily.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/dark_light_mode.dart';

class QrViewScreen extends StatefulWidget {
  const QrViewScreen({super.key});

  @override
  State<QrViewScreen> createState() => _QrViewScreenState();
}

class _QrViewScreenState extends State<QrViewScreen> {
  EventDetailsController eventDetailsController = Get.put(EventDetailsController());
  TextEditingController bookingId = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Barcode? result;
  TicketInfo? ticketInfo;
  MobileScannerController scannerController = MobileScannerController();

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  int currentIndex = 0;

  @override
  void initState() {
    getDarkMode();
    super.initState();
  }
  late ColorNotifier notifier;
  getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previousState = prefs.getBool("setIsDark");
    if (previousState == null) {
      notifier.setIsDark = false;
    } else {
      notifier.setIsDark = previousState;
    }
  }

  @override
  Widget build(BuildContext context) {
    notifier = Provider.of<ColorNotifier>(context, listen: true);
    Future.delayed(
      Duration(seconds: 1),
          () {
        if (getData.read("openCamera") == true) {
          print("::::::::::--------");
          save("openCamera", false);
        }
      },
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: scannerController,
              scanWindow: Rect.fromCenter(
                center: MediaQuery.of(context).size.center(Offset.zero),
                width: 250,
                height: 250,
              ),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  String scannedText = barcodes.first.rawValue ?? "";
                  debugPrint("Scanned Data: $scannedText");

                  scannerController.stop();

                  if (scannedText.startsWith("{") && scannedText.endsWith("}")) {
                    try {
                      var res1 = jsonDecode(scannedText);
                      debugPrint("Parsed JSON: $res1");
                      ticketInfo = TicketInfo.fromJson(res1);
                      eventDetailsController.qrCheckApi(
                        context: context,
                        eventId: ticketInfo?.eventId,
                        oragId: ticketInfo?.orgnizerId,
                        ticketId: ticketInfo?.ticketId,
                        uId: ticketInfo?.uid,
                      );
                      print("..............." + ticketInfo!.ticketId.toString());
                    } catch (e) {
                      debugPrint("JSON Decode Error: $e");
                    }
                  } else {
                    debugPrint("Non-JSON scanned data: $scannedText");
                  }
                }
              },
            ),

            // 2. Dark overlay with cutout box
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  // Full screen background
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  // Cut-out area (transparent box)
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. Optional white border around scanner box
            Align(
              alignment: Alignment.center,
              child: CornerBorderBox(
                size: 250,
                cornerSize: 30,
                strokeWidth: 4,
                borderColor: Colors.redAccent,
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                height: 45,
                width: 45,
                alignment: Alignment.center,
                child: BackButton(
                  onPressed: () {
                    Get.back();
                  },
                  color: notifier.background,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            Positioned(
              bottom: 50,
              left: 10,
              right: 10,
              child: Container(
                height: 50,
                width: Get.size.width,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            currentIndex = 0;
                          });
                        },
                        child: Container(
                          height: 45,
                          margin: EdgeInsets.only(top: 4, bottom: 4, left: 4),
                          alignment: Alignment.center,
                          child: Text(
                            "Scan Code".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              color: BlackColor,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: currentIndex == 0 ? WhiteColor : transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            currentIndex = 1;
                            Get.defaultDialog(
                              backgroundColor: WhiteColor.withOpacity(0.5),
                              onWillPop: () async {
                                setState(() {
                                  currentIndex = 0;
                                });
                                return Future.value(true);
                              },
                              contentPadding: EdgeInsets.only(
                                  left: 15, right: 15, bottom: 0),
                              title: "Enter booking ID".tr,
                              titleStyle: TextStyle(
                                fontFamily: FontFamily.gilroyBold,
                                letterSpacing: 2,
                              ),
                              content: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    Text(
                                      "Enter the booking number from your \n booked e-ticket or scan the OR code",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: FontFamily.gilroyMedium,
                                        fontSize: 12,
                                        height: 1.2,
                                      ),
                                    ),
                                    textfield1(
                                      controller: bookingId,
                                      labelText: "Enter Booking ID".tr,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please Enter Booking ID'.tr;
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          Get.back();
                                          eventDetailsController.bookingIdVerifyApi(bookingID: bookingId.text);
                                        }
                                      },
                                      child: Container(
                                        height: 45,
                                        width: Get.size.width,
                                        alignment: Alignment.center,
                                        margin: EdgeInsets.only(
                                            left: 8, right: 8, top: 8),
                                        child: Text(
                                          "Verify".tr,
                                          style: TextStyle(
                                            fontFamily: FontFamily.gilroyBold,
                                            color: WhiteColor,
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: appcolor,
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                        child: Container(
                          height: 45,
                          margin: EdgeInsets.only(top: 4, bottom: 4, right: 4),
                          alignment: Alignment.center,
                          child: Text(
                            "Enter Code".tr,
                            style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              color: BlackColor,
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: currentIndex == 1 ? WhiteColor : transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

}

class CornerBorderBox extends StatelessWidget {
  final double size;
  final double cornerSize;
  final double strokeWidth;
  final double radius;
  final Color borderColor;

  const CornerBorderBox({
    super.key,
    this.size = 250,
    this.cornerSize = 30,
    this.strokeWidth = 4,
    this.borderColor = Colors.white,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerBorderPainter(
          cornerSize: cornerSize,
          strokeWidth: strokeWidth,
          radius: radius,
          borderColor: borderColor,
        ),
      ),
    );
  }
}

class _CornerBorderPainter extends CustomPainter {
  final double cornerSize;
  final double strokeWidth;
  final double radius;
  final Color borderColor;

  _CornerBorderPainter({
    required this.cornerSize,
    required this.strokeWidth,
    required this.radius,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Size.fromRadius(radius);
    // Top-left corner
    canvas.drawLine(Offset(0, 0), Offset(cornerSize, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(0, cornerSize), paint);

    // Top-right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerSize, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerSize), paint);

    // Bottom-left corner
    canvas.drawLine(Offset(0, size.height), Offset(cornerSize, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerSize), paint);

    // Bottom-right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerSize, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerSize), paint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
