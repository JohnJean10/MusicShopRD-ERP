import { Product } from './types';

/**
 * Generates SKU in format: [BRAND][COLOR_ID][SEQUENCE]
 * Examples: RMB1021, CMW1023, UTR1024
 * 
 * @param brand - Brand/Marca name
 * @param color - Optional color name
 * @param existingProducts - Array of existing products to determine sequence
 * @returns Generated SKU string
 */
export function generateSKU(
    brand: string,
    color: string | undefined,
    existingProducts: Product[]
): string {
    // 1. Brand Identifier (first 2 letters uppercase)
    const brandId = brand.substring(0, 2).toUpperCase();

    // 2. Color Identifier (optional)
    let colorId = '';
    if (color && color.trim()) {
        const colorLetter = color.charAt(0).toUpperCase();

        // Count how many products exist with same brand and same color first letter
        const sameColorProducts = existingProducts.filter(p =>
            p.brand?.toLowerCase() === brand.toLowerCase() &&
            p.color?.charAt(0).toUpperCase() === colorLetter
        );

        const colorVariant = sameColorProducts.length + 1;
        colorId = colorLetter + colorVariant;
    }

    // 3. Sequence Number (chronological, 3 digits)
    const sequence = (existingProducts.length + 1).toString().padStart(3, '0');

    return brandId + colorId + sequence;
}

/**
 * Validates if a SKU already exists
 */
export function skuExists(sku: string, products: Product[]): boolean {
    return products.some(p => p.sku.toLowerCase() === sku.toLowerCase());
}
