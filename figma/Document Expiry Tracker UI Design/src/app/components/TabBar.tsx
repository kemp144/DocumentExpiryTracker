import { Home, FileText, BarChart3, Settings } from 'lucide-react';
import { Link } from 'react-router';

interface TabBarProps {
  currentPath: string;
}

export function TabBar({ currentPath }: TabBarProps) {
  const tabs = [
    { path: '/', icon: Home, label: 'Home' },
    { path: '/items', icon: FileText, label: 'Items' },
    { path: '/insights', icon: BarChart3, label: 'Insights' },
    { path: '/settings', icon: Settings, label: 'Settings' },
  ];

  const isActive = (path: string) => {
    if (path === '/') return currentPath === '/';
    return currentPath.startsWith(path);
  };

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-[#1C1C1E]/95 backdrop-blur-xl border-t border-white/10 safe-area-inset-bottom">
      <div className="max-w-md mx-auto flex justify-around items-center px-2 pt-2 pb-6">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const active = isActive(tab.path);
          
          return (
            <Link
              key={tab.path}
              to={tab.path}
              className="flex flex-col items-center gap-1 py-1 px-4 min-w-[60px]"
            >
              <Icon 
                className={`w-6 h-6 ${
                  active ? 'text-[#0A84FF]' : 'text-gray-500'
                }`}
                strokeWidth={active ? 2.5 : 2}
              />
              <span 
                className={`text-[10px] ${
                  active ? 'text-[#0A84FF] font-semibold' : 'text-gray-500'
                }`}
              >
                {tab.label}
              </span>
            </Link>
          );
        })}
      </div>
    </div>
  );
}