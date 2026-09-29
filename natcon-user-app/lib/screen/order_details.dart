// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_typing_uninitialized_variables, unnecessary_brace_in_string_interps, prefer_interpolation_to_compose_strings, avoid_print, unused_element

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:magicmate_user/screen/paypal/flutter_paypal.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../Api/config.dart';
import '../Api/data_store.dart';
import '../controller/bookevent_controller.dart';
import '../controller/coupon_controller.dart';
import '../controller/eventdetails_controller.dart';
import '../controller/home_controller.dart';
import '../controller/paystack_controller.dart';
import '../controller/wallet_controller.dart';
import '../helpar/routes_helpar.dart';
import '../model/fontfamily_model.dart';
import '../utils/Colors.dart';
import '../utils/Custom_widget.dart';
import 'LoginAndSignup/login_screen.dart';
import 'PaymentGateway/FlutterWave.dart';
import 'PaymentGateway/InputFormater.dart';
import 'PaymentGateway/PaymentCard.dart';
import 'PaymentGateway/StripeWeb.dart';
import 'PaymentGateway/checkout.dart';
import 'PaymentGateway/khali.dart';
import 'PaymentGateway/mecardopago.dart';
import 'PaymentGateway/midtrans.dart';
import 'PaymentGateway/payfast.dart';
import 'PaymentGateway/paystack.dart';
import 'PaymentGateway/paytm_payment.dart';
import 'home_screen.dart';
import 'natcon_delegate_details.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

