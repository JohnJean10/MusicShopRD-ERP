import 'package:flutter/material.dart';
import '../providers/app_providers.dart';
import '../widgets/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  final AppConfigState config;
  final Function(double exchange, double courier, double packaging) onUpdate;

  const SettingsScreen({
    super.key,
    required this.config,
    required this.onUpdate,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _exchangeController;
  late TextEditingController _courierController;
  late TextEditingController _packagingController;

  @override
  void initState() {
    super.initState();
    _exchangeController = TextEditingController(text: widget.config.exchangeRate.toString());
    _courierController = TextEditingController(text: widget.config.courierRate.toString());
    _packagingController = TextEditingController(text: widget.config.packaging.toString());
  }

  @override
  void didUpdateWidget(SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _exchangeController.text = widget.config.exchangeRate.toString();
      _courierController.text = widget.config.courierRate.toString();
      _packagingController.text = widget.config.packaging.toString();
    }
  }

  @override
  void dispose() {
    _exchangeController.dispose();
    _courierController.dispose();
    _packagingController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onUpdate(
      double.tryParse(_exchangeController.text) ?? widget.config.exchangeRate,
      double.tryParse(_courierController.text) ?? widget.config.courierRate,
      double.tryParse(_packagingController.text) ?? widget.config.packaging,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.emerald400),
            SizedBox(width: 8),
            Text('Configuración guardada'),
          ],
        ),
        backgroundColor: AppColors.slate800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuración',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.emerald400,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ajusta las tasas y parámetros del sistema.',
            style: TextStyle(color: AppColors.slate400),
          ),
          const SizedBox(height: 32),

          // Settings Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.slate700),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.emerald500.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.currency_exchange, color: AppColors.emerald400),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Configuración de Tasas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _SettingField(
                  controller: _exchangeController,
                  label: 'Tasa USD (DOP)',
                  hint: 'Ej: 60.5',
                  icon: Icons.attach_money,
                  helperText: 'Tasa de cambio del dólar a peso dominicano',
                ),
                const SizedBox(height: 16),

                _SettingField(
                  controller: _courierController,
                  label: 'Courier por Libra',
                  hint: 'Ej: 250',
                  icon: Icons.local_shipping,
                  helperText: 'Costo de courier por cada libra (RD\$)',
                ),
                const SizedBox(height: 16),

                _SettingField(
                  controller: _packagingController,
                  label: 'Empaque/Gestión',
                  hint: 'Ej: 50',
                  icon: Icons.inventory_2,
                  helperText: 'Costo fijo por empaque y gestión (RD\$)',
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Cambios'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.blue500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.blue500.withValues(alpha: 0.3)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: AppColors.blue400, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fórmula de Costo Landed',
                        style: TextStyle(
                          color: AppColors.blue400,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '(Costo USD × Tasa) + (Peso × Courier) + Empaque',
                        style: TextStyle(
                          color: AppColors.slate400,
                          fontSize: 13,
                          fontFamily: 'monospace',
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
}

class _SettingField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String helperText;

  const _SettingField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.slate400),
            filled: true,
            fillColor: AppColors.slate900,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate700),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.slate700),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.emerald500, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Text(
            helperText,
            style: const TextStyle(color: AppColors.slate500, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
