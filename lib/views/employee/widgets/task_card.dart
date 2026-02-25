import 'package:flutter/material.dart';
import '../../../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onSimplify;
  final VoidCallback? onFocusMode;
  final VoidCallback? onSubmitProof;

  const TaskCard({
    super.key,
    required this.task,
    this.onSimplify,
    this.onFocusMode,
    this.onSubmitProof,
  });

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return const Color(0xFFDF3F3F);
      case TaskPriority.important:
        return const Color(0xFFE3B71B);
      case TaskPriority.normal:
        return const Color(0xFF19B889);
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return 'Urgent';
      case TaskPriority.important:
        return 'Important';
      case TaskPriority.normal:
        return 'Normal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _getPriorityColor(task.priority);
    final statusDotColor = priorityColor;
    return Stack(
      children: [
        Positioned(
          left: 0,
          top: 10,
          bottom: 10,
          child: Container(
            width: 4,
            decoration: BoxDecoration(
              color: priorityColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD8DDE6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF15283B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusDotColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 15,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Due ${_formatDate(task.dueDate)}',
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: priorityColor, width: 1.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _getPriorityLabel(task.priority),
                      style: TextStyle(
                        color: priorityColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                task.description,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.25,
                  color: Color(0xFF6B7280),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.status,
                  style: const TextStyle(
                    color: Color(0xFF2A3D3A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildActionButton(
                icon: Icons.auto_awesome_outlined,
                label: 'Simplify with AI',
                onPressed: onSimplify,
              ),
              const SizedBox(height: 10),
              _buildActionButton(
                icon: Icons.center_focus_strong,
                label: 'Focus Mode',
                onPressed: onFocusMode,
              ),
              const SizedBox(height: 10),
              _buildActionButton(
                icon: Icons.upload_outlined,
                label: 'Submit Proof',
                onPressed: onSubmitProof,
                isPrimary: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isPrimary ? const Color(0xFF2F80ED) : const Color(0xFFD1D5DB),
          ),
          backgroundColor: isPrimary ? const Color(0xFF2F80ED) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        icon: Icon(
          icon,
          size: 18,
          color: isPrimary ? Colors.white : const Color(0xFF1F2937),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isPrimary ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
