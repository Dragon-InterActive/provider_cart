import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StripeService {
  /// Zahlungs Flow

  static Future<bool> processPayment({
    required double totalAmount,
    required String currency,
  }) async {
    try {
      //1. Cloud function
      final amountInCents = (totalAmount * 100).toInt();
      debugPrint('Sende an Firebase:');
      debugPrint('  Amount: $amountInCents');
      debugPrint('  Currency: $currency');

      final callable = FirebaseFunctions.instanceFor(
        region: 'us-central1',
      ).httpsCallable('createPaymentIntent');
      final result = await callable.call(<String, dynamic>{
        'amount': amountInCents,
        'currency': currency,
      });

      //2. Clientsecret holen
      final clientSecret = result.data['clientSecret'] as String;

      // 3. Paymentsheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Provider Cart',
          style: ThemeMode.system,
        ),
      );

      // Paymentsheet anzeigen
      await Stripe.instance.presentPaymentSheet();
      return true;
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Firebase Fehler: ${e.code} - ${e.message}');
      return false;
    } on StripeException catch (e) {
      debugPrint('Strip Fehler: ${e.error.localizedMessage}');
      return false;
    } catch (e) {
      debugPrint('Allgemeiner Fehler: $e');
      return false;
    }
  }
}
