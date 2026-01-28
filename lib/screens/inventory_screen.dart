import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/product.dart';
import '../models/product_variant.dart';
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
  final Set<String> _expandedProducts = {};

  List<Product> get _filteredProducts {
    if (_searchTerm.isEmpty) return widget.products;
    final term = _searchTerm.toLowerCase();
    return widget.products.where((p) =>
      p.name.toLowerCase().contains(term) ||
      p.modelId.toLowerCase().contains(term) ||
      p.variants.any((v) => v.sku.toLowerCase().contains(term) || v.color.toLowerCase().contains(term))
    ).toList();
  }

  double _calculateLandedCost(double usd, double weight) {
    return (usd * widget.config.exchangeRate) + 
           (weight * widget.config.courierRate) + 
           widget.config.packaging;
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: 'RD\$').format(amount);
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

  void _confirmDelete(String modelId, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Estás seguro de eliminar "$name" y todas sus variantes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () {
              widget.onDeleteProduct(modelId);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  Color _getVariantColorDot(String colorName) {
    final name = colorName.toLowerCase();
    if (name.contains('negro') || name.contains('black')) return Colors.black;
    if (name.contains('blanco') || name.contains('white')) return Colors.white;
    if (name.contains('dorado') || name.contains('gold')) return const Color(0xFFFFD700);
    if (name.contains('plata') || name.contains('silver')) return Colors.grey.shade400;
    if (name.contains('azul') || name.contains('blue')) return Colors.blue;
    if (name.contains('rojo') || name.contains('red')) return Colors.red;
    if (name.contains('verde') || name.contains('green')) return Colors.green;
    if (name.contains('rosa') || name.contains('pink')) return Colors.pink;
    if (name.contains('morado') || name.contains('purple')) return Colors.purple;
    return AppColors.slate500;
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
                  hintText: 'Buscar por nombre, SKU o color...',
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

        // Product List with Expandable Tiles
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
              : ListView.builder(
                  itemCount: _filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = _filteredProducts[index];
                    final isExpanded = _expandedProducts.contains(product.modelId);
                    final hasMultipleVariants = product.variants.length > 1;
                    
                    return _buildProductTile(product, isExpanded, hasMultipleVariants);
                  },
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductTile(Product product, bool isExpanded, bool hasMultipleVariants) {
    final landed = _calculateLandedCost(product.costUsd, product.weight);
    final isLow = product.isLowStock;
    
    return Column(
      children: [
        // Product Header Row
        InkWell(
          onTap: hasMultipleVariants 
            ? () => setState(() {
                if (isExpanded) {
                  _expandedProducts.remove(product.modelId);
                } else {
                  _expandedProducts.add(product.modelId);
                }
              })
            : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isLow ? AppColors.red500.withValues(alpha: 0.1) : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: isExpanded ? Colors.transparent : AppColors.slate700,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                // Expand indicator (solo si tiene múltiples variantes)
                if (hasMultipleVariants)
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.slate400,
                    size: 20,
                  )
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                
                // Product info
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (isLow) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.red500,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'BAJO',
                                style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${product.brand ?? ''} • ${product.variants.length} variante${product.variants.length > 1 ? 's' : ''}',
                        style: const TextStyle(color: AppColors.slate500, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                
                // Stock total agregado
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Text(
                        '${product.totalStock}',
                        style: TextStyle(
                          color: isLow ? AppColors.red400 : AppColors.emerald400,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Stock Total',
                        style: TextStyle(color: AppColors.slate500, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                
                // Min/Max
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_downward, size: 10, color: AppColors.orange400.withValues(alpha: 0.8)),
                      Text('${product.minStock}', style: TextStyle(color: AppColors.orange400.withValues(alpha: 0.8), fontSize: 12)),
                      const SizedBox(width: 4),
                      const Text('|', style: TextStyle(color: AppColors.slate600)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_upward, size: 10, color: AppColors.blue400.withValues(alpha: 0.8)),
                      Text('${product.maxStock}', style: TextStyle(color: AppColors.blue400.withValues(alpha: 0.8), fontSize: 12)),
                    ],
                  ),
                ),
                
                // Price
                Expanded(
                  flex: 1,
                  child: Text(
                    _formatCurrency(product.price),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Landed Cost
                Expanded(
                  flex: 1,
                  child: Text(
                    _formatCurrency(landed),
                    style: const TextStyle(color: AppColors.slate400, fontSize: 12, fontFamily: 'monospace'),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // Margin %
                Expanded(
                  flex: 1,
                  child: Builder(
                    builder: (context) {
                      final margin = landed > 0 && product.price > 0
                          ? ((product.price - landed) / landed) * 100
                          : 0.0;
                      final marginColor = margin >= 30
                          ? AppColors.emerald400
                          : margin >= 15
                              ? AppColors.orange400
                              : AppColors.red400;
                      return Text(
                        '${margin.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: marginColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      );
                    },
                  ),
                ),
                
                // Purchase Link Icon
                SizedBox(
                  width: 40,
                  child: product.purchaseLink != null && product.purchaseLink!.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                          color: AppColors.blue400,
                          tooltip: 'Abrir link de compra',
                          onPressed: () async {
                            final uri = Uri.tryParse(product.purchaseLink!);
                            if (uri != null) {
                              launchUrl(uri, mode: LaunchMode.externalApplication);
                            }
                          },
                        )
                      : const Icon(Icons.link_off, size: 16, color: AppColors.slate700),
                ),
                
                // Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      color: AppColors.blue400,
                      tooltip: 'Editar',
                      onPressed: () => _showAddModal(product),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 18),
                      color: AppColors.slate500,
                      tooltip: 'Eliminar',
                      onPressed: () => _confirmDelete(product.modelId, product.name),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Expanded Variant Rows
        if (isExpanded)
          ...product.variants.map((variant) => _buildVariantRow(product, variant)),
      ],
    );
  }

  Widget _buildVariantRow(Product product, ProductVariant variant) {
    final variantIsLow = variant.stock < (product.minStock / product.variants.length).ceil();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.only(left: 28),
      decoration: BoxDecoration(
        color: AppColors.slate900.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: AppColors.slate700.withValues(alpha: 0.5), width: 0.5),
          left: BorderSide(color: AppColors.emerald500.withValues(alpha: 0.3), width: 2),
        ),
      ),
      child: Row(
        children: [
          // Color dot
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _getVariantColorDot(variant.color),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.slate600, width: 1),
            ),
          ),
          const SizedBox(width: 12),
          
          // Variant info
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  variant.color,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                ),
                Text(
                  variant.sku,
                  style: const TextStyle(color: AppColors.slate500, fontSize: 10, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          
          // Variant stock
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${variant.stock}',
                  style: TextStyle(
                    color: variantIsLow ? AppColors.orange400 : AppColors.slate300,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (variantIsLow) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.warning_amber, size: 12, color: AppColors.orange400),
                ],
              ],
            ),
          ),
          
          // Spacers for alignment
          const Expanded(flex: 1, child: SizedBox()),
          const Expanded(flex: 1, child: SizedBox()),
          const Expanded(flex: 1, child: SizedBox()),
          const SizedBox(width: 80), // Actions column width
        ],
      ),
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
