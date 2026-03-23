import { useNavigate } from 'react-router';
import { Bell, Menu } from 'lucide-react';
import { Button } from '../components/Button';
import { useState } from 'react';
import { DemoNavigation } from '../components/DemoNavigation';

export function NotificationPermissionPage() {
  const navigate = useNavigate();
  const [showNav, setShowNav] = useState(false);

  const handleEnable = () => {
    // In a real app, this would request notification permissions
    navigate('/app');
  };

  const handleSkip = () => {
    navigate('/app');
  };

  return (
    <div className="min-h-screen bg-[#F5F5F7] flex flex-col items-center justify-center px-6">
      {/* Demo Navigation Toggle */}
      <button
        onClick={() => setShowNav(true)}
        className="fixed top-4 right-4 z-40 w-10 h-10 bg-gray-900 text-white rounded-full flex items-center justify-center shadow-lg hover:bg-gray-800 transition-colors"
      >
        <Menu className="w-5 h-5" />
      </button>
      
      {showNav && <DemoNavigation onClose={() => setShowNav(false)} />}
      
      <div className="max-w-md w-full">
        {/* Icon */}
        <div className="w-24 h-24 rounded-3xl bg-gradient-to-br from-[#007AFF] to-[#5E5CE6] flex items-center justify-center mx-auto mb-8">
          <Bell className="w-12 h-12 text-white" strokeWidth={1.5} />
        </div>

        {/* Title */}
        <h1 className="text-[28px] font-bold text-gray-900 text-center mb-4 leading-tight">
          Enable Notifications
        </h1>

        {/* Description */}
        <p className="text-[17px] text-gray-600 text-center leading-relaxed mb-8">
          Get reminded about upcoming renewals and expirations so you never miss an important date.
        </p>

        {/* Features */}
        <div className="bg-white rounded-2xl p-5 border border-gray-200/80 mb-8">
          <div className="space-y-4">
            <div className="flex items-start gap-3">
              <div className="w-6 h-6 rounded-full bg-[#34C759] flex items-center justify-center flex-shrink-0 mt-0.5">
                <svg className="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div>
                <p className="font-medium text-gray-900">Timely Reminders</p>
                <p className="text-sm text-gray-500 mt-0.5">Get notified before items expire</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <div className="w-6 h-6 rounded-full bg-[#34C759] flex items-center justify-center flex-shrink-0 mt-0.5">
                <svg className="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div>
                <p className="font-medium text-gray-900">Customizable Alerts</p>
                <p className="text-sm text-gray-500 mt-0.5">Choose when you want to be reminded</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <div className="w-6 h-6 rounded-full bg-[#34C759] flex items-center justify-center flex-shrink-0 mt-0.5">
                <svg className="w-4 h-4 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M5 13l4 4L19 7" />
                </svg>
              </div>
              <div>
                <p className="font-medium text-gray-900">Never Miss a Deadline</p>
                <p className="text-sm text-gray-500 mt-0.5">Stay organized and prepared</p>
              </div>
            </div>
          </div>
        </div>

        {/* Buttons */}
        <div className="space-y-3">
          <Button onClick={handleEnable} size="lg" fullWidth>
            Enable Notifications
          </Button>
          <button 
            onClick={handleSkip}
            className="w-full py-3 text-[15px] text-gray-500 active:text-gray-700"
          >
            Maybe Later
          </button>
        </div>
      </div>
    </div>
  );
}