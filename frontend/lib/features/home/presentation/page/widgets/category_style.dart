import 'package:flutter/material.dart';

class CategoryStyle {
  final Color backgroundColor;
  final Color progressColor;
  final Color iconColor;
  final IconData icon;
  final String label;

  CategoryStyle({
    required this.backgroundColor,
    required this.progressColor,
    required this.iconColor,
    required this.icon,
    required this.label,
  });
}

CategoryStyle getCategoryStyle(String category) {
  switch (category) {
    case 'Office':
      return CategoryStyle(
        backgroundColor: const Color(0xFFE0F2FE), // Sky blue 100
        progressColor: const Color(0xFF0284C7), // Sky blue 600
        iconColor: const Color(0xFFEC4899), // Pink 500
        icon: Icons.business_center_rounded,
        label: 'Office Project',
      );
    case 'Personal':
      return CategoryStyle(
        backgroundColor: const Color(0xFFFFF0F5), // Lavender/pink 50
        progressColor: const Color(0xFF8B5CF6), // Purple 500
        iconColor: const Color(0xFF8B5CF6), // Purple 500
        icon: Icons.person_rounded,
        label: 'Personal Project',
      );
    case 'Self':
      return CategoryStyle(
        backgroundColor: const Color(0xFFFFEDD5), // Orange 100
        progressColor: const Color(0xFFF97316), // Orange 500
        iconColor: const Color(0xFFF97316), // Orange 500
        icon: Icons.book_rounded,
        label: 'Daily Study',
      );
    case 'Health':
      return CategoryStyle(
        backgroundColor: const Color(0xFFDCFCE7), // Green 100
        progressColor: const Color(0xFF10B981), // Green 500
        iconColor: const Color(0xFF10B981), // Green 500
        icon: Icons.favorite_rounded,
        label: 'Health & Fitness',
      );
    case 'Finance':
      return CategoryStyle(
        backgroundColor: const Color(0xFFFEE2E2), // Red 100
        progressColor: const Color(0xFFEF4444), // Red 500
        iconColor: const Color(0xFFEF4444), // Red 500
        icon: Icons.account_balance_wallet_rounded,
        label: 'Finance Tracker',
      );
    case 'Career':
      return CategoryStyle(
        backgroundColor: const Color(0xFFE2F0FD), // Sky blue 50
        progressColor: const Color(0xFF0EA5E9), // Blue 500
        iconColor: const Color(0xFF0EA5E9), // Blue 500
        icon: Icons.work_rounded,
        label: 'Career Growth',
      );
    case 'Home':
      return CategoryStyle(
        backgroundColor: const Color(0xFFECFDF5), // Emerald 50
        progressColor: const Color(0xFF059669), // Emerald 600
        iconColor: const Color(0xFF059669), // Emerald 600
        icon: Icons.home_rounded,
        label: 'Home Tasks',
      );
    case 'Leisure':
      return CategoryStyle(
        backgroundColor: const Color(0xFFFFF1F2), // Rose 50
        progressColor: const Color(0xFFF43F5E), // Rose 500
        iconColor: const Color(0xFFF43F5E), // Rose 500
        icon: Icons.surfing_rounded,
        label: 'Leisure Activities',
      );
    case 'Fun':
      return CategoryStyle(
        backgroundColor: const Color(0xFFFEF9C3), // Yellow 100
        progressColor: const Color(0xFFEAB308), // Yellow 500
        iconColor: const Color(0xFFEAB308), // Yellow 500
        icon: Icons.celebration_rounded,
        label: 'Fun & Games',
      );
    default:
      return CategoryStyle(
        backgroundColor: const Color(0xFFF1F5F9), // Slate 100
        progressColor: const Color(0xFF64748B), // Slate 500
        iconColor: const Color(0xFF64748B), // Slate 500
        icon: Icons.task_alt_rounded,
        label: category,
      );
  }
}
