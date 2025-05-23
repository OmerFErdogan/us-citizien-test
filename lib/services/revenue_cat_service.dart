import 'dart:io';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  // RevenueCat API Keys - Replace with your actual keys
  static const String _apiKeyIOS = 'appl_RevenueCatAPIKey';
  static const String _apiKeyAndroid = 'goog_RevenueCatAPIKey';
  
  // Product and Entitlement IDs
  static const String premiumEntitlementId = 'premium_access';
  static const String campModeProductId = 'us_citizenship_premium';
  
  /// Initialize RevenueCat SDK
  static Future<void> initialize() async {
    try {
      // Enable debug logs in debug mode
      await Purchases.setLogLevel(LogLevel.debug);
      
      // Configure for the platform
      late PurchasesConfiguration configuration;
      if (Platform.isAndroid) {
        configuration = PurchasesConfiguration(_apiKeyAndroid);
      } else if (Platform.isIOS) {
        configuration = PurchasesConfiguration(_apiKeyIOS);
      } else {
        throw UnsupportedError('Platform not supported');
      }
      
      await Purchases.configure(configuration);
      
      print('RevenueCat initialized successfully');
    } catch (e) {
      print('Failed to initialize RevenueCat: $e');
    }
  }
  
  /// Check if user has premium access
  static Future<bool> isPremiumUser() async {
    try {
      CustomerInfo customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[premiumEntitlementId]?.isActive == true;
    } catch (e) {
      print('Error checking premium status: $e');
      // RevenueCat hatası durumunda geçici olarak false döndür
      // Production'da bu kısım kaldırılmalı
      if (e.toString().contains('InvalidCredentialsError')) {
        print('RevenueCat API key hatası - geçici olarak premium erişimi kapalı');
        return false;
      }
      return false;
    }
  }
  
  /// Purchase camp mode premium
  static Future<PurchaseResult> purchaseCampMode() async {
    try {
      // Get offerings
      Offerings offerings = await Purchases.getOfferings();
      
      if (offerings.current == null) {
        return PurchaseResult(
          success: false,
          error: 'No available products found'
        );
      }
      
      // Find the camp mode product
      Package? campModePackage;
      for (Package package in offerings.current!.availablePackages) {
        if (package.storeProduct.identifier == campModeProductId) {
          campModePackage = package;
          break;
        }
      }
      
      if (campModePackage == null) {
        return PurchaseResult(
          success: false,
          error: 'Camp mode product not found'
        );
      }
      
      // Make the purchase
      CustomerInfo customerInfo = await Purchases.purchasePackage(campModePackage);
      bool isPremium = customerInfo.entitlements.all[premiumEntitlementId]?.isActive == true;
      
      return PurchaseResult(
        success: isPremium,
        customerInfo: customerInfo
      );
      
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      String errorMessage = _getErrorMessage(errorCode);
      print('Purchase error: $errorCode - $errorMessage');
      
      return PurchaseResult(
        success: false,
        error: errorMessage,
        errorCode: errorCode
      );
    } catch (e) {
      print('Unexpected purchase error: $e');
      return PurchaseResult(
        success: false,
        error: 'Something went wrong. Please try again.'
      );
    }
  }
  
  /// Restore previous purchases
  static Future<RestoreResult> restorePurchases() async {
    try {
      CustomerInfo customerInfo = await Purchases.restorePurchases();
      bool isPremium = customerInfo.entitlements.all[premiumEntitlementId]?.isActive == true;
      
      return RestoreResult(
        success: true,
        hasPremium: isPremium,
        customerInfo: customerInfo
      );
    } catch (e) {
      print('Restore error: $e');
      return RestoreResult(
        success: false,
        error: 'Failed to restore purchases. Please try again.'
      );
    }
  }
  
  /// Get available offerings/products
  static Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      print('Error getting offerings: $e');
      return null;
    }
  }
  
  /// Set user ID for RevenueCat
  static Future<void> setUserID(String userID) async {
    try {
      await Purchases.logIn(userID);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }
  
  /// Log out user
  static Future<void> logOut() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      print('Error logging out: $e');
    }
  }
  
  /// Get human-readable error message
  static String _getErrorMessage(PurchasesErrorCode errorCode) {
    switch (errorCode) {
      case PurchasesErrorCode.purchaseCancelledError:
        return 'Purchase was cancelled.';
      case PurchasesErrorCode.purchaseNotAllowedError:
        return 'Purchase not allowed.';
      case PurchasesErrorCode.purchaseInvalidError:
        return 'Purchase is invalid.';
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        return 'Product not available for purchase.';
      case PurchasesErrorCode.productAlreadyPurchasedError:
        return 'You already own this product.';
      case PurchasesErrorCode.receiptAlreadyInUseError:
        return 'Receipt already in use.';
      case PurchasesErrorCode.paymentPendingError:
        return 'Payment is pending. Please wait.';
      case PurchasesErrorCode.networkError:
        return 'Network error. Please check your connection.';
      case PurchasesErrorCode.configurationError:
        return 'Configuration error. Please contact support.';
      default:
        return 'Purchase failed. Please try again.';
    }
  }
}

/// Result of a purchase attempt
class PurchaseResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final String? error;
  final PurchasesErrorCode? errorCode;
  
  PurchaseResult({
    required this.success,
    this.customerInfo,
    this.error,
    this.errorCode,
  });
}

/// Result of a restore attempt
class RestoreResult {
  final bool success;
  final bool hasPremium;
  final CustomerInfo? customerInfo;
  final String? error;
  
  RestoreResult({
    required this.success,
    this.hasPremium = false,
    this.customerInfo,
    this.error,
  });
}
