import 'package:flutter/material.dart';
import '../utils/responsive/responsive.dart';

class ErrorContentWidget extends StatelessWidget {
  final String errorMessage;

  const ErrorContentWidget({
    Key? key,
    required this.errorMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper.of(context);
    final double spacing = responsive.value(small: 12.0, medium: 16.0, large: 24.0);
    
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: spacing),
          Text(
            errorMessage, 
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
