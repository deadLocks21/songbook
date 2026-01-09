import 'package:flutter/material.dart';
import 'package:songbook/core/domain/model/sync_diff.dart';

/// Widget affichant un résumé des modifications de synchronisation
class DiffSummary extends StatelessWidget {
  final SyncDiff diff;

  const DiffSummary({super.key, required this.diff});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Icon(Icons.sync, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              _getTitleText(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            _buildStatsRow(),
          ],
        ),
      ),
    );
  }

  String _getTitleText() {
    final count = diff.totalActions;
    if (count == 0) {
      return 'Aucune modification nécessaire';
    } else if (count == 1) {
      return '1 modification détectée';
    } else {
      return '$count modifications détectées';
    }
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(
          icon: Icons.add_circle,
          color: Colors.green,
          label: '${diff.toAdd.length}',
          description: 'à ajouter',
        ),
        _buildStatItem(
          icon: Icons.update,
          color: Colors.orange,
          label: '${diff.toUpdate.length}',
          description: 'à modifier',
        ),
        _buildStatItem(
          icon: Icons.remove_circle,
          color: Colors.red,
          label: '${diff.toDelete.length}',
          description: 'à supprimer',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required String description,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
