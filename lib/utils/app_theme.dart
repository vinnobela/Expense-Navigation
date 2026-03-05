import 'package:flutter/material.dart';

const kPrimary     = Color(0xFF9B8FD4);
const kPrimaryDark = Color(0xFF7B6FBF);
const kAccent      = Color(0xFFBDB5E8);
const kBg          = Color(0xFFF4F2FC);
const kCard        = Color(0xFFEDE9F8);
const kGreen       = Color(0xFF00C896);
const kRed         = Color(0xFFFF3B5C);

const kGradient = LinearGradient(
  colors: [kPrimaryDark, kAccent],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: kPrimary),
    useMaterial3: true,
  );
}