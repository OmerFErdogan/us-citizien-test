import 'package:flutter/material.dart';

class AnswerOption extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isIncorrect;
  final VoidCallback onTap;

  const AnswerOption({
    Key? key,
    required this.text,
    required this.isSelected,
    required this.onTap,
    this.isCorrect = false,
    this.isIncorrect = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? trailingIcon;

    if (isCorrect) {
      backgroundColor = Colors.green[50]!;
      borderColor = Colors.green;
      textColor = Colors.green[800]!;
      trailingIcon = Icons.check_circle;
    } else if (isIncorrect) {
      backgroundColor = Colors.red[50]!;
      borderColor = Colors.red;
      textColor = Colors.red[800]!;
      trailingIcon = Icons.cancel;
    } else if (isSelected) {
      backgroundColor = Colors.blue[50]!;
      borderColor = Colors.blue;
      textColor = Colors.blue[800]!;
      trailingIcon = null;
    } else {
      backgroundColor = Colors.white;
      borderColor = Colors.grey[300]!;
      textColor = Colors.black87;
      trailingIcon = null;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCorrect || isIncorrect ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            border: Border.all(
              color: borderColor,
              width: isSelected || isCorrect || isIncorrect ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (isSelected && !isCorrect && !isIncorrect)
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.circle, size: 12, color: Colors.white),
                  ),
                )
              else if (!isSelected && !isCorrect && !isIncorrect)
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                    border: Border.all(color: Colors.grey[400]!, width: 1.5),
                  ),
                ),
                
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isSelected || isCorrect || isIncorrect
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
              
              if (trailingIcon != null)
                Icon(
                  trailingIcon,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
            ],
          ),
        ),
      ),
    );
  }
}