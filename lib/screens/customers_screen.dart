import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/customer.dart';
import '../providers/app_providers.dart';
import '../widgets/app_theme.dart';
import '../widgets/add_customer_modal.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  String _searchTerm = '';

  void _showAddEditModal([Customer? customer]) {
    showDialog(
      context: context,
      builder: (context) => AddCustomerModal(
        customer: customer,
        onSave: (c) {
          if (customer == null) {
            ref.read(customerProvider.notifier).addCustomer(c);
          } else {
            ref.read(customerProvider.notifier).updateCustomer(c);
          }
        },
      ),
    );
  }

  void _confirmDelete(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Cliente'),
        content: Text('¿Estás seguro de eliminar a "${customer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red500),
            onPressed: () {
              ref.read(customerProvider.notifier).deleteCustomer(customer.id);
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
    final customers = ref.watch(customerProvider);
    final filtered = _searchTerm.isEmpty
        ? customers
        : customers.where((c) =>
            c.name.toLowerCase().contains(_searchTerm.toLowerCase()) ||
            c.email.toLowerCase().contains(_searchTerm.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Clientes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emerald400,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.blue500),
                    onPressed: () => _showAddEditModal(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Nuevo Cliente'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _searchTerm = v),
                decoration: InputDecoration(
                  hintText: 'Buscar cliente...',
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
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    customers.isEmpty ? 'No hay clientes registrados.' : 'No se encontraron resultados.',
                    style: const TextStyle(color: AppColors.slate500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final c = filtered[index];
                    return Card(
                      color: AppColors.slate800,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.emerald500.withValues(alpha: 0.2),
                          child: Text(
                            c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                            style: const TextStyle(color: AppColors.emerald400),
                          ),
                        ),
                        title: Text(c.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (c.email.isNotEmpty) Text(c.email, style: const TextStyle(color: AppColors.slate400, fontSize: 13)),
                            if (c.phone.isNotEmpty) Text(c.phone, style: const TextStyle(color: AppColors.slate400, fontSize: 13)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20, color: AppColors.blue400),
                              onPressed: () => _showAddEditModal(c),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20, color: AppColors.slate500),
                              onPressed: () => _confirmDelete(c),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
