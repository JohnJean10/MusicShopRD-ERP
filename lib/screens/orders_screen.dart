import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../widgets/app_theme.dart';
import '../widgets/create_order_modal.dart';
import '../services/export_service.dart';

class OrdersScreen extends StatefulWidget {
  final List<Order> orders;
  final List<Product> products;
  final Function(Order) onCreateOrder;
  final Function(Order) onUpdateOrder;
  final Function(String) onDeleteOrder;

  const OrdersScreen({
    super.key,
    required this.orders,
    required this.products,
    required this.onCreateOrder,
    required this.onUpdateOrder,
    required this.onDeleteOrder,
  });

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

enum _TabType { quotes, active, history }

class _OrdersScreenState extends State<OrdersScreen> {
  _TabType _activeTab = _TabType.active;
  String _searchTerm = '';

  List<Order> get _filteredOrders {
    return widget.orders.where((o) {
      final matchesSearch = o.customerName.toLowerCase().contains(_searchTerm.toLowerCase()) ||
                            o.id.toLowerCase().contains(_searchTerm.toLowerCase());
      if (!matchesSearch) return false;

      switch (_activeTab) {
        case _TabType.quotes:
          return o.status == OrderStatus.quote;
        case _TabType.active:
          return o.status == OrderStatus.pending || o.status == OrderStatus.ready;
        case _TabType.history:
          return o.status == OrderStatus.completed || o.status == OrderStatus.cancelled;
      }
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$').format(amount);
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMM', 'es').format(date);
  }

  void _showCreateModal({bool isQuote = false}) {
    showDialog(
      context: context,
      builder: (context) => CreateOrderModal(
        products: widget.products,
        onSave: widget.onCreateOrder,
        isQuote: isQuote,
      ),
    );
  }

  void _handleStatusChange(Order order, OrderStatus newStatus) {
    widget.onUpdateOrder(order.copyWith(status: newStatus));
  }

  void _confirmDelete(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Pedido'),
        content: const Text('¿Eliminar historial de este pedido? El stock NO será afectado.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () {
              widget.onDeleteOrder(order.id);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    String label;

    switch (status) {
      case OrderStatus.quote:
        bgColor = AppColors.blue500.withValues(alpha: 0.1);
        textColor = AppColors.blue400;
        borderColor = AppColors.blue500.withValues(alpha: 0.2);
        label = 'Cotización';
        break;
      case OrderStatus.pending:
        bgColor = AppColors.orange500.withValues(alpha: 0.1);
        textColor = AppColors.orange400;
        borderColor = AppColors.orange500.withValues(alpha: 0.2);
        label = 'Pendiente';
        break;
      case OrderStatus.ready:
        bgColor = AppColors.yellow500.withValues(alpha: 0.1);
        textColor = AppColors.yellow400;
        borderColor = AppColors.yellow500.withValues(alpha: 0.2);
        label = 'Listo Entrega';
        break;
      case OrderStatus.completed:
        bgColor = AppColors.emerald500.withValues(alpha: 0.1);
        textColor = AppColors.emerald400;
        borderColor = AppColors.emerald500.withValues(alpha: 0.2);
        label = 'Completado';
        break;
      case OrderStatus.cancelled:
        bgColor = AppColors.red500.withValues(alpha: 0.1);
        textColor = AppColors.red400;
        borderColor = AppColors.red500.withValues(alpha: 0.2);
        label = 'Cancelado';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAlertMessage(Order order) {
    switch (order.status) {
      case OrderStatus.quote:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule, size: 14, color: AppColors.blue400),
            SizedBox(width: 4),
            Text('Seguimiento', style: TextStyle(color: AppColors.blue400, fontSize: 12)),
          ],
        );
      case OrderStatus.pending:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 14, color: AppColors.orange400),
            SizedBox(width: 4),
            Text('Falta Pago', style: TextStyle(color: AppColors.orange400, fontSize: 12)),
          ],
        );
      case OrderStatus.ready:
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 14, color: AppColors.yellow400),
            SizedBox(width: 4),
            Text('Coordinar', style: TextStyle(color: AppColors.yellow400, fontSize: 12)),
          ],
        );
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return Text(
          order.status == OrderStatus.completed ? 'Finalizado' : 'Cerrado',
          style: const TextStyle(color: AppColors.slate500, fontSize: 11),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Control de Pedidos',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emerald400,
                    ),
                  ),
                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.request_quote,
                        label: 'Cotizar',
                        color: AppColors.blue500,
                        onTap: () => _showCreateModal(isQuote: true),
                      ),
                      const SizedBox(width: 8),
                      _ActionButton(
                        icon: Icons.add,
                        label: 'Pedido',
                        color: AppColors.emerald600,
                        onTap: () => _showCreateModal(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.slate800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TabButton(
                      label: 'Cotizaciones',
                      isActive: _activeTab == _TabType.quotes,
                      onTap: () => setState(() => _activeTab = _TabType.quotes),
                    ),
                    _TabButton(
                      label: 'En Proceso',
                      isActive: _activeTab == _TabType.active,
                      onTap: () => setState(() => _activeTab = _TabType.active),
                    ),
                    _TabButton(
                      label: 'Histórico',
                      isActive: _activeTab == _TabType.history,
                      onTap: () => setState(() => _activeTab = _TabType.history),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _searchTerm = v),
                decoration: InputDecoration(
                  hintText: 'Buscar cliente, ID...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
                  filled: true,
                  fillColor: AppColors.slate800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slate700),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Orders List
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate700),
            ),
            clipBehavior: Clip.antiAlias,
            child: _filteredOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.filter_list, size: 48, color: AppColors.slate600.withValues(alpha: 0.3)),
                      const SizedBox(height: 8),
                      const Text('No hay pedidos en esta vista.', style: TextStyle(color: AppColors.slate500)),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _filteredOrders.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.slate700),
                  itemBuilder: (context, index) {
                    final order = _filteredOrders[index];
                    
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order.customerName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  '#${order.id.substring(0, 8)}',
                                  style: const TextStyle(color: AppColors.slate500, fontSize: 11, fontFamily: 'monospace'),
                                ),
                                Text(
                                  _formatDate(order.date),
                                  style: const TextStyle(color: AppColors.slate400, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: _buildStatusBadge(order.status)),
                          Expanded(child: _buildAlertMessage(order)),
                          Expanded(
                            child: Text(
                              _formatCurrency(order.total),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: AppColors.emerald400,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildActionButtons(order),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Order order) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SmallActionButton(
           icon: Icons.print,
           color: AppColors.slate400,
           tooltip: 'Imprimir PDF',
           onTap: () => ExportService.generateOrderPdf(order, order.status == OrderStatus.quote),
         ),
        if (order.status == OrderStatus.quote)
          _SmallActionButton(
            icon: Icons.check_circle,
            color: AppColors.emerald500,
            tooltip: 'Confirmar Pedido',
            onTap: () => _handleStatusChange(order, OrderStatus.pending),
          ),
        if (order.status == OrderStatus.pending)
          _SmallActionButton(
            icon: Icons.arrow_forward,
            color: AppColors.yellow500,
            tooltip: 'Marcar Listo',
            onTap: () => _handleStatusChange(order, OrderStatus.ready),
          ),
        if (order.status == OrderStatus.ready)
          _SmallActionButton(
            icon: Icons.check_circle,
            color: AppColors.blue500,
            tooltip: 'Entregar',
            onTap: () => _handleStatusChange(order, OrderStatus.completed),
          ),
        if (order.status != OrderStatus.completed && order.status != OrderStatus.cancelled)
          _SmallActionButton(
            icon: Icons.cancel,
            color: AppColors.red500,
            tooltip: 'Cancelar',
            onTap: () => _handleStatusChange(order, OrderStatus.cancelled),
          ),
        _SmallActionButton(
          icon: Icons.delete_outline,
          color: AppColors.slate500,
          tooltip: 'Eliminar',
          onTap: () => _confirmDelete(order),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.slate700 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.slate400,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withValues(alpha: 0.2), // Background is faint color
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: color.withValues(alpha: 0.1), // Hover effect
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 16, color: color), // Icon uses the main color
          ),
        ),
      ),
    );
  }
}