var total;

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  EventDetailsController eventDetailsController = Get.find();
  BookEventController bookEventController = Get.find();
  CouponController couponController = Get.find();
  HomePageController homePageController = Get.find();
  WalletController walletController = Get.find();
  String couponCode = "";
  bool status = false;
  var subtotal = Get.arguments["total"];

  late Razorpay _razorpay;

  int? _groupValue;
  String? selectidPay = "0";
  String razorpaykey = "";
  String? paymenttital;

  var useWallet = 0.0;
  String wallet = "";
  var tempWallet = 0.0;
  dynamic tex = 0.00;

  String mTotal = "";

  @override
  void initState() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    total = 0.0;
    walletController.getpaymentgatewayList();
    super.initState();
    setState(() {
      tex = double.parse(
          "${(subtotal * double.parse(homePageController.homeInfo?.homeData.mainData.tax ?? "") / 100)}");

      total = subtotal + tex;
      mTotal = total.toString();
      wallet = wallet1.toString();
      tempWallet = double.parse(wallet1.toString());
      if(tempWallet==0.0){
        tempWallet=0;
      }
    });
  }
  PayStackController payStackController = Get.put(PayStackController());
  String? accessToken;
  String? payerID;
  bool isCheckoutLoading = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgcolor,
      appBar: AppBar(
        backgroundColor: WhiteColor,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(
          onPressed: () {
            Get.back();
          },
          color: BlackColor,
        ),
        title: Text(
          "Order Details".tr,
          style: TextStyle(
            fontFamily: FontFamily.gilroyBold,
            fontSize: 14,
            color: BlackColor,
          ),
        ),
      ),
      bottomNavigationBar: GestButton(
        height: 50,
        Width: Get.size.width,
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        buttoncolor: gradient.defoultColor,
        buttontext:
            getData.read("UserLogin") != null ? "Confirm".tr : "Login".tr,
        style: TextStyle(
          color: WhiteColor,
          fontFamily: FontFamily.gilroyBold,
          fontSize: 15,
        ),
        onclick: () {
          if (getData.read("UserLogin") != null) {
            if (!isCheckoutLoading) startNatconCheckout();
          } else {
            Get.to(LoginScreen());
          }
        },
      ),
      body: SizedBox(
        height: Get.size.height,
        width: Get.size.width,
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              GetBuilder<EventDetailsController>(builder: (context) {
                return Container(
                  height: 120,
                  width: Get.size.width,
                  margin: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Container(
                        height: 120,
                        width: 100,
                        margin: EdgeInsets.all(8),
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: FadeInImage.assetNetwork(
                            placeholder: "assets/ezgif.com-crop.gif",
                            image:
                                "${Config.imageUrl}${eventDetailsController.eventInfo?.eventData.eventImg ?? ""}",
                            height: 120,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    eventDetailsController
                                            .eventInfo?.eventData.eventTitle ??
                                        "",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyBold,
                                      fontSize: 15,
                                      color: BlackColor,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 7,
                            ),
                            Text(
                              eventDetailsController
                                      .eventInfo?.eventData.eventSdate ??
                                  "",
                              maxLines: 1,
                              style: TextStyle(
                                fontFamily: FontFamily.gilroyMedium,
                                fontSize: 14,
                                color: greytext,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: [
                                Image.asset(
                                  "assets/Location.png",
                                  color: gradient.defoultColor,
                                  height: 15,
                                  width: 15,
                                ),
                                Flexible(flex: 1,
                                  child: Text(
                                    eventDetailsController.eventInfo?.eventData
                                            .eventAddressTitle ??
                                        "",
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily: FontFamily.gilroyMedium,
                                      fontSize: 15,
                                      color: gradient.defoultColor,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: WhiteColor,
                  ),
                );
              }),
              getData.read("UserLogin") != null
                  ? eventDetailsController.ticketPrice != "0"
                      ? Container(
                          height: 150,
                          width: Get.size.width,
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: InkWell(
                            onTap: () {},
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  height: 60,
                                  alignment: Alignment.center,
                                  child: InkWell(
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          "assets/badge-discount.png",
                                          height: 40,
                                          width: 40,
                                          color: gradient.defoultColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                onTap: () {},
                                                child: Text(
                                                  "Apply Coupon".tr,
                                                  style: TextStyle(
                                                    color:
                                                        gradient.defoultColor,
                                                    fontFamily:
                                                        FontFamily.gilroyBold,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 4,
                                              ),
                                              couponCode != ""
                                                  ? Row(
                                                      children: [
                                                        Text(
                                                          "Use code:".tr,
                                                          style: TextStyle(
                                                            fontFamily: FontFamily
                                                                .gilroyMedium,
                                                          ),
                                                        ),
                                                        Text(
                                                          couponCode,
                                                          style: TextStyle(
                                                            fontFamily:
                                                                FontFamily
                                                                    .gilroyBold,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                        ),
                                        couponCode != ""
                                            ? InkWell(
                                                onTap: () {
                                                  status = false;
                                                  walletCalculation(false);
                                                  setState(() {});
                                                  total = total +
                                                      bookEventController
                                                          .couponAmt;
                                                  bookEventController
                                                      .couponAmt = 0;
                                                  couponCode = "";
                                                  setState(() {});
                                                },
                                                child: Text(
                                                  "Remove".tr,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.gilroyBold,
                                                    color: RedColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  status = false;
                                                  walletCalculation(false);
                                                  setState(() {});
                                                  couponController
                                                      .getCouponDataApi(
                                                    sponsoreID:
                                                        eventDetailsController
                                                            .eventInfo
                                                            ?.eventData
                                                            .sponsoreId,
                                                  );
                                                  Get.toNamed(
                                                    Routes.couponScreen,
                                                    arguments: {
                                                      "price": subtotal
                                                    },
                                                  )?.then((value) {
                                                    setState(() {
                                                      couponCode = value;
                                                    });
                                                    couponSucsessFullyApplyed();
                                                  });
                                                },
                                                child: Text(
                                                  "Apply".tr,
                                                  style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.gilroyBold,
                                                    color:
                                                        gradient.defoultColor,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Divider(),
                                SizedBox(
                                  height: 10,
                                ),
                                InkWell(
                                  onTap: () {},
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "View all coupons".tr,
                                        style: TextStyle(
                                          color: greyColor,
                                          fontSize: 15,
                                          fontFamily: FontFamily.gilroyMedium,
                                        ),
                                      ),
                                      Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 15,
                                        color: greyColor,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            color: WhiteColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        )
                      : SizedBox()
                  : SizedBox(),
              getData.read("UserLogin") != null
                  ? eventDetailsController.ticketPrice != "0"
                      ? wallet != "0"
                          ? Container(
                              height: 140,
                              width: Get.size.width,
                              margin: EdgeInsets.all(10),
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Pay from wallet".tr,
                                        style: TextStyle(
                                          fontFamily: FontFamily.gilroyBold,
                                          fontSize: 17,
                                          color: BlackColor,
                                        ),
                                      ),

                                      SizedBox(
                                        width: 5,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                    height: 65,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Image.asset(
                                          "assets/wallet.png",
                                          height: 30,
                                          width: 30,
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "${"Your Balance".tr} $currency${tempWallet.toStringAsFixed(2)}",
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.gilroyBold,
                                                fontSize: 17,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              "Available for Payment".tr,
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.gilroyBold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),
                                        Transform.scale(
                                          scale: 0.8,
                                          child: CupertinoSwitch(
                                            activeColor: gradient.defoultColor,
                                            value: status,
                                            onChanged: (value) {
                                              setState(() {});
                                              status = value;
                                              walletCalculation(value);
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                  )
                                ],
                              ),
                              decoration: BoxDecoration(
                                color: WhiteColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            )
                          : SizedBox()
                      : SizedBox()
                  : SizedBox(),
              Container(
                width: Get.size.width,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      "Order Summary".tr,
                      style: TextStyle(
                        fontFamily: FontFamily.gilroyBold,
                        color: BlackColor,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'NATCON confirms the final price on the server before payment. The amount shown above is an estimate.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: [
                        Text(
                          "Price".tr,
                          style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 15,
                              color: greytext),
                        ),
                        Spacer(),
                        Text(
                          "$currency$subtotal",
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            fontSize: 15,
                            color: greytext,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Fee".tr,
                          style: TextStyle(
                              fontFamily: FontFamily.gilroyMedium,
                              fontSize: 15,
                              color: greytext),
                        ),
                        Spacer(),
                        Text(
                          "${currency}${tex}",
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyMedium,
                            fontSize: 15,
                            color: greytext,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    status
                        ? Row(
                            children: [
                              Text(
                                "Wallet".tr,
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyMedium,
                                  fontSize: 15,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "${useWallet.toStringAsFixed(2)}${currency}",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(
                      height: 10,
                    ),
                    couponCode != ""
                        ? Row(
                            children: [
                              Text(
                                "Coupon".tr,
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyMedium,
                                  fontSize: 15,
                                ),
                              ),
                              Spacer(),
                              Text(
                                "${currency}${bookEventController.couponAmt}",
                                style: TextStyle(
                                  fontFamily: FontFamily.gilroyBold,
                                  fontSize: 15,
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                            ],
                          )
                        : SizedBox(),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          "Total Payment".tr,
                          style: TextStyle(
                              fontFamily: FontFamily.gilroyBold,
                              fontSize: 15,
                              color: BlackColor),
                        ),
                        Spacer(),
                        Text(
                          "${currency}${double.parse(total.toString()).toStringAsFixed(2)}",
                          style: TextStyle(
                            fontFamily: FontFamily.gilroyBold,
                            fontSize: 15,
                            color: BlackColor,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
                decoration: BoxDecoration(
                  color: WhiteColor,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> startNatconCheckout() async {
    final account = getData.read('UserLogin');
    if (account is! Map<String, dynamic>) {
      showToastMessage('Sign in to continue with NATCON checkout.');
      return;
    }
    final selectedCount = int.tryParse(eventDetailsController.totalTicke) ??
        eventDetailsController.totalTicket;
    if (selectedCount < 1 || selectedCount > 50) {
      showToastMessage('Choose between 1 and 50 delegates.');
      return;
    }
    final delegates = await Get.to<List<Map<String, String>>>(
      () => NatconDelegateDetailsScreen(count: selectedCount, account: account),
    );
    if (delegates == null || !mounted) return;

    setState(() => isCheckoutLoading = true);
    try {
      final order = await bookEventController.createNatconOrder(
        account: Map<String, dynamic>.from(account),
        delegates: delegates,
      );
      final amountKobo = (order['amount_kobo'] as num?)?.toInt() ?? 0;
      final confirm = await Get.dialog<bool>(AlertDialog(
        title: const Text('Confirm NATCON total'),
        content: Text(
          '${currency} ${(amountKobo / 100).toStringAsFixed(2)} for ${delegates.length} delegate(s). This total is calculated by NATCON.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Get.back(result: true), child: const Text('Continue to Paystack')),
        ],
      ));
      if (confirm != true) return;

      final payment = await bookEventController.initializeNatconPayment(
        reference: order['reference'].toString(),
        token: order['access_token'].toString(),
      );
      final authorizationUrl = payment['authorization_url']?.toString() ?? '';
      if (authorizationUrl.isEmpty) {
        throw const FormatException('NATCON did not return a Paystack checkout link.');
      }
      final reference = order['reference'].toString();
      final orderToken = order['access_token'].toString();
      await Get.to(() => PayStackWeb(
        initialUrl: authorizationUrl,
        navigationDelegate: (request) async {
          final callback = Uri.tryParse(request.url);
          final baseHost = Uri.parse(Config.imageUrl).host;
          if (callback != null &&
              callback.host == baseHost &&
              callback.path.endsWith('/conference/')) {
            try {
              final verified = await bookEventController.verifyNatconPayment(
                reference: reference,
                token: orderToken,
              );
              if (verified['status'] == 'paid') {
                Get.back();
                await OrderPlacedSuccessfully();
              } else {
                showToastMessage('Payment is still being confirmed. Keep your NATCON reference and check your tickets again shortly.');
              }
            } catch (_) {
              showToastMessage('NATCON could not confirm payment yet. Your registration is saved; check again shortly.');
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ));
    } catch (error) {
      showToastMessage(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isCheckoutLoading = false);
    }
  }

  //! ------------- Wallet Clc ----------- !//
  walletCalculation(value) {
    if (value == true) {
      if (double.parse(wallet.toString()) < double.parse(total.toString())) {
        tempWallet =
            double.parse(total.toString()) - double.parse(wallet.toString());
        useWallet = double.parse(wallet.toString());
        total =
            (double.parse(total.toString()) - double.parse(wallet.toString()));
        tempWallet = 0;
        setState(() {});
      } else {
        tempWallet =
            double.parse(wallet.toString()) - double.parse(total.toString());
        useWallet = double.parse(wallet.toString()) - tempWallet;
        total = 0;
      }
    } else {
      tempWallet = 0;
      tempWallet = double.parse(wallet.toString());
      total = total + useWallet;
      useWallet = 0;
      setState(() {});
    }

  }

  //!-----------BookEventApi------------!//
  // String? eID,
  //   typeId,
  //   type,
  //   price,
  //   totalTicket,
  //   subTotal,
  //   tax,
  //   couAmt,
  //   totalAmt,
  //   wallAmt,
  //   pMethodId,
  //   otid,
  //   pLimit,
  //   sponsoreId,
  bookEvent(otid) {
    bookEventController.bookEventApi(
      eID: eventDetailsController.eventInfo?.eventData.eventId ?? "",
      typeId: eventDetailsController.ticketID,
      type: eventDetailsController.ticketType,
      price: eventDetailsController.ticketPrice,
      totalTicket: eventDetailsController.totalTicket.toString(),
      subTotal: subtotal.toString(),
      tax: tex.toString(),
      couAmt: bookEventController.couponAmt != 0.0
          ? bookEventController.couponAmt.toString()
          : "0",
      totalAmt: mTotal,
      wallAmt: useWallet.toString(),
      pMethodId: subtotal != 0.0
          ? double.parse(total.toString()) > 0
              ? selectidPay ?? ""
              : "3"
          : "11",
      otid: otid.toString(),
      pLimit: eventDetailsController.totalTicke,
      sponsoreId: eventDetailsController.eventInfo?.eventData.sponsoreId ?? "",
    );
  }

  //!-------- PaymentSheet --------//
  Future paymentSheett() {
    return showModalBottomSheet(
      backgroundColor: WhiteColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (context) {
        return Wrap(children: [
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 10),
                Center(
                  child: Container(
                    height: Get.height / 80,
                    width: Get.width / 5,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                  ),
                ),
                SizedBox(height: Get.height / 50),
                Row(children: [
                  SizedBox(width: Get.width / 14),
                  Text("Select Payment Method".tr,
                      style: TextStyle(
                          color: BlackColor,
                          fontSize: Get.height / 40,
                          fontFamily: 'Gilroy_Bold')),
                ]),
                SizedBox(height: Get.height / 50),
                //! --------- List view paymente ----------
                SizedBox(
                  height: Get.height * 0.50,
                  child: GetBuilder<WalletController>(builder: (context) {
                    return walletController.isLoading
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: walletController
                                .paymentInfo?.paymentdata.length,
                            itemBuilder: (ctx, i) {
                              return walletController
                                          .paymentInfo?.paymentdata[i].pShow !=
                                      "0"
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      child: sugestlocationtype(
                                        borderColor: selectidPay ==
                                                walletController.paymentInfo
                                                    ?.paymentdata[i].id
                                            ? gradient.defoultColor
                                            : const Color(0xffD6D6D6),
                                        title: walletController.paymentInfo
                                                ?.paymentdata[i].title ??
                                            "",
                                        titleColor: BlackColor,
                                        val: 0,
                                        image: Config.imageUrl +
                                            walletController.paymentInfo!
                                                .paymentdata[i].img,
                                        adress: walletController.paymentInfo
                                                ?.paymentdata[i].subtitle ??
                                            "",
                                        ontap: () async {
                                          setState(() {
                                            razorpaykey = walletController
                                                .paymentInfo!
                                                .paymentdata[i]
                                                .attributes;
                                            paymenttital = walletController
                                                .paymentInfo!
                                                .paymentdata[i]
                                                .title;
                                            selectidPay = walletController
                                                    .paymentInfo
                                                    ?.paymentdata[i]
                                                    .id ??
                                                "";
                                            _groupValue = i;
                                          });
                                        },
                                        radio: Radio(
                                          activeColor: gradient.defoultColor,
                                          value: i,
                                          groupValue: _groupValue,
                                          onChanged: (value) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    )
                                  : SizedBox();
                            },
                          )
                        : Center(
                            child: CircularProgressIndicator(
                              color: gradient.defoultColor,
                            ),
                          );
                  }),
                ),
                Container(
                  height: 80,
                  width: Get.size.width,
                  alignment: Alignment.center,
                  child: GestButton(
                    Width: Get.size.width,
                    height: 50,
                    buttoncolor: gradient.defoultColor,
                    margin: EdgeInsets.only(top: 10, left: 30, right: 30),
                    buttontext: "Continue".tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      color: WhiteColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    onclick: () async {
                      //!---- Stripe Payment ------
                      if (paymenttital == "Razorpay") {
                        Get.back();
                        openCheckout();
                      } else if (paymenttital == "Pay TO Owner") {
                        bookEvent("0");
                      } else if (paymenttital == "Paypal") {
                        List<String> keyList = razorpaykey.split(",");
                        print(keyList.toString());
                        paypalPayment(
                          total.toString(),
                          keyList[0],
                          keyList[1],
                        );
                      } else if (paymenttital == "Stripe") {
                        Get.back();
                        stripePayment();
                      } else if (paymenttital == "Paystack") {
                        payStackController.paystackApi(email: getData.read("UserLogin")["email"].toString(), amount: total.toString()).then((value) {
                          Map<String, dynamic> decodedValue = json.decode(value);
                          print("------------ ${decodedValue["data"]["authorization_url"]}");

                            Get.to(PayStackWeb(
                              initialUrl: decodedValue["data"]["authorization_url"],
                              navigationDelegate: (NavigationRequest request) async {
                                final uri = Uri.parse(request.url);
                                print("<><><><><>?<>?>>>>${uri}");
                                if (uri.queryParameters["status"] == null) {
                                  accessToken = uri.queryParameters["token"];
                                } else {
                                  if (uri.queryParameters["status"] == "success") {
                                    print('//////////////////////${uri.queryParameters["trxref"]}');
                                    payerID = uri.queryParameters["trxref"];
                                    print("*******************${payerID}");

                                    bookEvent(payerID);
                                    showToastMessage("Payment Successfully");
                                    Get.back();
                                  } else {

                                    showToastMessage("Payment Fail");
                                  }
                                }
                                return NavigationDecision.navigate;
                              },
                            ));

                        },);
                      } else if (paymenttital == "Flutterwave") {
                        print("++++++++++++++++++++++++++++ ${getData.read("UserLogin")["email"]}");
                        Get.to(() => Flutterwave(
                                  totalAmount: total.toString(),
                                  email: getData.read("UserLogin")["email"].toString(),
                                ))!
                            .then((otid) {
                          if (otid != null) {
                            bookEvent(otid);
                          } else {
                            Get.back();
                          }
                        });
                      } else if (paymenttital == "Paytm") {
                        Get.to(() => PayTmPayment(totalAmount: total.toString(),
                            uid: getData.read("UserLogin")["id"].toString()))!.then((otid) {
                          if (otid != null) {
                            bookEvent(otid);
                            showToastMessage("Payment Successfully");
                          } else {
                            Get.back();
                          }
                        });
                      }
                      else if (paymenttital == "SenangPay") {}
                      else if(paymenttital == "Payfast"){
                        Get.to(() => PayFast(
                          totalAmount: total.toString(),
                          email: getData.read("UserLogin")["email"].toString(),
                        ))!
                            .then((otid) {
                          if (otid != null) {
                            Get.back();
                            bookEvent(otid);
                            showToastMessage("Payment Successfully");
                          } else {
                            Get.back();
                          }
                        });
                      }else if(paymenttital == "Midtrans"){
                        Get.to(MidTrans(
                            email: getData.read("UserLogin")["email"].toString(),
                            totalAmount: total.toString(),
                            mobilenumber: getData.read("UserLogin")["mobile"]))?.then((value) {
                          if(value != null){
                            Get.back();
                            bookEvent(value);
                            showToastMessage("Payment Successfully");
                          } else {
                          }
                        });
                      }else if (paymenttital == "2checkout"){
                        Get.to(() => CheckOutPayment(
                          totalAmount: total.toString(),
                          email: getData.read("UserLogin")["email"].toString()))!
                            .then((otid) {
                          if (otid != null) {
                            Get.back();
                            bookEvent(otid);
                            showToastMessage("Payment Successfully");
                          } else {
                            Get.back();
                          }
                        });
                      }
                      else if(paymenttital == "Khalti Payment"){
                        Get.to(() => Khalti(
                          totalAmount: total.toString(),
                          email: getData.read("UserLogin")["email"].toString(),
                        ))!
                            .then((otid) {
                          if (otid != null) {
                            Get.back();
                            bookEvent(otid);
                            showToastMessage("Payment Successfully");
                          } else {
                            Get.back();
                          }
                        });
                      }
                      else if(paymenttital == "MercadoPago"){
                        Get.to(merpago(
                          totalAmount: total.toString(),
                        ))?.then((value) {
                          if(value != null){
                            Get.back();
                            bookEvent(value);
                            showToastMessage("Payment Successfully");
                          } else {
                          }
                        });
                      }
                    },
                  ),
                  decoration: BoxDecoration(
                    color: WhiteColor,
                  ),
                ),
              ],
            );
          }),
        ],
        );
      },
    );
  }

  Widget sugestlocationtype({Function()? ontap, title, val, image, adress, radio, Color? borderColor, Color? titleColor}) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return InkWell(
        splashColor: Colors.transparent,
        onTap: ontap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: Get.width / 18),
          child: Container(
            height: Get.height / 10,
            decoration: BoxDecoration(
                border: Border.all(color: borderColor!, width: 1),
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(11)),
            child: Row(
              children: [
                SizedBox(width: Get.width / 55),
                Container(
                    height: Get.height / 12,
                    width: Get.width / 5.5,
                    decoration: BoxDecoration(
                        color: const Color(0xffF2F4F9),
                        borderRadius: BorderRadius.circular(10)),
                    child: Center(
                      child: FadeInImage(
                          placeholder: const AssetImage("assets/loading2.gif"),
                          image: NetworkImage(image)),
                      // Image.network(image, height: Get.height / 08)
                    )),
                SizedBox(width: Get.width / 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: Get.height * 0.01),
                    Text(title,
                        style: TextStyle(
                          fontSize: Get.height / 55,
                          fontFamily: FontFamily.gilroyBold,
                          color: titleColor,
                        )),
                    SizedBox(
                      width: Get.width * 0.50,
                      child: Text(adress,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontSize: Get.height / 65,
                              fontFamily: 'Gilroy_Medium',
                              color: Colors.grey)),
                    ),
                  ],
                ),
                const Spacer(),
                radio
              ],
            ),
          ),
        ),
      );
    });
  }

  //!---------Coupon Dialoag-----------!//

  Future couponSucsessFullyApplyed() {
    return Get.defaultDialog(
      title: "",
      content: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            // height: 270,
            width: Get.size.width,
            margin: EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                Container(
                  height: 80,
                  width: 100,
                  decoration: BoxDecoration(
                    color: transparent,
                    image: DecorationImage(
                      image: AssetImage("assets/discount-voucher.png"),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "${"Yey! You've saved".tr} ${currency}${bookEventController.couponAmt} ${"With this coupon".tr}",
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyExtraBold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Supporting small businesses has never been so rewarding!".tr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontFamily: FontFamily.gilroyMedium,
                    height: 1.2,
                    fontSize: 15,
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Text(
                    "Awesome!".tr,
                    style: TextStyle(
                      fontFamily: FontFamily.gilroyBold,
                      color: gradient.defoultColor,
                      fontSize: 17,
                    ),
                  ),
                )
              ],
            ),
            decoration: BoxDecoration(
              color: WhiteColor,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          Positioned(
            top: -160,
            left: 0,
            right: 0,
            child: Container(
              color: transparent,
              child: Lottie.asset(
                'assets/L6o2mVij1E.json',
                repeat: false,
                fit: BoxFit.fill,
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    numberController.removeListener(_getCardTypeFrmNumber);
    numberController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  void _getCardTypeFrmNumber() {
    String input = CardUtils.getCleanedNumber(numberController.text);
    CardTypee cardType = CardUtils.getCardTypeFrmNumber(input);
    setState(() {
      _paymentCard.type = cardType;
    });
  }

  //!--------- Razorpay ----------//
  void openCheckout() async {
    var username = getData.read("UserLogin")["name"] ?? "";
    var mobile = getData.read("UserLogin")["mobile"] ?? "";
    var email = getData.read("UserLogin")["email"] ?? "";
    String currentTotal =
        (double.parse(total.toString()) * 100).toString().split(".").first;
    var options = {
      'key': razorpaykey,
      'amount': currentTotal,
      'name': username,
      'description': "",
      'timeout': 300,
      'prefill': {'contact': mobile, 'email': email},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      print(e.toString());
      debugPrint('Error: e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    bookEvent(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print(
        'Error Response: ${"ERROR: " + response.code.toString() + " - " + response.message!}');
    showToastMessage(response.message!);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    showToastMessage(response.walletName!);
  }

  //!-------- Stripe Patment --------//

  final _formKey = GlobalKey<FormState>();
  var numberController = TextEditingController();
  final _paymentCard = PaymentCardCreated();
  var _autoValidateMode = AutovalidateMode.disabled;
  bool isloading = false;

  final _card = PaymentCardCreated();

  stripePayment() {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      backgroundColor: WhiteColor,
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Ink(
                child: Column(
                  children: [
                    SizedBox(height: Get.height / 45),
                    Center(
                      child: Container(
                        height: Get.height / 85,
                        width: Get.width / 5,
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(height: Get.height * 0.03),
                          Text("Add Your payment information".tr,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: 0.5)),
                          SizedBox(height: Get.height * 0.02),
                          Form(
                            key: _formKey,
                            autovalidateMode: _autoValidateMode,
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                TextFormField(
                                  style: TextStyle(color: Colors.black),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(19),
                                    CardNumberInputFormatter()
                                  ],
                                  controller: numberController,
                                  onSaved: (String? value) {
                                    _paymentCard.number =
                                        CardUtils.getCleanedNumber(value!);

                                    CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(
                                            _paymentCard.number.toString());
                                    setState(() {
                                      _card.name = cardType.toString();
                                      _paymentCard.type = cardType;
                                    });
                                  },
                                  onChanged: (val) {
                                    CardTypee cardType =
                                        CardUtils.getCardTypeFrmNumber(val);
                                    setState(() {
                                      _card.name = cardType.toString();
                                      _paymentCard.type = cardType;
                                    });
                                  },
                                  validator: CardUtils.validateCardNum,
                                  decoration: InputDecoration(
                                    prefixIcon: SizedBox(
                                      height: 10,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 6,
                                        ),
                                        child: CardUtils.getCardIcon(
                                          _paymentCard.type,
                                        ),
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: gradient.defoultColor,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: gradient.defoultColor,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: gradient.defoultColor,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: gradient.defoultColor,
                                      ),
                                    ),
                                    hintText:
                                        "What number is written on card?".tr,
                                    hintStyle: TextStyle(color: Colors.grey),
                                    labelStyle: TextStyle(color: Colors.grey),
                                    labelText: "Number".tr,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Flexible(
                                      flex: 4,
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.grey),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(4),
                                        ],
                                        decoration: InputDecoration(
                                            prefixIcon: SizedBox(
                                              height: 10,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 14),
                                                child: Image.asset(
                                                  'assets/card_cvv.png',
                                                  width: 6,
                                                  color: gradient.defoultColor,
                                                ),
                                              ),
                                            ),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: gradient.defoultColor,
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: gradient.defoultColor,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                color: gradient.defoultColor,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                    color:
                                                        gradient.defoultColor)),
                                            hintText:
                                                "Number behind the card".tr,
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            labelStyle:
                                                TextStyle(color: Colors.grey),
                                            labelText: 'CVV'),
                                        validator: CardUtils.validateCVV,
                                        keyboardType: TextInputType.number,
                                        onSaved: (value) {
                                          _paymentCard.cvv = int.parse(value!);
                                        },
                                      ),
                                    ),
                                    SizedBox(width: Get.width * 0.03),
                                    Flexible(
                                      flex: 4,
                                      child: TextFormField(
                                        style: TextStyle(color: Colors.black),
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(4),
                                          CardMonthInputFormatter()
                                        ],
                                        decoration: InputDecoration(
                                          prefixIcon: SizedBox(
                                            height: 10,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 14),
                                              child: Image.asset(
                                                'assets/calender.png',
                                                width: 10,
                                                color: gradient.defoultColor,
                                              ),
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: gradient.defoultColor,
                                            ),
                                          ),
                                          focusedErrorBorder:
                                              OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: gradient.defoultColor,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: gradient.defoultColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: gradient.defoultColor,
                                            ),
                                          ),
                                          hintText: 'MM/YY',
                                          hintStyle:
                                              TextStyle(color: Colors.black),
                                          labelStyle:
                                              TextStyle(color: Colors.grey),
                                          labelText: "Expiry Date".tr,
                                        ),
                                        validator: CardUtils.validateDate,
                                        keyboardType: TextInputType.number,
                                        onSaved: (value) {
                                          List<int> expiryDate =
                                              CardUtils.getExpiryDate(value!);
                                          _paymentCard.month = expiryDate[0];
                                          _paymentCard.year = expiryDate[1];
                                        },
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: Get.height * 0.055),
                                Container(
                                  alignment: Alignment.center,
                                  child: SizedBox(
                                    width: Get.width,
                                    child: CupertinoButton(
                                      onPressed: () {
                                        _validateInputs();
                                      },
                                      color: gradient.defoultColor,
                                      child: Text(
                                        "Pay ${currency}${total}",
                                        style: TextStyle(fontSize: 17.0),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: Get.height * 0.065),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _validateInputs() {
    final FormState form = _formKey.currentState!;
    if (!form.validate()) {
      setState(() {
        _autoValidateMode =
            AutovalidateMode.always; // Start validating on every change.
      });
      showToastMessage("Please fix the errors in red before submitting.".tr);
    } else {
      var username = getData.read("UserLogin")["name"] ?? "";
      var email = getData.read("UserLogin")["email"] ?? "";
      _paymentCard.name = username;
      _paymentCard.email = email;
      _paymentCard.amount = total.toString();
      form.save();

      Get.to(() => StripePaymentWeb(paymentCard: _paymentCard))!.then((otid) {
        Get.back();
        //! order Api call
        if (otid != null) {
          //! Api Call Payment Success
          print("DFSF. PAYMENT SUCCESS #%#%#%");
          bookEvent(otid);
        }
      });

      showToastMessage("Payment card is valid".tr);
    }
  }

  //!--------- PayPal ----------//

  paypalPayment(String amt, String key, String secretKey,) {
    print("----------->>" + amt.toString());
    print("----------->>" + key.toString());
    print("----------->>" + secretKey.toString());
    Get.back();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return UsePaypal(
            sandboxMode: true,
            clientId: key,
            secretKey: secretKey,
            returnURL:
                "https://www.sandbox.paypal.com/cgi-bin/webscr?cmd=_express-checkout&token=EC-35S7886705514393E",
            cancelURL: Config.paymentBaseUrl + "/cancle.php",
            transactions: [
              {
                "amount": {
                  "total": amt,
                  "currency": "USD",
                  "details": {
                    "subtotal": amt,
                    "shipping": '0',
                    "shipping_discount": 0
                  }
                },
                "description": "The payment transaction description.",
                // "payment_options": {
                //   "allowed_payment_method":
                //       "INSTANT_FUNDING_SOURCE"
                // },
                "item_list": {
                  "items": [
                    {
                      "name": "A demo product",
                      "quantity": 1,
                      "price": amt,
                      "currency": "USD"
                    }
                  ],
                }
              }
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) {
              bookEvent(params["paymentId"].toString());
            },
            onError: (error) {
              print(error);
              showToastMessage(error.toString());
            },
            onCancel: (params) {
              print(params);
              showToastMessage(params.toString());
            },
          );
        },
      ),
    );
  }

}
