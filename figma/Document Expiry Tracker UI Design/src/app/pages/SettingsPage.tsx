import { ChevronRight, Bell, Shield, Crown, RotateCcw, Star, Info, Mail } from 'lucide-react';
import { Link } from 'react-router';

export function SettingsPage() {
  const settingsSections = [
    {
      title: 'Notifications',
      items: [
        {
          icon: Bell,
          label: 'Reminders',
          value: 'Enabled',
          action: 'toggle',
          enabled: true
        },
        {
          icon: Bell,
          label: 'Push Notifications',
          value: 'Enabled',
          action: 'toggle',
          enabled: true
        }
      ]
    },
    {
      title: 'Privacy',
      items: [
        {
          icon: Shield,
          label: 'Privacy Policy',
          action: 'link'
        },
        {
          icon: Shield,
          label: 'Data & Security',
          description: 'Your data stays on your device',
          action: 'info'
        }
      ]
    },
    {
      title: 'Pro Features',
      items: [
        {
          icon: Crown,
          label: 'Upgrade to Pro',
          description: 'Unlock insights and advanced features',
          action: 'upgrade',
          highlight: true
        },
        {
          icon: RotateCcw,
          label: 'Restore Purchases',
          action: 'restore'
        }
      ]
    },
    {
      title: 'Support',
      items: [
        {
          icon: Star,
          label: 'Rate App',
          action: 'link'
        },
        {
          icon: Mail,
          label: 'Contact Support',
          value: 'support@app.com',
          action: 'link'
        },
        {
          icon: Info,
          label: 'About',
          action: 'link'
        }
      ]
    }
  ];

  return (
    <div className="max-w-md mx-auto px-4 pt-6 pb-8">
      <div className="mb-6">
        <h1 className="text-[28px] font-bold text-white tracking-tight">
          Settings
        </h1>
        <p className="text-[15px] text-gray-400 mt-1">
          Document Expiry Tracker
        </p>
      </div>

      {/* App Info Card */}
      <div className="bg-gradient-to-br from-[#0A84FF] to-[#5E5CE6] rounded-2xl p-6 mb-6 text-white shadow-lg">
        <div className="flex items-center gap-4 mb-4">
          <div className="w-16 h-16 rounded-2xl bg-white/20 backdrop-blur flex items-center justify-center">
            <Shield className="w-8 h-8" />
          </div>
          <div>
            <h2 className="text-xl font-bold">Privacy First</h2>
            <p className="text-sm text-white/80">Your data, your device</p>
          </div>
        </div>
        <p className="text-sm text-white/90 leading-relaxed">
          All your data is stored locally on your device. We don't collect or share any personal information.
        </p>
      </div>

      {/* Settings Sections */}
      <div className="space-y-6">
        {settingsSections.map((section, sectionIndex) => (
          <div key={sectionIndex}>
            <h2 className="text-sm font-semibold text-gray-500 uppercase tracking-wide mb-3 px-1">
              {section.title}
            </h2>
            <div className="bg-[#1C1C1E] rounded-2xl border border-white/10 overflow-hidden">
              {section.items.map((item, itemIndex) => {
                const Icon = item.icon;
                const isLast = itemIndex === section.items.length - 1;
                
                if (item.action === 'upgrade') {
                  return (
                    <Link to="/paywall" key={itemIndex}>
                      <div className={`p-4 active:bg-[#2C2C2E] transition-colors ${!isLast ? 'border-b border-white/10' : ''}`}>
                        <div className="flex items-center gap-3">
                          <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#0A84FF] to-[#5E5CE6] flex items-center justify-center">
                            <Icon className="w-5 h-5 text-white" />
                          </div>
                          <div className="flex-1 min-w-0">
                            <div className="flex items-center gap-2">
                              <p className="font-semibold text-white">{item.label}</p>
                              <span className="px-2 py-0.5 bg-gradient-to-r from-[#0A84FF] to-[#5E5CE6] text-white text-[10px] font-bold rounded uppercase">
                                Pro
                              </span>
                            </div>
                            {item.description && (
                              <p className="text-sm text-gray-400 mt-0.5">{item.description}</p>
                            )}
                          </div>
                          <ChevronRight className="w-5 h-5 text-gray-600" />
                        </div>
                      </div>
                    </Link>
                  );
                }
                
                if (item.action === 'toggle') {
                  return (
                    <div key={itemIndex} className={`p-4 ${!isLast ? 'border-b border-white/10' : ''}`}>
                      <div className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center">
                          <Icon className="w-5 h-5 text-gray-400" />
                        </div>
                        <div className="flex-1">
                          <p className="font-medium text-white">{item.label}</p>
                        </div>
                        <input
                          type="checkbox"
                          checked={item.enabled}
                          onChange={() => {}}
                          className="w-12 h-7 appearance-none bg-white/10 rounded-full relative cursor-pointer transition-colors checked:bg-[#30D158] before:content-[''] before:absolute before:w-5 before:h-5 before:bg-white before:rounded-full before:top-1 before:left-1 before:transition-transform checked:before:translate-x-5"
                        />
                      </div>
                    </div>
                  );
                }
                
                return (
                  <button key={itemIndex} className={`w-full p-4 active:bg-[#2C2C2E] transition-colors ${!isLast ? 'border-b border-white/10' : ''}`}>
                    <div className="flex items-center gap-3">
                      <div className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center">
                        <Icon className="w-5 h-5 text-gray-400" />
                      </div>
                      <div className="flex-1 text-left min-w-0">
                        <p className="font-medium text-white">{item.label}</p>
                        {item.description && (
                          <p className="text-sm text-gray-400 mt-0.5">{item.description}</p>
                        )}
                        {item.value && (
                          <p className="text-sm text-gray-400 mt-0.5">{item.value}</p>
                        )}
                      </div>
                      {item.action === 'link' && (
                        <ChevronRight className="w-5 h-5 text-gray-600" />
                      )}
                    </div>
                  </button>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {/* Version */}
      <div className="text-center mt-8">
        <p className="text-sm text-gray-500">Version 1.0.0</p>
        <p className="text-xs text-gray-500 mt-1">Made with care for your privacy</p>
      </div>
    </div>
  );
}