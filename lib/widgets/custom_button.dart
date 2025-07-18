import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isSecondary = false,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          // Primary or secondary styling
          backgroundColor: isSecondary
              ? Colors.transparent
              : Theme.of(context).primaryColor,
          foregroundColor: isSecondary
              ? Theme.of(context).primaryColor
              : Colors.white,

          // Border for secondary button
          side: isSecondary
              ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
              : null,

          // Shape and elevation
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: isSecondary ? 0 : 2,

          // Disable shadow for secondary button
          shadowColor: isSecondary ? Colors.transparent : null,
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isSecondary
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(text),
                ],
              )
            : icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
