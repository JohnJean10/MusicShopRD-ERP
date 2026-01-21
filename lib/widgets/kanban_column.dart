import 'package:flutter/material.dart';
import '../models/order.dart';
import 'order_card.dart';

class KanbanColumn extends StatelessWidget {
  final String title;
  final List<Order> orders;
  final Color accentColor;
  final String emptyMessage;
  final Function(Order) onPrint;
  final Function(Order) onAction;
  final String Function(Order) getActionLabel;
  final IconData Function(Order) getActionIcon;

  const KanbanColumn({
    super.key,
    required this.title,
    required this.orders,
    required this.accentColor,
    required this.emptyMessage,
    required this.onPrint,
    required this.onAction,
    required this.getActionLabel,
    required this.getActionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 340,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  border: Border.all(color: accentColor.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${orders.length}',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Column content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: orders.isEmpty
                  ? Center(
                      child: Text(
                        emptyMessage,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        return OrderCard(
                          order: order,
                          onPrint: () => onPrint(order),
                          onAction: () => onAction(order),
                          actionLabel: getActionLabel(order),
                          actionIcon: getActionIcon(order),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
