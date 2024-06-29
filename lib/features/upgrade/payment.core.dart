import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

class StripePaymentHandle {
  Map<String, dynamic>? paymentIntent;

  Future<void> stripeMakePayment({
    required String amount,
    required UserModel userModel,
    required Function() onSuccess,
    required BuildContext context,
  }) async {
    try {
      await initPaymentSheet(amount, userModel);
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      Dio dio = Dio();
      dio.options.headers['Authorization'] =
          'Bearer ${dotenv.env['Secret-key']}';
      dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

      Response response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: body,
      );

      return json.decode(response.toString());
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  String calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }

  Future<void> initPaymentSheet(String amount, UserModel user) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');

      final billingDetails = BillingDetails(
        name: user.fullname,
        email: user.email,
        phone: user.phone,
      );

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          merchantDisplayName: 'The Metal App',
          primaryButtonLabel: 'Pay now',
          applePay: PaymentSheetApplePay(
            merchantCountryCode: 'CA',
            cartItems: [
              ApplePayCartSummaryItem.recurring(
                label: 'Subscription',
                amount: amount,
                intervalUnit: ApplePayIntervalUnit.year,
                intervalCount: 1,
              ),
            ],
            request: PaymentRequestType.recurring(
              description: 'subscription',
              managementUrl: 'https://themetalapp.com/',
              billing: ImmediateCartSummaryItem(
                label: 'Subscription',
                amount: amount,
                isPending: false,
              ),
            ),
          ),
          // googlePay: PaymentSheetGooglePay(
          //   merchantCountryCode: 'CA',
          //   testEnv: true,
          // ),
          
          style: ThemeMode.dark,
          billingDetails: billingDetails,
        ),
      );
      confirmPayment();
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      rethrow;
    }
  }

  Future<void> confirmPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      Fluttertoast.showToast(msg: 'Payment successfully completed');
    } on Exception catch (e) {
      if (e is StripeException) {
        Fluttertoast.showToast(
            msg: 'Error from Stripe: ${e.error.localizedMessage}');
      } else {
        Fluttertoast.showToast(msg: 'Unforeseen error: $e');
      }
    }
  }
}
