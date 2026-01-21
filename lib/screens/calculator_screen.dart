import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/app_providers.dart';
import '../widgets/app_theme.dart';

class CalculatorScreen extends StatefulWidget {
  final AppConfigState config;

  const CalculatorScreen({super.key, required this.config});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  double _costUsd = 0;
  double _weight = 0;

  double get _landedCost {
    return (_costUsd * widget.config.exchangeRate) +
           (_weight * widget.config.courierRate) +
           widget.config.packaging;
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$').format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calculadora',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.emerald400,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Calcula el costo puesto en RD de tus productos.',
            style: TextStyle(color: AppColors.slate400),
          ),
          const SizedBox(height: 32),

          // Input Fields
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate700),
            ),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => setState(() => _costUsd = double.tryParse(v) ?? 0),
                  decoration: InputDecoration(
                    labelText: 'Costo en USD',
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(12),
                      child: const Text('\$', style: TextStyle(color: AppColors.emerald400, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    filled: true,
                    fillColor: AppColors.slate900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.slate700),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (v) => setState(() => _weight = double.tryParse(v) ?? 0),
                  decoration: InputDecoration(
                    labelText: 'Peso (Lbs)',
                    prefixIcon: const Icon(Icons.scale, color: AppColors.slate400),
                    filled: true,
                    fillColor: AppColors.slate900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.slate700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Result Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.emerald500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'COSTO PUESTO EN RD (LANDED)',
                  style: TextStyle(
                    color: AppColors.slate400,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(_landedCost),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: AppColors.emerald400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate700),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Desglose',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _BreakdownRow(
                  label: 'Producto (USD × Tasa)',
                  calculation: '\$${_costUsd.toStringAsFixed(2)} × ${widget.config.exchangeRate}',
                  result: _formatCurrency(_costUsd * widget.config.exchangeRate),
                ),
                const Divider(color: AppColors.slate700, height: 24),
                _BreakdownRow(
                  label: 'Courier (Peso × Tarifa)',
                  calculation: '${_weight.toStringAsFixed(2)} lbs × ${widget.config.courierRate}',
                  result: _formatCurrency(_weight * widget.config.courierRate),
                ),
                const Divider(color: AppColors.slate700, height: 24),
                _BreakdownRow(
                  label: 'Empaque/Gestión',
                  calculation: 'Fijo',
                  result: _formatCurrency(widget.config.packaging),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final String label;
  final String calculation;
  final String result;

  const _BreakdownRow({
    required this.label,
    required this.calculation,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
              const SizedBox(height: 2),
              Text(calculation, style: const TextStyle(color: AppColors.slate500, fontSize: 11)),
            ],
          ),
        ),
        Text(
          result,
          style: const TextStyle(
            color: AppColors.emerald400,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
