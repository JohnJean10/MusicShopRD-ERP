import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/order.dart';

class ExportService {
  static String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: 'RD\$').format(amount);
  }

  static pw.Widget _buildDetailRow(String label, DateTime date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text("$label:", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
        pw.Text(DateFormat('dd/MM/yyyy h:mm a').format(date), style: const pw.TextStyle(fontSize: 9)),
      ],
    );
  }

  static Future<void> exportToPdf(List<Product> products) async {
    final pdf = pw.Document();
    
    // Load Logo
    final logoImage = await rootBundle.load('assets/images/logo.png');
    final logoBytes = logoImage.buffer.asUint8List();
    final logo = pw.MemoryImage(logoBytes);

    // Prepare Data (Flatten Variants)
    final List<List<String>> data = [];
    
    for (var p in products) {
      if (p.variants.length > 1) {
        // Multiple variants: List each one
        for (var v in p.variants) {
          data.add([
            v.sku,
            '${p.name} (${v.color})',
            v.stock.toString(),
            _formatCurrency(p.price),
            '\$${p.costUsd.toStringAsFixed(2)}',
          ]);
        }
      } else {
        // Single variant (Legacy or simple product)
        data.add([
          p.primarySku,
          p.name,
          p.stock.toString(),
          _formatCurrency(p.price),
          '\$${p.costUsd.toStringAsFixed(2)}',
        ]);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Row(
                  children: [
                    pw.Image(logo, width: 40),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      "MusicShopRD - Reporte de Inventario",
                      style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),
                pw.Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.black), // Black header
            cellPadding: const pw.EdgeInsets.all(6),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
            headers: ['SKU', 'Producto', 'Stock', 'Precio Venta', 'Costo USD'],
            data: data,
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Variantes/Items: ${data.length}'),
              pw.Text('Total Unidades: ${products.fold<int>(0, (sum, p) => sum + p.stock)}'),
            ],
          ),
        ],
      ),
    );
    
    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  static Future<void> generateOrderPdf(Order order, bool isQuote) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          // Header
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    "MusicShopRD",
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                  ),
                  pw.Text("Av. Principal #123, Santo Domingo"),
                  pw.Text("Tel: (809) 555-0123"),
                  pw.Text("RNC: 123456789"),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    isQuote ? "COTIZACIÓN" : "FACTURA",
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: isQuote ? PdfColors.blue600 : PdfColors.green700),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    isQuote ? "No. COT-${order.id.substring(order.id.length - 6)}" : "No. FAC-${order.id.substring(order.id.length - 6)}",
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                    DateFormat('dd/MM/yyyy').format(order.date),
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 30),
          
          // Customer Info & Order Details
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Customer
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Cliente:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.SizedBox(height: 4),
                      pw.Text(order.customerName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 20),
              // Timeline & Payment Details
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text("Historial:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.SizedBox(height: 4),
                    _buildDetailRow("Creado", order.date),
                    if (order.paymentDate != null)
                      _buildDetailRow("Pagado", order.paymentDate!),
                    if (order.deliveryDate != null)
                      _buildDetailRow("Entregado", order.deliveryDate!),
                    
                    if (order.paymentMethod != null) ...[
                      pw.SizedBox(height: 8),
                      pw.Text("Método de Pago:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text(order.paymentMethod!, style: const pw.TextStyle(fontSize: 10)),
                    ]
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // Items Table
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: isQuote ? PdfColors.blue600 : PdfColors.green700),
            cellPadding: const pw.EdgeInsets.all(8),
            cellAlignments: {
              0: pw.Alignment.centerLeft, // Product
              1: pw.Alignment.center,     // Qty
              2: pw.Alignment.centerRight, // Price
              3: pw.Alignment.centerRight, // Total
            },
            headers: ['Producto', 'Cant.', 'Precio', 'Total'],
            data: order.items.map((item) => [
              item.name,
              item.quantity.toString(),
              _formatCurrency(item.price),
              _formatCurrency(item.total),
            ]).toList(),
          ),
          
          pw.SizedBox(height: 20),
          
          // Totals
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    "Total General",
                    style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    _formatCurrency(order.total),
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                  ),
                ],
              ),
            ],
          ),
          
          pw.SizedBox(height: 40),
          pw.Divider(),
          
          // Footer
          pw.Center(
            child: pw.Text(
              isQuote 
                ? "Esta cotización es válida por 15 días. Precios sujetos a cambios." 
                : "¡Gracias por su compra!",
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ),
        ],
      ),
    );
    
    await Printing.layoutPdf(
      onLayout: (format) => pdf.save(),
      name: isQuote ? 'cotizacion_${order.id}' : 'factura_${order.id}',
    );
  }

  static Future<void> exportToExcel(List<Product> products) async {
    var excel = Excel.createExcel();
    
    // Access 'Inventario' first to ensure it exists (create if not)
    Sheet sheet = excel['Inventario'];
    
    // Now delete the default 'Sheet1' if it exists.
    // Try accessing it to check existence or just delete blindly if supported.
    // The excel package creates 'Sheet1' by default.    
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1'); 
    }
    
    // Ensure 'Inventario' is the active/default sheet by explicitly selecting it if needed (optional)
    
    // Title Row
    sheet.appendRow([TextCellValue('MusicShopRD - Reporte de Inventario')]);
    sheet.appendRow([TextCellValue('Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}')]);
    sheet.appendRow([TextCellValue('')]); // Empty spacer row

    // Merge title cells for better look (optional, but good practice)
    // excel library might not support complex merging easily in all versions, sticking to simple append for safety

    // Header row
    sheet.appendRow([
      TextCellValue('SKU'),
      TextCellValue('Nombre'),
      TextCellValue('Color/Variante'),
      TextCellValue('Costo USD'),
      TextCellValue('Peso (Lbs)'),
      TextCellValue('Stock'),
      TextCellValue('Min'),
      TextCellValue('Max'),
      TextCellValue('Precio Venta (RD\$)'),
    ]);

    // Data rows
    for (var p in products) {
      if (p.variants.length > 1) {
        // Multiple variants
        for (var v in p.variants) {
          sheet.appendRow([
            TextCellValue(v.sku),
            TextCellValue(p.name),
            TextCellValue(v.color),
            DoubleCellValue(p.costUsd),
            DoubleCellValue(p.weight),
            IntCellValue(v.stock),
            IntCellValue(p.minStock),
            IntCellValue(p.maxStock),
            DoubleCellValue(p.price),
          ]);
        }
      } else {
        // Single variant / Legacy
        sheet.appendRow([
          TextCellValue(p.primarySku),
          TextCellValue(p.name),
          TextCellValue('-'),
          DoubleCellValue(p.costUsd),
          DoubleCellValue(p.weight),
          IntCellValue(p.stock),
          IntCellValue(p.minStock),
          IntCellValue(p.maxStock),
          DoubleCellValue(p.price),
        ]);
      }
    }

    // Style header row (Row index 3, 0-based)
    for (int col = 0; col < 9; col++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 3));
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#000000'), // Black header matching PDF
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );
    }
    
    // Auto-fit width is not natively supported in all excel flutter pkg versions, letting default width apply

    final bytes = excel.save();
    if (bytes != null) {
      final fileName = 'inventario_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
      await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: fileName);
    }
  }
}
