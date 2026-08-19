import 'package:flutter/material.dart';
import '../providers/shopping_provider.dart';
import '../theme/app_theme.dart';

class SuggestionCard extends StatelessWidget {
  final SuggestionEntry entry;
  final VoidCallback onAdd;

  const SuggestionCard({super.key, required this.entry, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final item = entry.item;
    final overdue = entry.daysOverdue;

    String subtitle;
    Color badgeColor;
    if (overdue <= 0) {
      subtitle = 'Hora de comprar';
      badgeColor = AppTheme.accent;
    } else if (overdue <= 3) {
      subtitle = 'Atrasado há $overdue dia${overdue == 1 ? '' : 's'}';
      badgeColor = AppTheme.accent;
    } else {
      subtitle = 'Atrasado há $overdue dias';
      badgeColor = AppTheme.danger;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(item.icon, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration:
                            BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton.filled(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
