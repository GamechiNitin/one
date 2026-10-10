import 'package:flutter/material.dart';

/// Maps backend icon keys to Material icons.
IconData iconFor(String key) {
  switch (key) {
    case 'ticket':
      return Icons.confirmation_number_outlined;
    case 'play':
      return Icons.play_arrow_rounded;
    case 'bag':
      return Icons.shopping_bag_outlined;
    case 'live':
      return Icons.sensors;
    case 'gift':
      return Icons.card_giftcard;
    case 'tv':
      return Icons.tv;
    case 'star':
      return Icons.star_outline;
    default:
      return Icons.circle_outlined;
  }
}
