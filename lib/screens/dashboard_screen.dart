import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../models/purchase_order.dart';
import '../providers/app_providers.dart';
import '../widgets/app_theme.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  String _formatCurrency(double amount, {bool isUsd = false}) {
    return NumberFormat.currency(
      locale: 'es_DO', 
      symbol: isUsd ? 'US\$' : 'RD\$'
    ).format(amount);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderProvider);
    final purchaseOrders = ref.watch(purchaseOrderProvider);
    
    // KPI Calculations
    // 1. Ventas Abiertas (Quotes)
    final quotes = orders.where((o) => o.status == OrderStatus.quote).toList();
    final quotesTotal = quotes.fold(0.0, (sum, o) => sum + o.total);

    // 2. Ventas Pendientes (Confirmed/Pending Payment or Delivery)
    final pendingSales = orders.where((o) => 
      o.status == OrderStatus.pending || o.status == OrderStatus.ready
    ).toList();
    final pendingSalesTotal = pendingSales.fold(0.0, (sum, o) => sum + o.total);

    // 3. Ventas Cerradas (Completed)
    final closedSales = orders.where((o) => o.status == OrderStatus.completed).toList();
    final closedSalesTotal = closedSales.fold(0.0, (sum, o) => sum + o.total);

    // 4. Compras en Transito (Pending/Shipped Purchase Orders)
    final activePurchases = purchaseOrders.where((o) => 
      o.status == PurchaseOrderStatus.pending || o.status == PurchaseOrderStatus.shipped
    ).toList();
    final activePurchasesTotal = activePurchases.fold(0.0, (sum, o) => sum + o.totalUsd);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cuadrante de Mando',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Visión general del ciclo de efectivo',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.slate400,
            ),
          ),
          const SizedBox(height: 32),

          // Quadrant Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              final double cardRatio = isWide ? 1.5 : 1.3;
              
              return GridView.count(
                crossAxisCount: isWide ? 2 : 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: isWide ? 2.5 : 1.8,
                children: [
                   // 1. Ventas Abiertas (Blue)
                  _buildKpiCard(
                    title: 'Ventas Abiertas',
                    subtitle: 'Prospectos / Cotizaciones',
                    count: quotes.length,
                    amount: _formatCurrency(quotesTotal),
                    color: AppColors.blue500,
                    icon: Icons.pending_actions,
                    onTap: () {
                      // Navigate to Quotes tab
                    },
                  ),

                  // 2. Ventas Pendientes (Orange)
                  _buildKpiCard(
                    title: 'Ventas Pendientes',
                    subtitle: 'Por Cobrar / Entregar',
                    count: pendingSales.length,
                    amount: _formatCurrency(pendingSalesTotal),
                    color: AppColors.orange500,
                    icon: Icons.hourglass_top,
                    onTap: () {
                      // Navigate to Pending Orders
                    },
                  ),

                  // 3. Ventas Cerradas (Green)
                  _buildKpiCard(
                    title: 'Ventas Cerradas',
                    subtitle: 'Dinero en Banco',
                    count: closedSales.length,
                    amount: _formatCurrency(closedSalesTotal),
                    color: AppColors.emerald500,
                    icon: Icons.check_circle_outline,
                    onTap: () {
                      // Navigate to History
                    },
                  ),

                  // 4. Ordenes de Compra (Purple)
                  _buildKpiCard(
                    title: 'Órdenes de Compra',
                    subtitle: 'Mercancía en Camino',
                    count: activePurchases.length,
                    amount: _formatCurrency(activePurchasesTotal, isUsd: true),
                    color: AppColors.purple500,
                    icon: Icons.local_shipping_outlined,
                    onTap: () {
                      // Navigate to Purchase Orders
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String subtitle,
    required int count,
    required String amount,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate800,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slate700),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              // Background accent
              Positioned(
                right: -20,
                top: -20,
                child: Icon(
                  icon,
                  size: 140,
                  color: color.withValues(alpha: 0.05),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.slate400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$count Órdenes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: color.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          amount,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Bottom bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 4,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

