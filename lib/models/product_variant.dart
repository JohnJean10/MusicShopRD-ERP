/// Representa una variante específica de un producto (ej: color diferente)
/// Cada variante tiene su propio SKU único y stock independiente.
class ProductVariant {
  final String sku;       // SKU único de la variante (ej: "KZPRONEG001")
  final String color;     // Color o identificador de la variante
  int stock;              // Stock individual de esta variante
  final String? imageUrl; // URL de imagen opcional

  ProductVariant({
    required this.sku,
    required this.color,
    required this.stock,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'color': color,
      'stock': stock,
      'imageUrl': imageUrl,
    };
  }

  factory ProductVariant.fromMap(Map<String, dynamic> map) {
    return ProductVariant(
      sku: map['sku'] ?? '',
      color: map['color'] ?? 'Default',
      stock: map['stock'] ?? 0,
      imageUrl: map['imageUrl'],
    );
  }

  ProductVariant copyWith({
    String? sku,
    String? color,
    int? stock,
    String? imageUrl,
  }) {
    return ProductVariant(
      sku: sku ?? this.sku,
      color: color ?? this.color,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
