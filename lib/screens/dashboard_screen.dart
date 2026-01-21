import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/app_theme.dart';
import '../widgets/metric_card.dart';

class DashboardScreen extends StatelessWidget {
  final List<Product> products;
  
  const DashboardScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final lowStockProducts = products.where((p) => p.stock <= p.minStock).toList();
    final totalStock = products.fold<int>(0, (sum, p) => sum + p.stock);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.emerald400,
            ),
          ),
          const SizedBox(height: 20),

          // Metrics Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 500;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Alertas de Stock',
                        value: '${lowStockProducts.length}',
                        subtitle: 'productos bajos',
                        icon: Icons.warning_amber_rounded,
                        iconColor: AppColors.orange500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MetricCard(
                        title: 'Total Inventario',
                        value: '$totalStock',
                        subtitle: 'unidades',
                        icon: Icons.inventory_2_rounded,
                        iconColor: AppColors.blue500,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  MetricCard(
                    title: 'Alertas de Stock',
                    value: '${lowStockProducts.length}',
                    subtitle: 'productos bajos',
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.orange500,
                  ),
                  const SizedBox(height: 12),
                  MetricCard(
                    title: 'Total Inventario',
                    value: '$totalStock',
                    subtitle: 'unidades',
                    icon: Icons.inventory_2_rounded,
                    iconColor: AppColors.blue500,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Stock Summary Card
          Container(
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate700),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: AppColors.slate700)),
                  ),
                  child: const Text(
                    'Resumen de Stock',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate200,
                    ),
                  ),
                ),

                if (products.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: AppColors.slate600.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No hay productos registrados.',
                            style: TextStyle(color: AppColors.slate500),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      color: AppColors.slate700,
                    ),
                    itemBuilder: (context, index) {
                      final p = products[index];
                      final isLow = p.stock <= p.minStock;
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'SKU: ${p.sku}',
                                    style: const TextStyle(
                                      color: AppColors.slate400,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Existencia: ',
                                  style: TextStyle(
                                    color: AppColors.slate400,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '${p.stock}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  isLow ? Icons.trending_down : Icons.check_circle,
                                  size: 16,
                                  color: isLow ? AppColors.red500 : AppColors.emerald500,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
