import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../services/export_service.dart';
import 'app_theme.dart';

class OrderDetailsModal extends StatelessWidget {
  final Order order;

  const OrderDetailsModal({super.key, required this.order});

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: 'RD\$').format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return DateFormat('dd/MM/yyyy h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 600,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.slate900,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Detalles del Pedido',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => ExportService.generateOrderPdf(
                      order, 
                      order.status.name == 'quote'
                    ),
                    icon: const Icon(Icons.print, color: Colors.blue),
                    tooltip: 'Imprimir',
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Customer info
          _buildSectionTitle('Cliente'),
          Text(
            order.customerName,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            'ID: ${order.id}',
            style: TextStyle(fontSize: 14, color: AppColors.slate400),
          ),
          const SizedBox(height: 24),

          // Timeline
          _buildSectionTitle('Historial'),
          _buildTimelineRow('Creado', _formatDate(order.date), Icons.create),
          _buildTimelineRow('Pagado', _formatDate(order.paymentDate), Icons.payment),
          _buildTimelineRow('Entregado', _formatDate(order.deliveryDate), Icons.local_shipping),
          if (order.paymentMethod != null)
             Padding(
               padding: const EdgeInsets.only(top: 8.0),
               child: _buildTimelineRow('Método de Pago', order.paymentMethod!, Icons.credit_card),
             ),
          
          const SizedBox(height: 24),

          // Items
          _buildSectionTitle('Productos'),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.slate700),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: order.items.map((item) => ListTile(
                title: Text(item.name, style: const TextStyle(color: Colors.white)),
                subtitle: Text(item.sku, style: TextStyle(color: AppColors.slate400)),
                trailing: Text(
                  '${item.quantity} x ${_formatCurrency(item.price)}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 16),
          
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: ${_formatCurrency(order.total)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.emerald400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: AppColors.slate400,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTimelineRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.slate500),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(color: AppColors.slate400),
            ),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
