import 'package:flutter/material.dart';

/// ABD vatandaşlık temasına uygun geliştirilmiş onboarding sayfası veri modeli
class OnboardingPage {
  final String title; // Sayfa başlığı
  final String description; // Sayfa açıklaması
  final String imagePath; // Ana görsel yolu
  final Color backgroundColor; // Arka plan rengi
  final Color secondaryColor; // İkincil tema rengi
  final Color textColor; // Metin rengi
  final IconData icon; // Tema ikonu
  final String symbolImage; // ABD vatandaşlık sembolü görsel yolu

  OnboardingPage({
    required this.title,
    required this.description, 
    required this.imagePath,
    required this.symbolImage,
    required this.icon,
    this.backgroundColor = Colors.white,
    this.secondaryColor = Colors.blue,
    this.textColor = Colors.black87,
  });
}
