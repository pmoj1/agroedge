import 'package:flutter/material.dart';
import '../theme.dart';

class AppTypography extends StatelessWidget {
  const AppTypography.title(
    this.text, {
    this.color = AppColors.ink900,
    this.align,
    this.maxLines,
    this.overflow,
    super.key,
  }) : fontSize = AppFontSizes.title,
       fontFamily = 'Georgia',
       fontFamilyFallback = const ['Liberation Serif', 'serif'],
       fontWeight = FontWeight.bold;

  const AppTypography.subtitle(
    this.text, {
    this.color = AppColors.ink900,
    this.align,
    this.maxLines,
    this.overflow,
    super.key,
  }) : fontSize = AppFontSizes.subtitle,
       fontFamily = 'Georgia',
       fontFamilyFallback = const ['Liberation Serif', 'serif'],
       fontWeight = FontWeight.w600;

  const AppTypography.body(
    this.text, {
    this.color = AppColors.ink900,
    this.align,
    this.maxLines,
    this.overflow,
    super.key,
  }) : fontSize = AppFontSizes.body,
       fontFamily = 'Georgia',
       fontFamilyFallback = const ['Liberation Serif', 'serif'],
       fontWeight = FontWeight.normal;

  const AppTypography.label(
    this.text, {
    this.color = AppColors.ink900,
    this.align,
    this.maxLines,
    this.overflow,
    this.fontWeight = FontWeight.w600,
    super.key,
  }) : fontSize = AppFontSizes.body,
       fontFamily = 'Calibri',
       fontFamilyFallback = const ['Liberation Sans', 'sans-serif'];

  const AppTypography.caption(
    this.text, {
    this.color = AppColors.ink500,
    this.align,
    this.maxLines,
    this.overflow,
    super.key,
  }) : fontSize = AppFontSizes.caption,
       fontFamily = 'Calibri',
       fontFamilyFallback = const ['Liberation Sans', 'sans-serif'],
       fontWeight = FontWeight.normal;

  final String text;
  final double fontSize;
  final String fontFamily;
  final List<String> fontFamilyFallback;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFamilyFallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: fontFamily == 'Georgia' ? 1.4 : 1.2,
      ),
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
