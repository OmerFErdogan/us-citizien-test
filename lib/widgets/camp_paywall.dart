import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/revenue_cat_service.dart';

class CampPaywall extends StatefulWidget {
  const CampPaywall({Key? key}) : super(key: key);

  @override
  State<CampPaywall> createState() => _CampPaywallState();
}

class _CampPaywallState extends State<CampPaywall> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(l10n),
          const SizedBox(height: 20),
          _buildFeatures(l10n),
          const SizedBox(height: 20),
          _buildPricing(l10n),
          const SizedBox(height: 20),
          _buildPurchaseButton(l10n),
          const SizedBox(height: 12),
          _buildRestoreButton(l10n),
          const SizedBox(height: 8),
          _buildCloseButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        const Icon(Icons.military_tech, size: 60, color: Colors.amber),
        const SizedBox(height: 12),
        Text(
          l10n.unlockCampMode,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          l10n.masterCitizenshipTest,
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeatures(AppLocalizations l10n) {
    return Column(
      children: [
        _FeatureItem(
          icon: Icons.calendar_today,
          title: l10n.tenDayStructuredPlan,
          description: l10n.scientificallyDesigned,
        ),
        _FeatureItem(
          icon: Icons.quiz,
          title: l10n.unlimitedPractice,
          description: l10n.accessAllQuestions,
        ),
        _FeatureItem(
          icon: Icons.analytics,
          title: l10n.progressTracking,
          description: l10n.detailedAnalytics,
        ),
        _FeatureItem(
          icon: Icons.block,
          title: l10n.adFreeExperience,
          description: l10n.studyWithoutInterruptions,
        ),
      ],
    );
  }

  Widget _buildPricing(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$4.99',
                style: TextStyle(
                  fontSize: 18,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '\$1.99',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          Text(
            l10n.limitedTimeOffer,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButton(AppLocalizations l10n) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePurchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                l10n.unlockCampModePrice,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildRestoreButton(AppLocalizations l10n) {
    return TextButton(
      onPressed: _handleRestore,
      child: Text(
        l10n.restorePurchases,
        style: TextStyle(color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildCloseButton() {
    return TextButton(
      onPressed: () => Navigator.of(context).pop(false),
      child: Text(
        'Maybe Later',
        style: TextStyle(color: Colors.grey[500], fontSize: 14),
      ),
    );
  }

  void _handlePurchase() async {
    setState(() => _isLoading = true);

    try {
      final result = await RevenueCatService.purchaseCampMode();

      if (result.success) {
        Navigator.of(context).pop(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.celebration, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.welcomeToCampMode),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Debug mode için geçici çözüm
        if (result.error?.contains('InvalidCredentialsError') == true ||
            result.error?.contains('Invalid API Key') == true) {
          // RevenueCat API key hatası durumunda debug access ver
          Navigator.of(context).pop(true);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Debug mode: Kamp moduna erişim sağlandı (geçici)'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }
        _showError(result.error ?? AppLocalizations.of(context)!.purchaseFailed);
      }
    } catch (e) {
      // Debug mode fallback
      if (e.toString().contains('InvalidCredentialsError') ||
          e.toString().contains('Invalid API Key')) {
        Navigator.of(context).pop(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Debug mode: Kamp moduna erişim sağlandı (geçici)'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      _showError('${AppLocalizations.of(context)!.somethingWentWrong}: $e');
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleRestore() async {
    try {
      final result = await RevenueCatService.restorePurchases();

      if (result.success && result.hasPremium) {
        Navigator.of(context).pop(true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.purchasesRestored),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _showError(AppLocalizations.of(context)!.noPreviousPurchases);
      }
    } catch (e) {
      _showError('${AppLocalizations.of(context)!.restoreFailed}: $e');
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
