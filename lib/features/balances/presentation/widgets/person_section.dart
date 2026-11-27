import 'package:material_ui/material_ui.dart';

import '../../domain/balances_overview.dart';
import 'balances_card.dart';
import 'person_row.dart';
import 'section_label.dart';
import 'staggered_entry.dart';

/// "TE DEBEN · 3" or "DEBES · 2" and a card with their rows, which enter
/// in cascade starting at [firstIndex].
class PersonSection extends StatelessWidget {
  const PersonSection({
    super.key,
    required this.label,
    required this.people,
    required this.isAllGroups,
    required this.groupNames,
    required this.onOpen,
    this.firstIndex = 0,
  });

  final String label;
  final List<PersonBalance> people;
  final bool isAllGroups;
  final Map<String, String> groupNames;
  final ValueChanged<PersonBalance> onOpen;
  final int firstIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(label),
        BalancesCard(
          children: [
            for (var i = 0; i < people.length; i++)
              StaggeredEntry(
                key: ValueKey(people[i].uid),
                index: firstIndex + i,
                child: PersonRow(
                  person: people[i],
                  isAllGroups: isAllGroups,
                  groupNames: groupNames,
                  onTap: () => onOpen(people[i]),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
