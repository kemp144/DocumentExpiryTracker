interface StatusBadgeProps {
  status: 'expired' | 'due-soon' | 'active';
  text: string;
  size?: 'sm' | 'md';
}

export function StatusBadge({ status, text, size = 'md' }: StatusBadgeProps) {
  const getStatusStyles = () => {
    switch (status) {
      case 'expired':
        return 'bg-[#FF453A]/20 text-[#FF453A]';
      case 'due-soon':
        return 'bg-[#FF9F0A]/20 text-[#FF9F0A]';
      case 'active':
        return 'bg-white/10 text-gray-400';
      default:
        return 'bg-white/10 text-gray-400';
    }
  };

  const sizeStyles = size === 'sm' 
    ? 'text-[11px] px-2 py-0.5' 
    : 'text-xs px-2.5 py-1';

  return (
    <span className={`inline-flex items-center rounded-full font-medium ${getStatusStyles()} ${sizeStyles}`}>
      {text}
    </span>
  );
}