import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';

class StripePaymentHandle {
  Map<String, dynamic>? paymentIntent;

  Future<void> stripeMakePayment(
      {required String amount,
      required UserModel userModel,
      required Function() onSuccess}) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  billingDetails: BillingDetails(
                    name: userModel.fullname,
                    email: userModel.email,
                    phone: userModel.phone,
                  ),
                  paymentIntentClientSecret: paymentIntent![
                      'client_secret'], //Gotten from payment intent
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Metal APP'))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet(onSuccess);
    } catch (e) {
      print(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  displayPaymentSheet(onSuccess) async {
    try {
      // 3. display the payment sheet.
      await Stripe.instance.presentPaymentSheet();

      Fluttertoast.showToast(msg: 'Payment succesfully completed');
      onSuccess();
    } on Exception catch (e) {
      if (e is StripeException) {
        Fluttertoast.showToast(
            msg: 'Error from Stripe: ${e.error.localizedMessage}');
      } else {
        Fluttertoast.showToast(msg: 'Unforeseen error: $e');
      }
    }
  }

//create Payment
  createPaymentIntent(String amount, String currency) async {
    try {
      // Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      // Initialize Dio
      Dio dio = Dio();

      // Add the authorization header
      dio.options.headers['Authorization'] =
          'Bearer ${dotenv.env['Secret-key']}';
      dio.options.headers['Content-Type'] = 'application/x-www-form-urlencoded';

      // Make post request using Dio
      Response response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: body,
      );

      // Decode and return the response
      return json.decode(response.toString());
    } catch (err) {
      throw Exception(err.toString());
    }
  }

//calculate Amount
  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount)) * 100;
    return calculatedAmount.toString();
  }
}
