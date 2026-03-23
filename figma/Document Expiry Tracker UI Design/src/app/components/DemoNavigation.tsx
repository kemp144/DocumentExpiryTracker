import { Link } from 'react-router';
import { X } from 'lucide-react';

interface DemoNavigationProps {
  onClose?: () => void;
}

export function DemoNavigation({ onClose }: DemoNavigationProps) {
  const sections = [
    {
      title: 'Start Here',
      links: [
        { to: '/', label: 'Welcome Screen' },
      ]
    },
    {
      title: 'Main App',
      links: [
        { to: '/app', label: 'Home (Populated)' },
        { to: '/app/items', label: 'Items List' },
        { to: '/app/item/1', label: 'Item Detail' },
        { to: '/app/add', label: 'Add Item' },
        { to: '/app/edit/1', label: 'Edit Item' },
        { to: '/app/insights', label: 'Insights (Locked)' },
        { to: '/app/settings', label: 'Settings' },
      ]
    },
    {
      title: 'Flows',
      links: [
        { to: '/onboarding', label: 'Onboarding' },
        { to: '/notifications', label: 'Notification Permission' },
        { to: '/paywall', label: 'Paywall' },
      ]
    },
    {
      title: 'Reference',
      links: [
        { to: '/design-system', label: 'Design System' },
      ]
    }
  ];

  return (
    <div className="fixed inset-0 bg-black/80 z-50 flex items-center justify-center p-4">
      <div className="bg-[#1C1C1E] rounded-2xl max-w-md w-full max-h-[80vh] overflow-y-auto border border-white/10">
        <div className="sticky top-0 bg-[#1C1C1E] border-b border-white/10 p-4 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-white">Screen Navigation</h2>
          {onClose && (
            <button onClick={onClose} className="w-8 h-8 rounded-full flex items-center justify-center hover:bg-white/10">
              <X className="w-5 h-5 text-gray-400" />
            </button>
          )}
        </div>
        
        <div className="p-4 space-y-6">
          {sections.map((section, index) => (
            <div key={index}>
              <h3 className="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-2">
                {section.title}
              </h3>
              <div className="space-y-1">
                {section.links.map((link, linkIndex) => (
                  <Link
                    key={linkIndex}
                    to={link.to}
                    onClick={onClose}
                    className="block px-3 py-2 text-sm text-gray-300 hover:bg-white/10 rounded-lg"
                  >
                    {link.label}
                  </Link>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}