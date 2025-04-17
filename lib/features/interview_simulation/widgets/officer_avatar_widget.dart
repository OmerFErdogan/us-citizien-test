import 'package:flutter/material.dart';
import '../models/interview_models.dart';

/// Görüşme memuru avatar widget'i
class OfficerAvatarWidget extends StatelessWidget {
  final UscisOfficer officer;
  final double size;
  final bool isAnimated;
  final bool isActive;

  const OfficerAvatarWidget({
    Key? key,
    required this.officer,
    this.size = 64,
    this.isAnimated = false,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Debug bilgilerini gizle
    return Stack(
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: AssetImage(officer.avatarImagePath),
        ),
        if (isActive)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size / 4,
              height: size / 4,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        if (isAnimated)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue, width: 2),
              ),
              child: const Center(
                child: SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
