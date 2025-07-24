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
        throw Exception(
          'Payment processing is not available on web platforms. Please use a mobile device.',
        );
      }

      log(
        'Creating payment intent with client secret: ${clientSecret.substring(0, 20)}...',
      );

      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(billingDetails: billingDetails),
        ),
      );

      final paymentIntent = await Stripe.instance.retrievePaymentIntent(
        clientSecret,
      );
      log('Payment intent retrieved successfully');

      return paymentIntent;
    } on StripeException catch (e) {
      log('Stripe error: ${e.error.message}');
      final errorMessage = _getLocalizedErrorMessage(e.error.code.toString());
      throw Exception(errorMessage);
    } catch (e) {
      log('Unexpected error creating payment intent: $e');
      throw Exception(
        'An unexpected error occurred during payment processing. Please try again.',
      );
    }
  }

  static String _getLocalizedErrorMessage(String? errorCode) {
    switch (errorCode) {
      case 'payment_intent_authentication_failure':
        return 'Payment authentication failed. Please check your payment details and try again.';
      case 'card_declined':
        return 'Your card was declined. Please try a different payment method.';
      case 'insufficient_funds':
        return 'Insufficient funds. Please check your account balance.';
      case 'incorrect_cvc':
        return 'Your card\'s security code is incorrect.';
      case 'expired_card':
        return 'Your card has expired. Please use a different card.';
      case 'processing_error':
        return 'An error occurred while processing your payment. Please try again.';
      case 'incorrect_number':
        return 'Your card number is incorrect.';
      default:
        return 'Payment failed. Please check your payment details and try again.';
    }
  }

  static Future<bool> isPlatformSupported() async {
    return !kIsWeb;
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