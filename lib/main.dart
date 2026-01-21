import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/app_providers.dart';
import 'screens/dashboard_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/orders_kanban_screen.dart';
import 'screens/customers_screen.dart';
import 'screens/suppliers_screen.dart';
import 'screens/calculator_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_DO', null);
  runApp(const ProviderScope(child: MusicShopERPApp()));
}

class MusicShopERPApp extends StatelessWidget {
  const MusicShopERPApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MusicShopRD Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MusicShopERPHome(),
    );
  }
}

class MusicShopERPHome extends ConsumerStatefulWidget {
  const MusicShopERPHome({super.key});

  @override
  ConsumerState<MusicShopERPHome> createState() => _MusicShopERPHomeState();
}

class _MusicShopERPHomeState extends ConsumerState<MusicShopERPHome> {
  int _selectedIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Inicio'),
    _NavItem(icon: Icons.inventory_2_rounded, label: 'Inventario'),
    _NavItem(icon: Icons.shopping_cart_rounded, label: 'Pedidos'),
    _NavItem(icon: Icons.people_rounded, label: 'Clientes'),
    _NavItem(icon: Icons.local_shipping_rounded, label: 'Proveedores'),
    _NavItem(icon: Icons.calculate_rounded, label: 'Calculadora'),
    _NavItem(icon: Icons.settings_rounded, label: 'Config'),
  ];

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productProvider);
    final orders = ref.watch(orderProvider);
    final config = ref.watch(configProvider);
    final isWideScreen = MediaQuery.of(context).size.width >= 768;

    Widget content;
    switch (_selectedIndex) {
      case 0:
        content = DashboardScreen(products: products);
        break;
      case 1:
        content = InventoryScreen(
          products: products,
          config: config,
          onAddProduct: (p) => ref.read(productProvider.notifier).addProduct(p),
          onDeleteProduct: (sku) => ref.read(productProvider.notifier).deleteProduct(sku),
        );
        break;
      case 2:
        content = const OrdersKanbanScreen();
        break;
      case 3:
        content = const CustomersScreen();
        break;
      case 4:
        content = const SuppliersScreen();
        break;
      case 5:
        content = CalculatorScreen(config: config);
        break;
      case 6:
        content = SettingsScreen(
          config: config,
          onUpdate: (exchange, courier, packaging) =>
              ref.read(configProvider.notifier).updateConfig(exchange, courier, packaging),
        );
        break;
      default:
        content = DashboardScreen(products: products);
    }

    if (isWideScreen) {
      // Desktop/Tablet: Sidebar layout
      return Scaffold(
        body: Row(
          children: [
            // Sidebar
            _buildSidebar(config),
            // Main content
            Expanded(
              child: content,
            ),
          ],
        ),
      );
    } else {
      // Mobile: Bottom navigation
      return Scaffold(
        body: SafeArea(child: content),
        bottomNavigationBar: _buildBottomNav(),
      );
    }
  }

  Widget _buildSidebar(AppConfigState config) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: AppColors.slate900,
        border: Border(
          right: BorderSide(color: AppColors.slate800, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.slate800)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.emerald500,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.music_note, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'MusicShopRD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: _navItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = _selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Material(
                      color: isSelected
                          ? AppColors.emerald500.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => setState(() => _selectedIndex = index),
                        borderRadius: BorderRadius.circular(12),
                        hoverColor: AppColors.slate800,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                                color: isSelected ? AppColors.emerald400 : AppColors.slate400,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: isSelected ? AppColors.emerald400 : AppColors.slate400,
                                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Exchange Rate Footer
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slate800.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.slate800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tasa del día',
                  style: TextStyle(
                    color: AppColors.slate400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: AppColors.slate500),
                    children: [
                      const TextSpan(text: '1 USD = '),
                      TextSpan(
                        text: 'RD\$${config.exchangeRate}',
                        style: const TextStyle(
                          color: AppColors.emerald400,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.slate900,
        border: Border(
          top: BorderSide(color: AppColors.slate800, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.emerald400,
        unselectedItemColor: AppColors.slate500,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: _navItems.map((item) => BottomNavigationBarItem(
          icon: Icon(item.icon),
          activeIcon: Icon(item.icon),
          label: item.label,
        )).toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
