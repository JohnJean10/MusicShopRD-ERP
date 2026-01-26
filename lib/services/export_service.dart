import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../models/order.dart';

class ExportService {
  static String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'es_DO', symbol: 'RD\$').format(amount);
  }

  static Future<void> exportToPdf(List<Product> products) async {
    final pdf = pw.Document();
    
    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "MusicShopRD - Reporte de Inventario",
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
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
            headerDecoration: const pw.BoxDecoration(color: PdfColors.blueGrey800),
            cellPadding: const pw.EdgeInsets.all(6),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.center,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
            },
            headers: ['SKU', 'Producto', 'Stock', 'Precio Venta', 'Costo USD'],
            data: products.map((p) => [
              p.primarySku,
              p.name,
              p.stock.toString(),
              _formatCurrency(p.price),
              '\$${p.costUsd.toStringAsFixed(2)}',
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Total Productos: ${products.length}'),
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
          
          // Customer Info
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Row(
              children: [
                 pw.Text("Cliente:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                 pw.SizedBox(width: 8),
                 pw.Text(order.customerName),
              ],
            ),
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
    excel.delete('Sheet1'); // Remove default sheet
    
    Sheet sheet = excel['Inventario'];
    
    // Header row
    sheet.appendRow([
      TextCellValue('SKU'),
      TextCellValue('Nombre'),
      TextCellValue('Costo USD'),
      TextCellValue('Peso (Lbs)'),
      TextCellValue('Stock'),
      TextCellValue('Min'),
      TextCellValue('Max'),
      TextCellValue('Precio Venta (RD\$)'),
    ]);

    // Data rows
    for (var p in products) {
      sheet.appendRow([
        TextCellValue(p.primarySku),
        TextCellValue(p.name),
        DoubleCellValue(p.costUsd),
        DoubleCellValue(p.weight),
        IntCellValue(p.stock),
        IntCellValue(p.minStock),
        IntCellValue(p.maxStock),
        DoubleCellValue(p.price),
      ]);
    }

    // Style header row
    for (int col = 0; col < 8; col++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#334155'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );
    }

    final bytes = excel.save();
    if (bytes != null) {
      final fileName = 'inventario_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
      await Printing.sharePdf(bytes: Uint8List.fromList(bytes), filename: fileName);
    }
  }
}
