export interface Product {
  sku: string;
  name: string;
  brand: string;         // Brand/Marca for SKU generation
  color?: string;        // Optional color for SKU generation
  costUsd: number;
  weight: number;
  stock: number;
  minStock: number;
  maxStock: number;
  price: number; // Selling Price in RD$
}

export interface OrderItem {
  sku: string;
  name: string;
  quantity: number;
  price: number;
  total: number;
}

export enum OrderStatus {
  quote = 'quote',
  pending = 'pending',
  ready = 'ready',
  completed = 'completed',
  cancelled = 'cancelled',
}

export interface Order {
  id: string;
  customerName: string;
  date: string;
  items: OrderItem[];
  total: number;
  // quote: Cotización (Lead)
  // pending: Confirmado, esperando pago/preparación
  // ready: Listo para entrega/envío
  // completed: Entregado y cerrado
  // cancelled: Cancelado
  status: 'quote' | 'pending' | 'ready' | 'completed' | 'cancelled';
}

export interface AppConfigState {
  exchangeRate: number;
  courierRate: number;
  packaging: number;
}

export type ViewState = 'dashboard' | 'inventory' | 'orders' | 'calculator' | 'settings';