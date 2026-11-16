import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class AppTypography extends StatelessWidget {
  const AppTypography.title(
    this.text, {
    this.color = AppColors.ink900,
    this.align,
    this.maxLines,
    this.overflow,
    super.key,
  }) : style = AppTextStyles.programmeName;

  const AppTypography.section(
    this.text, {
    this.color = AppColors.ink500,
    this.align,
    this.maxLines,
    this.overflow,
    super.key,
  }) : style = AppTextStyles.sectionHeading;

  const AppTypography.body(
    this.text, {
    this.color = AppColors.ink900,
    this.align,
    this.maxLines,
    this.overflow,
    super.key,
  }) : style = AppTextStyles.bodyText;

  const AppTypography.table(
    this.text, {
    this.color = AppColors.ink900,
    this.align,
    this.maxLines,
    this.overflow,
    super.key,
  }) : style = AppTextStyles.tableText;

  const AppTypography.caption(
    this.text, {
    this.color = AppColors.ink500,
    this.align,
    this.maxLines,
    this.overflow,
    super.key,
  }) : style = AppTextStyles.metricLabel;

  final String text;
  final TextStyle style;
  final Color color;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style.copyWith(color: color),
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
