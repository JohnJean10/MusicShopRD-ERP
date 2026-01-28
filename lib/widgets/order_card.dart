import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onPrint;
  final VoidCallback onAction;
  final String actionLabel;
  final IconData actionIcon;

  const OrderCard({
    super.key,
    required this.order,
    required this.onPrint,
    required this.onAction,
    required this.actionLabel,
    required this.actionIcon,
  });

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: 'RD\$');
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM d', 'es_DO').format(date);
  }

  Widget _getStatusBadge(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;

    switch (order.status) {
      case OrderStatus.quote:
        bgColor = Colors.blue.withOpacity(0.2);
        textColor = Colors.blue.shade400;
        borderColor = Colors.blue.withOpacity(0.3);
        label = 'INTERESADO';
        break;
      case OrderStatus.pending:
        bgColor = Colors.orange.withOpacity(0.2);
        textColor = Colors.orange.shade400;
        borderColor = Colors.orange.withOpacity(0.3);
        label = 'PREVENTA (50%)';
        break;
      case OrderStatus.ready:
        bgColor = Colors.green.withOpacity(0.2);
        textColor = Colors.green.shade400;
        borderColor = Colors.green.withOpacity(0.3);
        label = 'PAGADO';
        break;
      case OrderStatus.completed:
        bgColor = Colors.grey.withOpacity(0.2);
        textColor = Colors.grey.shade400;
        borderColor = Colors.grey.withOpacity(0.3);
        label = 'COMPLETADO';
        break;
      case OrderStatus.cancelled:
        bgColor = Colors.red.withOpacity(0.2);
        textColor = Colors.red.shade400;
        borderColor = Colors.red.withOpacity(0.3);
        label = 'CANCELADO';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and print button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.id.substring(0, order.id.length > 12 ? 12 : order.id.length),
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onPrint,
                icon: const Icon(Icons.print, size: 18),
                color: Colors.grey.shade400,
                tooltip: 'Imprimir PDF',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Status badge
          _getStatusBadge(context),
          const SizedBox(height: 12),
          
          // Amount and date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatCurrency(order.total),
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(order.date),
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAction,
              icon: Icon(actionIcon, size: 16),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF334155),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
