import { useState } from 'react';
import { useNavigate } from 'react-router';
import { X, Crown, Check, BarChart3, Bell, Calendar, Lock, Menu } from 'lucide-react';
import { Button } from '../components/Button';
import { DemoNavigation } from '../components/DemoNavigation';

export function PaywallPage() {
  const navigate = useNavigate();
  const [viewMode, setViewMode] = useState<'full' | 'sheet'>('full');
  const [showNav, setShowNav] = useState(false);

  const features = [
    {
      icon: BarChart3,
      title: 'Detailed Insights',
      description: 'Track recurring costs and category breakdowns'
    },
    {
      icon: Calendar,
      title: 'Advanced Analytics',
      description: 'See patterns and trends in your renewals'
    },
    {
      icon: Bell,
      title: 'Unlimited Reminders',
      description: 'Set as many custom reminders as you need'
    },
    {
      icon: Lock,
      title: 'Priority Support',
      description: 'Get help when you need it most'
    }
  ];

  const handlePurchase = () => {
    // Simulate purchase
    alert('Purchase flow would start here');
    navigate(-1);
  };

  const handleRestore = () => {
    alert('Restore purchases flow would start here');
  };

  if (viewMode === 'sheet') {
    return (
      <div className="fixed inset-0 bg-black/40 flex items-end z-50 animate-in fade-in">
        <div className="bg-white rounded-t-3xl w-full max-w-md mx-auto pb-8 animate-in slide-in-from-bottom duration-300">
          {/* Handle */}
          <div className="flex justify-center pt-3 pb-4">
            <div className="w-10 h-1 bg-gray-300 rounded-full" />
          </div>

          <div className="px-6">
            {/* Icon */}
            <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-[#007AFF] to-[#5E5CE6] flex items-center justify-center mx-auto mb-4">
              <Crown className="w-8 h-8 text-white" />
            </div>

            {/* Title */}
            <h2 className="text-2xl font-bold text-gray-900 text-center mb-2">
              Unlock Pro
            </h2>
            <p className="text-[15px] text-gray-600 text-center mb-6">
              Get insights and advanced features
            </p>

            {/* Features */}
            <div className="bg-gray-50 rounded-2xl p-4 mb-6">
              <div className="space-y-3">
                {features.slice(0, 3).map((feature, index) => (
                  <div key={index} className="flex items-start gap-3">
                    <div className="w-5 h-5 rounded-full bg-[#34C759] flex items-center justify-center flex-shrink-0 mt-0.5">
                      <Check className="w-3.5 h-3.5 text-white" strokeWidth={3} />
                    </div>
                    <div className="flex-1">
                      <p className="text-[15px] font-medium text-gray-900">{feature.title}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>

            {/* Price */}
            <div className="bg-gray-900 rounded-2xl p-5 mb-6 text-center">
              <p className="text-sm text-gray-400 mb-1">One-time purchase</p>
              <p className="text-3xl font-bold text-white mb-1">$4.99</p>
              <p className="text-xs text-gray-400">No subscription required</p>
            </div>

            {/* Buttons */}
            <Button onClick={handlePurchase} size="lg" fullWidth>
              Purchase Pro
            </Button>
            
            <div className="flex items-center justify-center gap-4 mt-4">
              <button onClick={handleRestore} className="text-sm text-gray-500">
                Restore
              </button>
              <span className="text-gray-300">•</span>
              <button onClick={() => setViewMode('full')} className="text-sm text-gray-500">
                View full version
              </button>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F5F5F7]">
      {/* Header */}
      <div className="bg-white border-b border-gray-200/80">
        <div className="max-w-md mx-auto px-4 py-3">
          <div className="flex items-center justify-between">
            <button 
              onClick={() => navigate(-1)}
              className="w-10 h-10 -ml-2 rounded-full flex items-center justify-center active:bg-gray-100 transition-colors"
            >
              <X className="w-6 h-6 text-gray-600" />
            </button>
            <button onClick={() => setViewMode('sheet')} className="text-sm text-gray-500">
              View sheet version
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-md mx-auto px-6 py-8">
        {/* Hero */}
        <div className="text-center mb-8">
          <div className="w-20 h-20 rounded-3xl bg-gradient-to-br from-[#007AFF] to-[#5E5CE6] flex items-center justify-center mx-auto mb-6">
            <Crown className="w-10 h-10 text-white" />
          </div>
          <h1 className="text-[32px] font-bold text-gray-900 mb-3 leading-tight">
            Unlock Pro
          </h1>
          <p className="text-[17px] text-gray-600 leading-relaxed">
            Get powerful insights and never miss an important renewal
          </p>
        </div>

        {/* Features List */}
        <div className="bg-white rounded-2xl p-6 border border-gray-200/80 mb-6">
          <div className="space-y-5">
            {features.map((feature, index) => {
              const Icon = feature.icon;
              return (
                <div key={index} className="flex items-start gap-4">
                  <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-[#007AFF]/10 to-[#5E5CE6]/10 flex items-center justify-center flex-shrink-0">
                    <Icon className="w-6 h-6 text-[#007AFF]" />
                  </div>
                  <div className="flex-1 pt-1">
                    <h3 className="font-semibold text-gray-900 mb-1">
                      {feature.title}
                    </h3>
                    <p className="text-[15px] text-gray-600 leading-relaxed">
                      {feature.description}
                    </p>
                  </div>
                  <div className="w-6 h-6 rounded-full bg-[#34C759] flex items-center justify-center flex-shrink-0 mt-2">
                    <Check className="w-4 h-4 text-white" strokeWidth={3} />
                  </div>
                </div>
              );
            })}
          </div>
        </div>

        {/* Price Card */}
        <div className="bg-gradient-to-br from-gray-900 to-gray-800 rounded-2xl p-6 mb-6 text-white">
          <div className="text-center mb-4">
            <p className="text-sm text-gray-400 mb-2">One-time unlock</p>
            <div className="flex items-baseline justify-center gap-1">
              <span className="text-5xl font-bold">$4.99</span>
            </div>
            <p className="text-sm text-gray-400 mt-2">Pay once, keep forever</p>
          </div>
          
          <div className="pt-4 border-t border-white/10">
            <p className="text-center text-sm text-gray-300">
              <span className="font-medium text-white">No subscription.</span> One-time purchase.
            </p>
          </div>
        </div>

        {/* CTA Button */}
        <Button onClick={handlePurchase} size="lg" fullWidth>
          Purchase Pro for $4.99
        </Button>

        {/* Footer Links */}
        <div className="flex items-center justify-center gap-4 mt-6">
          <button onClick={handleRestore} className="text-[15px] text-gray-500">
            Restore Purchases
          </button>
          <span className="text-gray-300">•</span>
          <button className="text-[15px] text-gray-500">
            Terms
          </button>
        </div>

        {/* Privacy Note */}
        <div className="mt-8 bg-gray-50 rounded-xl p-4 border border-gray-200">
          <p className="text-sm text-gray-600 text-center leading-relaxed">
            Your purchase supports independent development and keeps this app privacy-focused and ad-free.
          </p>
        </div>
      </div>
    </div>
  );
}