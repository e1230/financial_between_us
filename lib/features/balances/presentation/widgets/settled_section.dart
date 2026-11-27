import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/balances_overview.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import 'balances_card.dart';
import 'person_row.dart';
import 'section_label.dart';

/// "A PAZ Y SALVO · N": collapsed by default. Its toggle row (a shield in a
/// 40 dp circle and a chevron that turns 180°) opens the people with
/// nothing pending, dimmed, and a footnote.
class SettledSection extends StatefulWidget {
  const SettledSection({
    super.key,
    required this.people,
    required this.scopeName,
    required this.isAllGroups,
    required this.groupNames,
    required this.onOpen,
  });

  final List<PersonBalance> people;
  final String scopeName;
  final bool isAllGroups;
  final Map<String, String> groupNames;
  final ValueChanged<PersonBalance> onOpen;

  @override
  State<SettledSection> createState() => _SettledSectionState();
}

class _SettledSectionState extends State<SettledSection> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final fade = reduceMotion
        ? BalancesMetrics.reducedFade
        : BalancesMetrics.settledFade;

    final toggle = Semantics(
      button: true,
      expanded: _open,
      child: InkWell(
        onTap: () => setState(() => _open = !_open),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: BalancesMetrics.rowMinHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: BalancesMetrics.rowPaddingH,
              vertical: BalancesMetrics.rowPaddingV,
            ),
            child: Row(
              children: [
                Container(
                  width: BalancesMetrics.avatar,
                  height: BalancesMetrics.avatar,
                  decoration: BoxDecoration(
                    color: tokens.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_user_outlined,
                    size: BalancesMetrics.shieldIcon,
                    color: tokens.textPrimary,
                  ),
                ),
                const SizedBox(width: BalancesMetrics.rowGap),
                Expanded(
                  child: Text(
                    _open
                        ? BalancesStrings.hide
                        : BalancesStrings.settledToggle,
                    style: styles.rowTitle,
                  ),
                ),
                AnimatedRotation(
                  turns: _open ? 0.5 : 0,
                  duration: reduceMotion
                      ? Duration.zero
                      : BalancesMetrics.chevronTurn,
                  child: Icon(
                    Icons.expand_more,
                    size: BalancesMetrics.chevronSize,
                    color: tokens.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(BalancesStrings.settledSection(widget.people.length)),
        AnimatedSize(
          duration: reduceMotion
              ? BalancesMetrics.reducedFade
              : BalancesMetrics.settledResize,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: BalancesCard(
            children: [
              toggle,
              if (_open)
                for (final person in widget.people)
                  _FadeIn(
                    key: ValueKey(person.uid),
                    duration: fade,
                    child: Opacity(
                      opacity: BalancesMetrics.settledOpacity,
                      child: PersonRow(
                        person: person,
                        isAllGroups: widget.isAllGroups,
                        groupNames: widget.groupNames,
                        onTap: () => widget.onOpen(person),
                      ),
                    ),
                  ),
            ],
          ),
        ),
        if (_open)
          Padding(
            padding: EdgeInsets.fromLTRB(
              BalancesMetrics.sectionLabelPaddingH,
              tokens.space1,
              BalancesMetrics.sectionLabelPaddingH,
              0,
            ),
            child: Text(
              BalancesStrings.settledFootnote(widget.scopeName),
              style: styles.body,
            ),
          ),
      ],
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn({super.key, required this.duration, required this.child});

  final Duration duration;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: duration,
    builder: (context, value, child) => Opacity(opacity: value, child: child),
    child: child,
  );
}
