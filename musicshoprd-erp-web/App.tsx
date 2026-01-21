import React, { useState, useEffect } from 'react';
import { ViewState, Product, AppConfigState, Order } from './types';
import { DEFAULT_CONFIG, LOCAL_STORAGE_KEYS } from './constants';
import Dashboard from './components/Dashboard';
import Inventory from './components/Inventory';
import OrdersKanban from './OrdersKanban';
import Calculator from './components/Calculator';
import Settings from './components/Settings';
import AddProductModal from './components/AddProductModal';
import { LayoutDashboard, Package, Calculator as CalcIcon, Settings as SettingsIcon, Menu, Music, ShoppingCart } from 'lucide-react';

const App: React.FC = () => {
  // State
  const [activeView, setActiveView] = useState<ViewState>('dashboard');
  const [products, setProducts] = useState<Product[]>([]);
  const [orders, setOrders] = useState<Order[]>([]);
  const [config, setConfig] = useState<AppConfigState>(DEFAULT_CONFIG);
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  // Load Data
  useEffect(() => {
    const savedProducts = localStorage.getItem(LOCAL_STORAGE_KEYS.PRODUCTS);
    const savedConfig = localStorage.getItem(LOCAL_STORAGE_KEYS.CONFIG);
    const savedOrders = localStorage.getItem(LOCAL_STORAGE_KEYS.ORDERS);

    if (savedProducts) {
      try {
        setProducts(JSON.parse(savedProducts));
      } catch (e) { console.error('Error parsing products', e); }
    }

    if (savedConfig) {
      try {
        setConfig(JSON.parse(savedConfig));
      } catch (e) { console.error('Error parsing config', e); }
    }

    if (savedOrders) {
      try {
        setOrders(JSON.parse(savedOrders));
      } catch (e) { console.error('Error parsing orders', e); }
    }
  }, []);

  // Save Data Helpers
  const saveProducts = (newProducts: Product[]) => {
    setProducts(newProducts);
    localStorage.setItem(LOCAL_STORAGE_KEYS.PRODUCTS, JSON.stringify(newProducts));
  };

  const saveConfig = (newConfig: AppConfigState) => {
    setConfig(newConfig);
    localStorage.setItem(LOCAL_STORAGE_KEYS.CONFIG, JSON.stringify(newConfig));
  };

  const saveOrders = (newOrders: Order[]) => {
    setOrders(newOrders);
    localStorage.setItem(LOCAL_STORAGE_KEYS.ORDERS, JSON.stringify(newOrders));
  };

  // Handlers
  const handleAddProduct = (product: Product) => {
    // Check if exists
    const exists = products.find(p => p.sku === product.sku);
    if (exists) {
      const updated = products.map(p => p.sku === product.sku ? product : p);
      saveProducts(updated);
    } else {
      saveProducts([...products, product]);
    }
  };

  const handleDeleteProduct = (sku: string) => {
    if (confirm('¿Estás seguro de eliminar este producto?')) {
      saveProducts(products.filter(p => p.sku !== sku));
    }
  };

  const handleCreateOrder = (order: Order) => {
    // 1. Save Order
    saveOrders([order, ...orders]);

    // 2. Only deduct stock if it's NOT a quote
    if (order.status !== 'quote') {
      const updatedProducts = products.map(p => {
        const orderedItem = order.items.find(item => item.sku === p.sku);
        if (orderedItem) {
          return { ...p, stock: p.stock - orderedItem.quantity };
        }
        return p;
      });
      saveProducts(updatedProducts);
    }
  };

  const handleUpdateOrder = (updatedOrder: Order) => {
    const oldOrder = orders.find(o => o.id === updatedOrder.id);
    if (!oldOrder) return;

    // Logic to handle stock deduction when moving from Quote -> Pending/Completed
    if (oldOrder.status === 'quote' && updatedOrder.status !== 'quote' && updatedOrder.status !== 'cancelled') {
      const updatedProducts = products.map(p => {
        const orderedItem = updatedOrder.items.find(item => item.sku === p.sku);
        if (orderedItem) {
          return { ...p, stock: p.stock - orderedItem.quantity };
        }
        return p;
      });
      saveProducts(updatedProducts);
    }

    // Logic to return stock if Cancelled (unless it was just a quote)
    if (oldOrder.status !== 'quote' && updatedOrder.status === 'cancelled') {
      const updatedProducts = products.map(p => {
        const orderedItem = updatedOrder.items.find(item => item.sku === p.sku);
        if (orderedItem) {
          return { ...p, stock: p.stock + orderedItem.quantity };
        }
        return p;
      });
      saveProducts(updatedProducts);
    }

    const newOrders = orders.map(o => o.id === updatedOrder.id ? updatedOrder : o);
    saveOrders(newOrders);
  };

  const handleDeleteOrder = (id: string) => {
    if (confirm('¿Eliminar historial de este pedido? El stock NO será afectado.')) {
      saveOrders(orders.filter(o => o.id !== id));
    }
  };

  const renderContent = () => {
    switch (activeView) {
      case 'dashboard':
        return <Dashboard products={products} />;
      case 'inventory':
        return <Inventory
          products={products}
          config={config}
          onDelete={handleDeleteProduct}
          onAdd={() => setIsModalOpen(true)}
        />;
      case 'orders':
        return <OrdersKanban
          orders={orders}
          products={products}
          onCreateOrder={handleCreateOrder}
          onUpdateOrder={handleUpdateOrder}
          onPrintOrder={(order, isQuote) => {
            console.log('Print', order, isQuote);
          }}
        />
      case 'calculator':
        return <Calculator config={config} />;
      case 'settings':
        return <Settings config={config} onUpdate={saveConfig} />;
      default:
        return <Dashboard products={products} />;
    }
  };

  const NavItem = ({ view, icon: Icon, label }: { view: ViewState, icon: any, label: string }) => (
    <button
      onClick={() => { setActiveView(view); setIsMobileMenuOpen(false); }}
      className={`flex items-center space-x-3 w-full px-4 py-3 rounded-lg transition-all duration-200 ${activeView === view
        ? 'bg-emerald-500/10 text-emerald-400 font-medium'
        : 'text-slate-400 hover:bg-slate-800 hover:text-slate-200'
        }`}
    >
      <Icon size={20} />
      <span>{label}</span>
    </button>
  );

  return (
    <div className="min-h-screen flex bg-slate-900 text-slate-100 font-sans selection:bg-emerald-500/30">
      {/* Sidebar Desktop */}
      <aside className="hidden md:flex flex-col w-64 border-r border-slate-800 bg-slate-900/50 backdrop-blur-xl h-screen sticky top-0">
        <div className="p-6 flex items-center gap-3 border-b border-slate-800">
          <div className="bg-emerald-500 p-2 rounded-lg">
            <Music className="text-white w-5 h-5" />
          </div>
          <h1 className="text-lg font-bold tracking-tight text-white">MusicShopRD</h1>
        </div>

        <nav className="flex-1 p-4 space-y-2">
          <NavItem view="dashboard" icon={LayoutDashboard} label="Inicio" />
          <NavItem view="inventory" icon={Package} label="Inventario" />
          <NavItem view="orders" icon={ShoppingCart} label="Pedidos" />
          <NavItem view="calculator" icon={CalcIcon} label="Calculadora" />
          <NavItem view="settings" icon={SettingsIcon} label="Configuración" />
        </nav>

        <div className="p-6 border-t border-slate-800">
          <div className="bg-slate-800/50 rounded-lg p-3 text-xs text-slate-500 border border-slate-800">
            <p className="font-medium text-slate-400 mb-1">Tasa del día</p>
            <p>1 USD = <span className="text-emerald-400 font-mono">RD${config.exchangeRate}</span></p>
          </div>
        </div>
      </aside>

      {/* Main Content */}
      <div className="flex-1 flex flex-col min-w-0">

        {/* Mobile Header */}
        <header className="md:hidden flex items-center justify-between p-4 border-b border-slate-800 bg-slate-900 sticky top-0 z-20">
          <div className="flex items-center gap-2">
            <div className="bg-emerald-500 p-1.5 rounded-lg">
              <Music className="text-white w-4 h-4" />
            </div>
            <span className="font-bold">MusicShopRD</span>
          </div>
          <button onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)} className="p-2 text-slate-400">
            <Menu />
          </button>
        </header>

        {/* Mobile Menu Overlay */}
        {isMobileMenuOpen && (
          <div className="md:hidden absolute top-16 left-0 right-0 bg-slate-900 border-b border-slate-800 z-30 shadow-2xl p-4 space-y-2 animate-fade-in">
            <NavItem view="dashboard" icon={LayoutDashboard} label="Inicio" />
            <NavItem view="inventory" icon={Package} label="Inventario" />
            <NavItem view="orders" icon={ShoppingCart} label="Pedidos" />
            <NavItem view="calculator" icon={CalcIcon} label="Calculadora" />
            <NavItem view="settings" icon={SettingsIcon} label="Configuración" />
          </div>
        )}

        <main className="flex-1 p-4 md:p-8 overflow-y-auto">
          {renderContent()}
        </main>
      </div>

      <AddProductModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSave={handleAddProduct}
        products={products}
      />
    </div>
  );
};

export default App;