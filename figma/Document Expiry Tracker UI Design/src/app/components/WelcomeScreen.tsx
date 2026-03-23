import { Link } from 'react-router';
import { Smartphone, Palette, Eye, Code, Menu } from 'lucide-react';
import { Button } from './Button';
import { useState } from 'react';
import { DemoNavigation } from './DemoNavigation';

export function WelcomeScreen() {
  const [showNav, setShowNav] = useState(false);
  
  return (
    <div className="min-h-screen bg-gradient-to-br from-[#007AFF] to-[#5E5CE6] flex items-center justify-center p-6">
      {/* Demo Navigation Toggle */}
      <button
        onClick={() => setShowNav(true)}
        className="fixed top-4 right-4 z-40 w-10 h-10 bg-white/20 backdrop-blur text-white rounded-full flex items-center justify-center shadow-lg hover:bg-white/30 transition-colors"
      >
        <Menu className="w-5 h-5" />
      </button>
      
      {showNav && <DemoNavigation onClose={() => setShowNav(false)} />}
      
      <div className="max-w-lg w-full">
        {/* Icon */}
        <div className="w-20 h-20 rounded-3xl bg-white/20 backdrop-blur flex items-center justify-center mx-auto mb-6">
          <Smartphone className="w-10 h-10 text-white" />
        </div>

        {/* Title */}
        <h1 className="text-4xl font-bold text-white text-center mb-3 leading-tight">
          Document Expiry Tracker
        </h1>
        <p className="text-lg text-white/90 text-center mb-8">
          Premium iOS App UI Design
        </p>

        {/* Features */}
        <div className="bg-white/10 backdrop-blur-lg rounded-2xl p-6 mb-8 border border-white/20">
          <div className="space-y-4">
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-lg bg-white/20 flex items-center justify-center flex-shrink-0">
                <Palette className="w-4 h-4 text-white" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">Complete Design System</h3>
                <p className="text-sm text-white/80">Colors, typography, components, and spacing</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-lg bg-white/20 flex items-center justify-center flex-shrink-0">
                <Eye className="w-4 h-4 text-white" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">All Key Screens</h3>
                <p className="text-sm text-white/80">Home, Items, Insights, Settings, and more</p>
              </div>
            </div>
            <div className="flex items-start gap-3">
              <div className="w-8 h-8 rounded-lg bg-white/20 flex items-center justify-center flex-shrink-0">
                <Code className="w-4 h-4 text-white" />
              </div>
              <div>
                <h3 className="font-semibold text-white mb-1">Production Ready</h3>
                <p className="text-sm text-white/80">Built with React, TypeScript, and Tailwind</p>
              </div>
            </div>
          </div>
        </div>

        {/* Navigation */}
        <div className="space-y-3">
          <Link to="/onboarding" className="block">
            <Button size="lg" fullWidth variant="primary">
              Start Onboarding Flow
            </Button>
          </Link>
          <Link to="/app" className="block">
            <button className="w-full py-3 px-6 bg-white/10 backdrop-blur text-white rounded-full font-medium text-[17px] border border-white/20 hover:bg-white/20 transition-colors">
              View Main App
            </button>
          </Link>
          <Link to="/design-system" className="block">
            <button className="w-full py-3 text-white/90 text-[15px] hover:text-white transition-colors">
              Explore Design System
            </button>
          </Link>
        </div>

        {/* Footer */}
        <p className="text-center text-white/70 text-sm mt-8">
          Use the menu button (top right) to navigate between screens
        </p>
      </div>
    </div>
  );
}