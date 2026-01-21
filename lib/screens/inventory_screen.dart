import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../providers/app_providers.dart';
import '../services/export_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/add_product_modal.dart';

class InventoryScreen extends StatefulWidget {
  final List<Product> products;
  final AppConfigState config;
  final Function(Product) onAddProduct;
  final Function(String) onDeleteProduct;

  const InventoryScreen({
    super.key,
    required this.products,
    required this.config,
    required this.onAddProduct,
    required this.onDeleteProduct,
  });

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String _searchTerm = '';

  List<Product> get _filteredProducts {
    if (_searchTerm.isEmpty) return widget.products;
    final term = _searchTerm.toLowerCase();
    return widget.products.where((p) =>
      p.name.toLowerCase().contains(term) ||
      p.sku.toLowerCase().contains(term)
    ).toList();
  }

  double _calculateLandedCost(double usd, double weight) {
    return (usd * widget.config.exchangeRate) + 
           (weight * widget.config.courierRate) + 
           widget.config.packaging;
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$').format(amount);
  }

  void _showAddModal([Product? product]) {
    showDialog(
      context: context,
      builder: (context) => AddProductModal(
        onSave: widget.onAddProduct,
        editProduct: product,
      ),
    );
  }

  void _confirmDelete(String sku, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de eliminar "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () {
              widget.onDeleteProduct(sku);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
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
                    'Inventario',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emerald400,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      _ActionButton(
                        icon: Icons.print,
                        label: 'PDF',
                        onTap: () => ExportService.exportToPdf(widget.products),
                        color: AppColors.slate700,
                      ),
                      _ActionButton(
                        icon: Icons.table_chart,
                        label: 'Excel',
                        onTap: () => ExportService.exportToExcel(widget.products),
                        color: AppColors.emerald600,
                      ),
                      _ActionButton(
                        icon: Icons.add,
                        label: 'Nuevo',
                        onTap: () => _showAddModal(),
                        color: AppColors.blue500,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _searchTerm = v),
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre o SKU...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
                  filled: true,
                  fillColor: AppColors.slate800,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slate700),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.slate700),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Table
        Expanded(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate700),
            ),
            clipBehavior: Clip.antiAlias,
            child: _filteredProducts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 48, color: AppColors.slate600.withValues(alpha: 0.5)),
                      const SizedBox(height: 8),
                      const Text('No se encontraron productos.', style: TextStyle(color: AppColors.slate500)),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(AppColors.slate900.withValues(alpha: 0.5)),
                            dataRowMinHeight: 60,
                            dataRowMaxHeight: 80,
                            columnSpacing: 16,
                            horizontalMargin: 16,
                            columns: [
                              const DataColumn(label: Text('Producto', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.w600))),
                              const DataColumn(label: Text('Min/Max', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.w600))),
                              const DataColumn(label: Text('Stock', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.w600))),
                              const DataColumn(label: Text('Precio', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.w600)), numeric: true),
                              if (isWide)
                                const DataColumn(label: Text('Landed', style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.w600)), numeric: true),
                              const DataColumn(label: Text('', style: TextStyle(color: AppColors.slate400))),
                            ],
                            rows: _filteredProducts.map((p) {
                              final landed = _calculateLandedCost(p.costUsd, p.weight);
                              final isLow = p.stock <= p.minStock;
                              final isOver = p.stock > p.maxStock;
                              final maxScale = p.maxStock > 0 ? (p.maxStock * 1.2) : 10.0;
                              final stockScale = (p.stock > maxScale) ? maxScale : p.stock.toDouble();
                              final percent = (maxScale > 0) ? (stockScale / maxScale).clamp(0.0, 1.0) : 0.0;

                              return DataRow(
                                cells: [
                                  DataCell(
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(p.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                        Text(p.sku, style: const TextStyle(color: AppColors.slate500, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.arrow_downward, size: 10, color: AppColors.orange400.withValues(alpha: 0.8)),
                                        Text('${p.minStock}', style: TextStyle(color: AppColors.orange400.withValues(alpha: 0.8), fontSize: 12, fontFamily: 'monospace')),
                                        const SizedBox(width: 6),
                                        const Text('|', style: TextStyle(color: AppColors.slate600)),
                                        const SizedBox(width: 6),
                                        Icon(Icons.arrow_upward, size: 10, color: AppColors.blue400.withValues(alpha: 0.8)),
                                        Text('${p.maxStock}', style: TextStyle(color: AppColors.blue400.withValues(alpha: 0.8), fontSize: 12, fontFamily: 'monospace')),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    SizedBox(
                                      width: 80,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${p.stock}',
                                                style: TextStyle(
                                                  color: isLow ? AppColors.red400 : (isOver ? AppColors.blue400 : AppColors.emerald400),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              if (isLow) ...[
                                                const Icon(Icons.warning, size: 12, color: AppColors.red400),
                                                const Text(' Bajo', style: TextStyle(color: AppColors.red400, fontSize: 10)),
                                              ],
                                              if (isOver)
                                                const Text('Exceso', style: TextStyle(color: AppColors.blue400, fontSize: 10)),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: percent,
                                              minHeight: 4,
                                              backgroundColor: AppColors.slate900,
                                              color: isLow ? AppColors.red500 : (isOver ? AppColors.blue500 : AppColors.emerald500),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      _formatCurrency(p.price),
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  if (isWide)
                                    DataCell(
                                      Text(
                                        _formatCurrency(landed),
                                        style: const TextStyle(color: AppColors.slate400, fontSize: 13, fontFamily: 'monospace'),
                                      ),
                                    ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 20),
                                          color: AppColors.blue400,
                                          tooltip: 'Editar',
                                          onPressed: () => _showAddModal(p),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20),
                                          color: AppColors.slate500,
                                          hoverColor: AppColors.red500.withValues(alpha: 0.1),
                                          tooltip: 'Eliminar',
                                          onPressed: () => _confirmDelete(p.sku, p.name),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
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
