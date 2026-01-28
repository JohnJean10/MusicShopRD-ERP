import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/purchase_order.dart';
import '../widgets/app_theme.dart';

class ProcessPurchaseModal extends ConsumerStatefulWidget {
  final PurchaseOrder order;
  final Function(PurchaseOrder) onSave;

  const ProcessPurchaseModal({
    super.key, 
    required this.order,
    required this.onSave,
  });

  @override
  ConsumerState<ProcessPurchaseModal> createState() => _ProcessPurchaseModalState();
}

class _ProcessPurchaseModalState extends ConsumerState<ProcessPurchaseModal> {
  final _formKey = GlobalKey<FormState>();
  late String? _trackingNumber;
  late String? _notes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _trackingNumber = widget.order.trackingNumber;
    _notes = widget.order.notes;
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      PurchaseOrder updatedOrder = widget.order;
      
      // State transition logic
      if (widget.order.status == PurchaseOrderStatus.pending) {
        // Pending -> Shipped
        updatedOrder = widget.order.copyWith(
          status: PurchaseOrderStatus.shipped,
          trackingNumber: _trackingNumber,
          notes: _notes,
        );
      } else if (widget.order.status == PurchaseOrderStatus.shipped) {
        // Shipped -> Received
        updatedOrder = widget.order.copyWith(
          status: PurchaseOrderStatus.received,
          notes: _notes,
          // Could update actual arrival date here if needed
        );
      } else if (widget.order.status == PurchaseOrderStatus.received) {
         // Received -> ? (Maybe allow editing notes or reverting?)
         // For now, just update notes if changed
         updatedOrder = widget.order.copyWith(
           notes: _notes,
         );
      }

      widget.onSave(updatedOrder);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.order.status;
    String title = 'Procesar Orden';
    String buttonText = 'Guardar';
    Color actionColor = AppColors.blue500;

    if (status == PurchaseOrderStatus.pending) {
      title = 'Marcar como Enviado';
      buttonText = 'Confirmar Envío';
      actionColor = AppColors.blue500;
    } else if (status == PurchaseOrderStatus.shipped) {
      title = 'Recibir Mercancía';
      buttonText = 'Confirmar Recepción';
      actionColor = AppColors.emerald500;
    } else if (status == PurchaseOrderStatus.received) {
      title = 'Detalles de Recepción';
      buttonText = 'Actualizar Notas';
      actionColor = AppColors.slate500;
    }

    return Dialog(
      backgroundColor: AppColors.slate900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Proveedor: ${widget.order.supplierName}',
                style: const TextStyle(color: AppColors.slate400),
              ),
              const SizedBox(height: 24),

              if (status == PurchaseOrderStatus.pending) ...[
                TextFormField(
                  initialValue: _trackingNumber,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Número de Rastreo (Tracking)',
                    labelStyle: TextStyle(color: AppColors.slate400),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.slate700)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.blue500)),
                  ),
                  onSaved: (value) => _trackingNumber = value,
                ),
                const SizedBox(height: 16),
              ],

              if (status == PurchaseOrderStatus.shipped) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.emerald500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.emerald500.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.emerald500),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Al confirmar la recepción, se sumarán ${widget.order.items.fold<int>(0, (p, c) => p + c.quantity)} unidades al inventario automáticamente.',
                          style: const TextStyle(color: AppColors.emerald500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              TextFormField(
                initialValue: _notes,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Notas / Observaciones',
                  labelStyle: TextStyle(color: AppColors.slate400),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.slate700)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.blue500)),
                ),
                maxLines: 2,
                onSaved: (value) => _notes = value,
              ),

              const SizedBox(height: 32),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar', style: TextStyle(color: AppColors.slate400)),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: actionColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(buttonText),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
