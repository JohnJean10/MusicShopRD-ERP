import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../providers/app_providers.dart';
import '../widgets/kanban_column.dart';
import '../widgets/create_order_modal.dart';
import '../widgets/order_details_modal.dart';
import '../widgets/process_order_modal.dart';
import '../services/export_service.dart';
import '../widgets/app_theme.dart';

class OrdersKanbanScreen extends ConsumerStatefulWidget {
  const OrdersKanbanScreen({super.key});

  @override
  ConsumerState<OrdersKanbanScreen> createState() => _OrdersKanbanScreenState();
}

class _OrdersKanbanScreenState extends ConsumerState<OrdersKanbanScreen> {
  String _searchTerm = '';

  String _getActionLabel(Order order) {
    switch (order.status) {
      case OrderStatus.quote:
        return 'Dar seguimiento';
      case OrderStatus.pending:
        return 'Confirmar llegada';
      case OrderStatus.ready:
        return 'Preparar envío';
      default:
        return 'Ver detalles';
    }
  }

  IconData _getActionIcon(Order order) {
    switch (order.status) {
      case OrderStatus.quote:
        return Icons.schedule;
      case OrderStatus.pending:
        return Icons.check_circle_outline;
      case OrderStatus.ready:
        return Icons.local_shipping_outlined;
      default:
        return Icons.print;
    }
  }

  void _handleAction(Order order) {
    // 1. View Details (Completed or Cancelled)
    if (order.status == OrderStatus.completed || order.status == OrderStatus.cancelled) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: OrderDetailsModal(order: order),
        ),
      );
      return;
    }

    // 2. Process Order (State Transitions)
    if (order.status == OrderStatus.pending) {
       // Pending -> Ready (Confirmar llegada/Pago)
       showDialog(
         context: context,
         builder: (context) => ProcessOrderModal(
           order: order,
           isPayment: true,
           onConfirm: (method, date) {
             final updated = order.copyWith(
               status: OrderStatus.ready,
               paymentMethod: method,
               paymentDate: date,
             );
             ref.read(orderProvider.notifier).updateOrder(updated);
           },
         ),
       );
    } else if (order.status == OrderStatus.ready) {
      // Ready -> Completed (Confirmar entrega)
       showDialog(
         context: context,
         builder: (context) => ProcessOrderModal(
           order: order,
           isPayment: false,
           onConfirm: (_, date) {
             final updated = order.copyWith(
               status: OrderStatus.completed,
               deliveryDate: date,
             );
             ref.read(orderProvider.notifier).updateOrder(updated);
           },
         ),
       );
    } else if (order.status == OrderStatus.quote) {
      // Quote -> Pending (Start process)
        final updated = order.copyWith(status: OrderStatus.pending);
        ref.read(orderProvider.notifier).updateOrder(updated);
    }
  }

  void _handlePrint(Order order) {
    final isQuote = order.status == OrderStatus.quote;
    ExportService.generateOrderPdf(order, isQuote);
  }

  void _openCreateModal(bool isQuote) {
    final products = ref.read(productProvider);
    showDialog(
      context: context,
      builder: (context) => CreateOrderModal(
        isQuote: isQuote,
        products: products,
        onSave: (order) {
          ref.read(orderProvider.notifier).addOrder(order);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders = ref.watch(orderProvider);
    
    final filteredOrders = orders.where((o) {
      final searchLower = _searchTerm.toLowerCase();
      return o.customerName.toLowerCase().contains(searchLower) ||
             o.id.toLowerCase().contains(searchLower);
    }).toList();

    final prospectsOrders = filteredOrders
        .where((o) => o.status == OrderStatus.quote)
        .toList();
    
    final inProgressOrders = filteredOrders
        .where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.ready)
        .toList();
    
    final completedOrders = filteredOrders
        .where((o) => o.status == OrderStatus.completed || o.status == OrderStatus.cancelled)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.slate900,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tablero de Pedidos',
                  style: TextStyle(
                    color: AppColors.emerald500,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _openCreateModal(true),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nueva Cotización'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.blue500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _openCreateModal(false),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Nuevo Pedido'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search
            SizedBox(
              width: 400,
              child: TextField(
                onChanged: (value) => setState(() => _searchTerm = value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Buscar cliente o ID...',
                  hintStyle: const TextStyle(color: AppColors.slate500),
                  filled: true,
                  fillColor: AppColors.slate800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.slate700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.slate700),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.emerald500),
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Kanban Board
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 1100;

                  if (isDesktop) {
                    // Desktop: Full width columns, no scrolling
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: KanbanColumn(
                            title: 'PROSPECTOS / INTERESADOS',
                            orders: prospectsOrders,
                            accentColor: Colors.blue,
                            emptyMessage: 'Sin cotizaciones',
                            onPrint: _handlePrint,
                            onAction: _handleAction,
                            getActionLabel: _getActionLabel,
                            getActionIcon: _getActionIcon,
                          ),
                        ),
                        Expanded(
                          child: KanbanColumn(
                            title: 'EN PROCESO / PAGADOS',
                            orders: inProgressOrders,
                            accentColor: Colors.orange,
                            emptyMessage: 'Sin pedidos en proceso',
                            onPrint: _handlePrint,
                            onAction: _handleAction,
                            getActionLabel: _getActionLabel,
                            getActionIcon: _getActionIcon,
                          ),
                        ),
                        Expanded(
                          child: KanbanColumn(
                            title: 'FINALIZADOS',
                            orders: completedOrders,
                            accentColor: Colors.green,
                            emptyMessage: 'Sin pedidos finalizados',
                            onPrint: _handlePrint,
                            onAction: _handleAction,
                            getActionLabel: _getActionLabel,
                            getActionIcon: _getActionIcon,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Mobile/Tablet: Horizontal scroll with fixed width columns
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 340,
                            child: KanbanColumn(
                              title: 'PROSPECTOS / INTERESADOS',
                              orders: prospectsOrders,
                              accentColor: Colors.blue,
                              emptyMessage: 'Sin cotizaciones',
                              onPrint: _handlePrint,
                              onAction: _handleAction,
                              getActionLabel: _getActionLabel,
                              getActionIcon: _getActionIcon,
                            ),
                          ),
                          SizedBox(
                            width: 340,
                            child: KanbanColumn(
                              title: 'EN PROCESO / PAGADOS',
                              orders: inProgressOrders,
                              accentColor: Colors.orange,
                              emptyMessage: 'Sin pedidos en proceso',
                              onPrint: _handlePrint,
                              onAction: _handleAction,
                              getActionLabel: _getActionLabel,
                              getActionIcon: _getActionIcon,
                            ),
                          ),
                          SizedBox(
                            width: 340,
                            child: KanbanColumn(
                              title: 'FINALIZADOS',
                              orders: completedOrders,
                              accentColor: Colors.green,
                              emptyMessage: 'Sin pedidos finalizados',
                              onPrint: _handlePrint,
                              onAction: _handleAction,
                              getActionLabel: _getActionLabel,
                              getActionIcon: _getActionIcon,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
