import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  Size get screenSize => MediaQuery.of(this).size;

  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  bool get isPortrait => MediaQuery.of(this).orientation == Orientation.portrait;

  bool get isLandscape => MediaQuery.of(this).orientation == Orientation.landscape;

  bool get isMobile => screenWidth < 600;

  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;

  bool get isDesktop => screenWidth >= 1024;

  EdgeInsets get systemPadding => MediaQuery.of(this).padding;

  EdgeInsets get viewInsets => MediaQuery.of(this).viewInsets;
}

extension DateTimeExtensions on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  String get formattedDate {
    return '$day/$month/$year';
  }

  String get formattedTime {
    return '$hour:${minute.toString().padLeft(2, '0')}';
  }

  String get formattedDateTime {
    return '$formattedDate $formattedTime';
  }

  int get daysAgo {
    final now = DateTime.now();
    final difference = now.difference(this);
    return difference.inDays;
  }

  bool get isExpired => isBefore(DateTime.now());

  bool get isExpiringSoon {
    final difference = this.difference(DateTime.now());
    return difference.inHours > 0 && difference.inHours <= 48;
  }

}

extension StringExtensions on String {
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  bool get isValidPassword {
    return length >= 8;
  }

  String get capitalized {
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get titleCase {
    return split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }

  bool get isNotEmptyOrWhitespace {
    return trim().isNotEmpty;
  }
}

extension NumExtensions on num {
  String get formattedString {
    if (this is int) {
      return toString();
    } else {
      return toStringAsFixed(2);
    }
  }

  String get formattedWithComma {
    return toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (Match m) => ',',
        );
  }
}

extension ListExtensions<T> on List<T> {
  List<T> get shuffled {
    final list = [...this];
    list.shuffle();
    return list;
  }

  T? getByIndex(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  List<T> separatedBy(T separator) {
    if (isEmpty) return [];
    return expand((item) => [item, separator]).toList()..removeLast();
  }
}
