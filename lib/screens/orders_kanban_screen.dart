import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order.dart';
import '../providers/app_providers.dart';
import '../widgets/kanban_column.dart';
import '../widgets/create_order_modal.dart';
import '../services/export_service.dart';

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
    OrderStatus newStatus;
    switch (order.status) {
      case OrderStatus.quote:
        newStatus = OrderStatus.pending;
        break;
      case OrderStatus.pending:
        newStatus = OrderStatus.ready;
        break;
      case OrderStatus.ready:
        newStatus = OrderStatus.completed;
        break;
      default:
        return;
    }
    
    final updatedOrder = order.copyWith(status: newStatus);
    ref.read(orderProvider.notifier).updateOrder(updatedOrder);
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
      backgroundColor: const Color(0xFF0F172A),
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
                    color: Color(0xFF10B981),
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
                        backgroundColor: Colors.blue.shade600,
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
                        backgroundColor: const Color(0xFF10B981),
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
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF10B981)),
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Kanban Board
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    KanbanColumn(
                      title: 'PROSPECTOS / INTERESADOS',
                      orders: prospectsOrders,
                      accentColor: Colors.blue,
                      emptyMessage: 'Sin cotizaciones',
                      onPrint: _handlePrint,
                      onAction: _handleAction,
                      getActionLabel: _getActionLabel,
                      getActionIcon: _getActionIcon,
                    ),
                    KanbanColumn(
                      title: 'EN PROCESO / PAGADOS',
                      orders: inProgressOrders,
                      accentColor: Colors.orange,
                      emptyMessage: 'Sin pedidos en proceso',
                      onPrint: _handlePrint,
                      onAction: _handleAction,
                      getActionLabel: _getActionLabel,
                      getActionIcon: _getActionIcon,
                    ),
                    KanbanColumn(
                      title: 'FINALIZADOS',
                      orders: completedOrders,
                      accentColor: Colors.green,
                      emptyMessage: 'Sin pedidos finalizados',
                      onPrint: _handlePrint,
                      onAction: _handleAction,
                      getActionLabel: _getActionLabel,
                      getActionIcon: _getActionIcon,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
