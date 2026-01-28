import 'package:flutter/material.dart';
import '../models/order.dart';
import 'app_theme.dart';

class ProcessOrderModal extends StatefulWidget {
  final Order order;
  final Function(String paymentMethod, DateTime? date) onConfirm;
  final bool isPayment; // true = confirming payment, false = confirming delivery

  const ProcessOrderModal({
    super.key,
    required this.order,
    required this.onConfirm,
    this.isPayment = true,
  });

  @override
  State<ProcessOrderModal> createState() => _ProcessOrderModalState();
}

class _ProcessOrderModalState extends State<ProcessOrderModal> {
  String _selectedMethod = 'Efectivo';
  final List<String> _paymentMethods = [
    'Efectivo',
    'Transferencia BHD',
    'Transferencia Popular',
    'Banreservas',
    'Tarjeta de Crédito',
    'PayPal',
    'Cheque'
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.slate900,
      title: Text(
        widget.isPayment ? 'Confirmar Pago' : 'Confirmar Entrega',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.isPayment) ...[
             const Text(
              'Seleccione el método de pago:',
              style: TextStyle(color: AppColors.slate400),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.slate800,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.slate700),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedMethod,
                  isExpanded: true,
                  dropdownColor: AppColors.slate800,
                  style: const TextStyle(color: Colors.white),
                  items: _paymentMethods.map((m) {
                    return DropdownMenuItem(value: m, child: Text(m));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMethod = val);
                  },
                ),
              ),
            ),
          ] else ...[
             const Text(
              '¿Confirma que el pedido ha sido entregado al cliente?',
              style: TextStyle(color: AppColors.slate300),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.slate400)),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onConfirm(_selectedMethod, DateTime.now());
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.emerald500,
          ),
          child: Text(widget.isPayment ? 'Confirmar Pago' : 'Confirmar Entrega'),
        ),
      ],
    );
  }
}
