// import 'package:flutter/material.dart';
// import '../utils/ad_helper.dart';

// class BannerAdWidget extends StatefulWidget {
//   const BannerAdWidget({Key? key}) : super(key: key);

//   @override
//   State<BannerAdWidget> createState() => _BannerAdWidgetState();
// }

// class _BannerAdWidgetState extends State<BannerAdWidget> {
//   BannerAd? _bannerAd;
//   bool _isAdLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadBannerAd();
//   }

//   void _loadBannerAd() {
//     _bannerAd = BannerAd(
//       adUnitId: AdHelper.getBannerAdUnitId(),
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           setState(() {
//             _isAdLoaded = true;
//           });
//           print('Banner reklam başarıyla yüklendi');
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           print('Banner reklam yüklenemedi: ${error.message}');
//           // Yükleme başarısız olduğunda tekrar deneme
//           Future.delayed(const Duration(seconds: 30), () {
//             if (mounted) {
//               _loadBannerAd();
//             }
//           });
//         },
//       ),
//     );

//     _bannerAd?.load();
//   }

//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_bannerAd == null || !_isAdLoaded) {
//       return const SizedBox(height: 50);
//     }

//     return SizedBox(
//       width: _bannerAd!.size.width.toDouble(),
//       height: _bannerAd!.size.height.toDouble(),
//       child: AdWidget(ad: _bannerAd!),
//     );
//   }
// }