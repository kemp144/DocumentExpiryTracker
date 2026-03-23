import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Calendar, Bell, Shield, Check, Menu } from 'lucide-react';
import { Button } from '../components/Button';
import { DemoNavigation } from '../components/DemoNavigation';

export function OnboardingPage() {
  const navigate = useNavigate();
  const [currentStep, setCurrentStep] = useState(0);
  const [showNav, setShowNav] = useState(false);

  const steps = [
    {
      icon: Calendar,
      title: 'Track Important Renewals',
      description: 'Never miss a document expiration, subscription renewal, or contract deadline again.',
      color: 'from-[#007AFF] to-[#5E5CE6]'
    },
    {
      icon: Bell,
      title: 'Stay Ahead with Gentle Reminders',
      description: 'Get notified at just the right time, so you\'re always prepared and never caught off guard.',
      color: 'from-[#FF9500] to-[#FF6B00]'
    },
    {
      icon: Shield,
      title: 'Keep Everything Private and Organized',
      description: 'Your data stays on your device. Simple, secure, and completely private.',
      color: 'from-[#34C759] to-[#30D158]'
    }
  ];

  const handleNext = () => {
    if (currentStep < steps.length - 1) {
      setCurrentStep(currentStep + 1);
    } else {
      navigate('/notifications');
    }
  };

  const handleSkip = () => {
    navigate('/app');
  };

  const step = steps[currentStep];
  const Icon = step.icon;

  return (
    <div className="min-h-screen bg-[#F5F5F7] flex flex-col">
      {/* Demo Navigation Toggle */}
      <button
        onClick={() => setShowNav(true)}
        className="fixed top-4 right-4 z-40 w-10 h-10 bg-gray-900 text-white rounded-full flex items-center justify-center shadow-lg hover:bg-gray-800 transition-colors"
      >
        <Menu className="w-5 h-5" />
      </button>
      
      {showNav && <DemoNavigation onClose={() => setShowNav(false)} />}
      
      <div className="max-w-md mx-auto w-full flex-1 flex flex-col px-6 pt-12 pb-8">
        {/* Skip Button */}
        <div className="flex justify-end mb-8">
          <button 
            onClick={handleSkip}
            className="text-[15px] text-gray-500 active:text-gray-700"
          >
            Skip
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 flex flex-col justify-center pb-12">
          {/* Icon */}
          <div className={`w-24 h-24 rounded-3xl bg-gradient-to-br ${step.color} flex items-center justify-center mx-auto mb-8`}>
            <Icon className="w-12 h-12 text-white" strokeWidth={1.5} />
          </div>

          {/* Title */}
          <h1 className="text-[28px] font-bold text-gray-900 text-center mb-4 leading-tight px-4">
            {step.title}
          </h1>

          {/* Description */}
          <p className="text-[17px] text-gray-600 text-center leading-relaxed px-4">
            {step.description}
          </p>
        </div>

        {/* Pagination Dots */}
        <div className="flex justify-center gap-2 mb-8">
          {steps.map((_, index) => (
            <div
              key={index}
              className={`h-2 rounded-full transition-all ${
                index === currentStep 
                  ? 'w-8 bg-[#007AFF]' 
                  : 'w-2 bg-gray-300'
              }`}
            />
          ))}
        </div>

        {/* Button */}
        <Button onClick={handleNext} size="lg" fullWidth>
          {currentStep < steps.length - 1 ? 'Continue' : 'Get Started'}
        </Button>
      </div>
    </div>
  );
}