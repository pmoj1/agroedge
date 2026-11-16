import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';
import '../../core/theme/spacing.dart';
import '../../core/theme/text_styles.dart';
import 'widgets/choropleth_map.dart';
import 'widgets/crop_analytics_card.dart';
import 'widgets/distribution_list.dart';
import 'widgets/enrolment_timeline_chart.dart';
import 'widgets/farm_health_overview.dart';
import 'widgets/masthead.dart';
import 'widgets/metric_row.dart';
import 'widgets/needs_attention_panel.dart';
import 'widgets/status_timeline.dart';
import 'widgets/weather_widget.dart';

/// AgroEdge Agricultural Intelligence Dashboard
/// Bloomberg-density layout, Stripe-level simplicity, Apple-level polish.
/// Staggered entrance animations on every section row.
/// Desktop-first 1440px, minimum 1024px (per programme-overview.md).
class ProgrammeOverviewScreen extends StatelessWidget {
  const ProgrammeOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF0EBE0), // Warm parchment background
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1440, minWidth: 1024),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── 0: Masthead ─────────────────────────────────────────
                  _AnimatedSection(
                    delay: Duration.zero,
                    child: Masthead(),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // ── 1: KPI Metric Strip ──────────────────────────────────
                  _AnimatedSection(
                    delay: Duration(milliseconds: 100),
                    child: MetricRow(),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // ── 2: Weather | Farm Health | Crop Analytics ────────────
                  _AnimatedSection(
                    delay: Duration(milliseconds: 200),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(flex: 33, child: WeatherWidget()),
                          SizedBox(width: AppSpacing.xl),
                          Flexible(flex: 34, child: FarmHealthOverview()),
                          SizedBox(width: AppSpacing.xl),
                          Flexible(
                            flex: 33,
                            child: _SectionColumn(children: [
                              CropAnalyticsCard(),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // ── 3: Status timeline (full-width) ──────────────────────
                  _AnimatedSection(
                    delay: Duration(milliseconds: 280),
                    child: StatusTimeline(),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // ── 4: Map | Right panel (Needs Attention + Quick Actions)─
                  _AnimatedSection(
                    delay: Duration(milliseconds: 360),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(flex: 56, child: ChoroplethMap()),
                        SizedBox(width: AppSpacing.xl),
                        Flexible(
                          flex: 44,
                          child: _SectionColumn(children: [
                            NeedsAttentionPanel(),
                            SizedBox(height: AppSpacing.xl),
                            _QuickActionsPanel(),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // ── 5: Enrolment timeline (full-width) ───────────────────
                  _AnimatedSection(
                    delay: Duration(milliseconds: 440),
                    child: EnrolmentTimelineChart(),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // ── 6: Distribution | Insights (two-column) ─────────────
                  _AnimatedSection(
                    delay: Duration(milliseconds: 520),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(flex: 60, child: DistributionList()),
                          SizedBox(width: AppSpacing.xl),
                          Flexible(flex: 40, child: _InsightsSummaryPanel()),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.xl),

                  // ── Footer ────────────────────────────────────────────────
                  _AnimatedSection(
                    delay: Duration(milliseconds: 580),
                    child: _FooterBar(),
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAGGERED ENTRANCE ANIMATION
// ─────────────────────────────────────────────────────────────────────────────

/// Wraps any child with a fade + upward-slide entrance animation,
/// triggered after [delay]. Gives the dashboard a staggered 'reveal' feel.
class _AnimatedSection extends StatefulWidget {
  const _AnimatedSection({
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<_AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<_AnimatedSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    if (widget.delay == Duration.zero) {
      _ctrl.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LAYOUT HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionColumn extends StatelessWidget {
  const _SectionColumn({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// QUICK ACTIONS
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QUICK ACTIONS', style: AppTextStyles.sectionHeading),
        SizedBox(height: AppSpacing.md),
        _ActionButton(
          icon: Icons.person_add_outlined,
          label: 'Enrol New Farmer',
          sub: 'Add to Temo Letlotlo',
          color: AppColors.forest700,
        ),
        SizedBox(height: AppSpacing.sm),
        _ActionButton(
          icon: Icons.verified_outlined,
          label: 'Verify Farmer',
          sub: '0 pending verification',
          color: AppColors.forest500,
        ),
        SizedBox(height: AppSpacing.sm),
        _ActionButton(
          icon: Icons.assignment_outlined,
          label: 'Generate Report',
          sub: 'Seasonal overview PDF',
          color: AppColors.gold600,
        ),
        SizedBox(height: AppSpacing.sm),
        _ActionButton(
          icon: Icons.map_outlined,
          label: 'Site Visit Schedule',
          sub: 'Plan district visits',
          color: AppColors.sky400,
        ),
      ],
    );
  }
}

class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String sub;
  final Color color;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.color.withValues(alpha: 0.07)
              : AppColors.cream100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered
                ? widget.color.withValues(alpha: 0.35)
                : const Color(0xFFE5DDD0),
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.forest900.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: widget.color.withValues(
                alpha: _hovered ? 0.16 : 0.10,
              ),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(widget.icon, size: 17, color: widget.color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.label,
                  style: TextStyle(
                    fontFamily: 'Calibri',
                    fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _hovered ? widget.color : AppColors.ink900,
                  )),
              Text(widget.sub,
                  style: const TextStyle(
                    fontFamily: 'Calibri',
                    fontFamilyFallback: ['Liberation Sans', 'sans-serif'],
                    fontSize: 11,
                    color: AppColors.ink500,
                  )),
            ]),
          ),
          AnimatedOpacity(
            opacity: _hovered ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 160),
            child: Icon(Icons.chevron_right, size: 18, color: widget.color),
          ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INSIGHTS SUMMARY PANEL
// ─────────────────────────────────────────────────────────────────────────────

class _InsightsSummaryPanel extends StatelessWidget {
  const _InsightsSummaryPanel();

  static const _insights = [
    _InsightItem(
      category: 'Input Supply',
      text: 'Fertilizer delivery for Mahalapye cohort confirmed for 18 Jul. '
          'Ensure farmers prepare soil before arrival.',
      severity: _Severity.info,
    ),
    _InsightItem(
      category: 'Weather Risk',
      text: 'Forecast shows 48mm of rainfall next week. Early-planted '
          'maize in Serowe may need drainage monitoring.',
      severity: _Severity.warning,
    ),
    _InsightItem(
      category: 'Achievement',
      text: 'All 3 enrolled farmers have completed their crop plan '
          'submissions. 100% programme compliance.',
      severity: _Severity.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PROGRAMME INSIGHTS', style: AppTextStyles.sectionHeading),
        const SizedBox(height: AppSpacing.md),
        for (final insight in _insights) ...[
          _InsightCard(insight: insight),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

enum _Severity { info, warning, success }

class _InsightItem {
  const _InsightItem({
    required this.category,
    required this.text,
    required this.severity,
  });
  final String category;
  final String text;
  final _Severity severity;
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.insight});
  final _InsightItem insight;

  Color get _color => switch (insight.severity) {
        _Severity.info => AppColors.sky400,
        _Severity.warning => AppColors.gold600,
        _Severity.success => AppColors.forest700,
      };

  IconData get _icon => switch (insight.severity) {
        _Severity.info => Icons.info_outline_rounded,
        _Severity.warning => Icons.warning_amber_rounded,
        _Severity.success => Icons.check_circle_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border(left: BorderSide(color: _color, width: 3)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(_icon, size: 16, color: _color),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(insight.category,
                style: TextStyle(
                  fontFamily: 'Calibri',
                  fontFamilyFallback: const ['Liberation Sans', 'sans-serif'],
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _color,
                  letterSpacing: 0.4,
                )),
          ),
          const SizedBox(height: 5),
          Text(insight.text,
              style: AppTextStyles.tableText
                  .copyWith(color: AppColors.ink900, height: 1.45)),
        ])),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOOTER
// ─────────────────────────────────────────────────────────────────────────────

class _FooterBar extends StatelessWidget {
  const _FooterBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold500.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.22)),
      ),
      child: Row(children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.gold500.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.info_outline,
              size: 15, color: AppColors.gold600),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            'All data shown is sample/pilot data (N=3 enrolments, '
            'Temo Letlotlo 2026/27 season). No real farmer data is '
            'displayed. This view updates automatically when live data is wired.',
            style: AppTextStyles.tableText.copyWith(color: AppColors.gold600),
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        const Row(children: [
          _FooterBadge(label: 'AgroEdge v0.1.0'),
          SizedBox(width: AppSpacing.sm),
          _FooterBadge(label: 'Botswana Pilot'),
        ]),
      ]),
    );
  }
}

class _FooterBadge extends StatelessWidget {
  const _FooterBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.forest900.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.forest900.withValues(alpha: 0.12),
        ),
      ),
      child: Text(label,
          style: AppTextStyles.tableText.copyWith(
            fontSize: 10,
            color: AppColors.ink500,
            fontWeight: FontWeight.w600,
          )),
    );
  }
}
