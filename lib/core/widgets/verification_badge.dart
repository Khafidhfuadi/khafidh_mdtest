// verification_badge.dart - Badge status verifikasi email
import 'package:flutter/material.dart';

class VerificationBadge extends StatelessWidget {
  final bool isVerified;

  const VerificationBadge({super.key, required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFF16532D) : const Color(0xFF450A0A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\u2022 ',
            style: TextStyle(
              fontSize: 14,
              color: isVerified
                  ? const Color(0xFF4ADE80)
                  : const Color(0xFFFCA5A5),
            ),
          ),
          Text(
            isVerified ? 'Verified' : 'Not Verified',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isVerified
                  ? const Color(0xFF4ADE80)
                  : const Color(0xFFFCA5A5),
            ),
          ),
        ],
      ),
    );
  }
}
