import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class StripeService {
  static const String publishableKey =
      'pk_test_51N89riFiAvvrMfxF5CrKRqzHp8r9W692c4kcYlvoekki8giyuVeV1sr4EFwbAKPD757x2yZ1rEc3lofEosoCCpd000YkxIkbmm';

  static Future<void> init() async {
    try {
      // Skip Stripe initialization on web as it's not fully supported
      if (kIsWeb) {
        log('Stripe initialization skipped on web platform');
        return;
      }

      Stripe.publishableKey = publishableKey;
      log('Stripe initialized successfully');
    } catch (e) {
      log('Error initializing Stripe: $e');
      // Don't rethrow to prevent app crash
      log('Continuing without Stripe initialization');
    }
  }

  static Future<PaymentIntent?> createPaymentIntent({
    required String clientSecret,
    BillingDetails? billingDetails,
  }) async {
    try {
      if (kIsWeb) {
        log('Payment intents not supported on web');
        throw Exception('Payment processing not available on web');
      }

      log('Creating payment intent');

      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(billingDetails: billingDetails),
        ),
      );

      return await Stripe.instance.retrievePaymentIntent(clientSecret);
    } catch (e) {
      log('Error creating payment intent: $e');
      rethrow;
    }
  }

  static Future<PaymentMethod> createPaymentMethod({
    BillingDetails? billingDetails,
  }) async {
    try {
      if (kIsWeb) {
        log('Payment methods not supported on web');
        throw Exception('Payment method creation not available on web');
      }

      log('Creating payment method');

      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(billingDetails: billingDetails),
        ),
      );

      log('Payment method created: ${paymentMethod.id}');
      return paymentMethod;
    } catch (e) {
      log('Error creating payment method: $e');
      rethrow;
    }
  }

  static Future<bool> confirmPayment({
    required String clientSecret,
    BillingDetails? billingDetails,
  }) async {
    try {
      if (kIsWeb) {
        log('Payment confirmation not supported on web');
        throw Exception('Payment confirmation not available on web');
      }

      log('Confirming payment');

      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(billingDetails: billingDetails),
        ),
      );

      log('Payment confirmed: ${paymentIntent.status}');
      return paymentIntent.status == PaymentIntentsStatus.Succeeded;
    } catch (e) {
      log('Error confirming payment: $e');
      rethrow;
    }
  }

  static String getErrorMessage(dynamic error) {
    if (kIsWeb) {
      return 'Payment processing not available on web. Please use the mobile app.';
    }

    if (error is StripeException) {
      switch (error.error.code) {
        case FailureCode.Canceled:
          return 'Payment was cancelled';
        case FailureCode.Failed:
          return 'Payment failed. Please try again.';
        case FailureCode.Timeout:
          return 'Payment timed out. Please try again.';
        default:
          return error.error.message ?? 'Payment failed';
      }
    }
    return 'An unexpected error occurred';
  }
}
