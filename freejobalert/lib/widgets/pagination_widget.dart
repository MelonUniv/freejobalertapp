import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final bool hasPrevious;
  final bool hasNext;
  final bool isLoading;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const PaginationWidget({
    super.key,
    required this.hasPrevious,
    required this.hasNext,
    required this.isLoading,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show pagination controls if there are no buttons to display
    if (!hasPrevious && !hasNext) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          if (hasPrevious)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: !isLoading ? onPrevious : null,
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Previous'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

          // Spacing
          if (hasPrevious && hasNext) const SizedBox(width: 16),

          // Next Button
          if (hasNext)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: !isLoading ? onNext : null,
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Next'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  disabledForegroundColor: Colors.grey.shade600,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
