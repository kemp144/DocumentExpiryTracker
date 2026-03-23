import { Outlet, useLocation } from 'react-router';
import { TabBar } from './TabBar';
import { useState } from 'react';
import { DemoNavigation } from './DemoNavigation';
import { Menu } from 'lucide-react';

export function Layout() {
  const location = useLocation();
  const [showNav, setShowNav] = useState(false);
  
  return (
    <div className="min-h-screen bg-[#0A0A0A] pb-20">
      <Outlet />
      <TabBar currentPath={location.pathname} />
      
      {/* Demo Navigation Toggle */}
      <button
        onClick={() => setShowNav(true)}
        className="fixed top-4 right-4 z-40 w-10 h-10 bg-white/10 text-white rounded-full flex items-center justify-center shadow-lg hover:bg-white/20 transition-colors backdrop-blur-sm border border-white/10"
      >
        <Menu className="w-5 h-5" />
      </button>
      
      {showNav && <DemoNavigation onClose={() => setShowNav(false)} />}
    </div>
  );
}