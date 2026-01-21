import { AppConfigState } from './types';

export const DEFAULT_CONFIG: AppConfigState = {
  exchangeRate: 60.5,
  courierRate: 250.0,
  packaging: 50.0,
};

export const LOCAL_STORAGE_KEYS = {
  PRODUCTS: 'musicshop_products',
  CONFIG: 'musicshop_config',
  ORDERS: 'musicshop_orders',
};