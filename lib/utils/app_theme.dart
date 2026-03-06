import 'package:flutter/material.dart';

// ── Core palette (matches dark redesign) ──────────────────────────────────────
const kBg          = Color(0xFF0F1117); // near-black background
const kCard        = Color(0xFF181920); // card surface
const kCardBorder  = Color(0xFF22232E); // subtle card border

// Home accent: coral → orange
const kCoral       = Color(0xFFFF6348);
const kOrange      = Color(0xFFFF9F43);

// Edit / teal accent
const kTeal        = Color(0xFF48C9FF);
const kViolet      = Color(0xFFA78BFA);

// Category accent colours
const kGreen       = Color(0xFF48C9FF); // amounts shown in teal
const kRed         = Color(0xFFFF3B5C);

// Gradients
const kHeroGradient = LinearGradient(
  colors: [kCoral, kOrange],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kEditGradient = LinearGradient(
  colors: [kTeal, kViolet],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

const kAppBarGradient = LinearGradient(
  colors: [Color(0xFF1A1B26), Color(0xFF1E1F2E)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

// Category left-bar and amount colours per type
const kCatFoodColor  = kCoral;
const kCatBillColor  = kTeal;
const kCatDrinkColor = kViolet;

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    colorScheme: ColorScheme.dark(
      primary: kCoral,
      secondary: kTeal,
      surface: kCard,
      background: kBg,
    ),
    useMaterial3: true,
    fontFamily: 'DMSans',
  );
}
