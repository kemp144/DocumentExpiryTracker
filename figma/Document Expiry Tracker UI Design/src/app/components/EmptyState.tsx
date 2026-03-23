import { LucideIcon } from 'lucide-react';
import { Link } from 'react-router';

interface EmptyStateProps {
  icon: LucideIcon;
  title: string;
  description: string;
  actionLabel?: string;
  actionPath?: string;
  onAction?: () => void;
}

export function EmptyState({ 
  icon: Icon, 
  title, 
  description, 
  actionLabel, 
  actionPath,
  onAction 
}: EmptyStateProps) {
  const ActionButton = actionPath ? Link : 'button';
  const actionProps = actionPath ? { to: actionPath } : { onClick: onAction };

  return (
    <div className="bg-[#1C1C1E] rounded-2xl p-8 border border-white/10 text-center">
      <div className="w-16 h-16 rounded-full bg-white/5 flex items-center justify-center mx-auto mb-4">
        <Icon className="w-8 h-8 text-gray-500" strokeWidth={1.5} />
      </div>
      <h3 className="text-[17px] font-semibold text-white mb-2">
        {title}
      </h3>
      <p className="text-[15px] text-gray-400 mb-6 leading-relaxed max-w-xs mx-auto">
        {description}
      </p>
      {actionLabel && (
        <ActionButton
          {...actionProps}
          className="inline-flex items-center justify-center px-6 py-2.5 bg-[#0A84FF] text-white rounded-full font-medium text-[15px] active:bg-[#0066CC] transition-colors"
        >
          {actionLabel}
        </ActionButton>
      )}
    </div>
  );
}