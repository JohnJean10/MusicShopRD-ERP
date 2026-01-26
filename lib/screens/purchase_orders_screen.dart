import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/purchase_order.dart';
import '../providers/app_providers.dart';
import '../widgets/app_theme.dart';
import '../widgets/create_purchase_order_modal.dart';

class PurchaseOrdersScreen extends ConsumerStatefulWidget {
  const PurchaseOrdersScreen({super.key});

  @override
  ConsumerState<PurchaseOrdersScreen> createState() => _PurchaseOrdersScreenState();
}

class _PurchaseOrdersScreenState extends ConsumerState<PurchaseOrdersScreen> {
  String _searchTerm = '';

  @override
  Widget build(BuildContext context) {
    final purchaseOrders = ref.watch(purchaseOrderProvider);
    
    // Filter logic
    final filteredOrders = purchaseOrders.where((o) =>
      o.supplierName.toLowerCase().contains(_searchTerm.toLowerCase()) ||
      o.items.any((i) => i.name.toLowerCase().contains(_searchTerm.toLowerCase()))
    ).toList();
    
    // Sort logic: Pending first, then by date descending
    filteredOrders.sort((a, b) {
      if (a.status == PurchaseOrderStatus.pending && b.status != PurchaseOrderStatus.pending) return -1;
      if (a.status != PurchaseOrderStatus.pending && b.status == PurchaseOrderStatus.pending) return 1;
      return b.date.compareTo(a.date);
    });

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Órdenes de Compra',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Padding(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: const CreatePurchaseOrderModal(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Search Bar
          TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Buscar por proveedor o producto...',
              hintStyle: const TextStyle(color: AppColors.slate500),
              prefixIcon: const Icon(Icons.search, color: AppColors.slate500),
              filled: true,
              fillColor: AppColors.slate800,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (val) => setState(() => _searchTerm = val),
          ),
          const SizedBox(height: 24),
          
          Expanded(
            child: filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined, 
                        size: 64, 
                        color: AppColors.slate600.withValues(alpha: 0.5)
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No hay órdenes de compra registradas',
                        style: TextStyle(color: AppColors.slate500),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _PurchaseOrderCard(order: order);
                  },
                ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseOrderCard extends StatelessWidget {
  final PurchaseOrder order;

  const _PurchaseOrderCard({required this.order});

  Color _getStatusColor(PurchaseOrderStatus status) {
    switch (status) {
      case PurchaseOrderStatus.pending: return AppColors.orange500;
      case PurchaseOrderStatus.shipped: return AppColors.blue500;
      case PurchaseOrderStatus.received: return AppColors.emerald500;
      case PurchaseOrderStatus.cancelled: return AppColors.red500;
    }
  }
  
  String _getStatusLabel(PurchaseOrderStatus status) {
    switch (status) {
      case PurchaseOrderStatus.pending: return 'Pendiente';
      case PurchaseOrderStatus.shipped: return 'En Tránsito';
      case PurchaseOrderStatus.received: return 'Recibido';
      case PurchaseOrderStatus.cancelled: return 'Cancelado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate700),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.business, color: AppColors.slate400, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    order.supplierName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getStatusColor(order.status).withValues(alpha: 0.5)),
                ),
                child: Text(
                  _getStatusLabel(order.status),
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.slate700),
          const SizedBox(height: 12),
          Text(
            '${order.items.length} productos · Total: US\$${order.totalUsd.toStringAsFixed(2)}',
            style: const TextStyle(color: AppColors.slate300),
          ),
          const SizedBox(height: 4),
          Text(
            'Fecha: ${DateFormat('dd/MM/yyyy').format(order.date)}',
            style: const TextStyle(color: AppColors.slate500, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
