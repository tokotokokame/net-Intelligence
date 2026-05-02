import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get darkTheme {
    // Noto Sans JP: 日本語字形を正しく表示するためのフォント
    // デフォルトのフォントフォールバックは中国語フォントを優先する場合があるため明示指定
    final textTheme = GoogleFonts.notoSansJpTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00BCD4),
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        titleTextStyle: GoogleFonts.notoSansJp(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFF1A1A2E),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
