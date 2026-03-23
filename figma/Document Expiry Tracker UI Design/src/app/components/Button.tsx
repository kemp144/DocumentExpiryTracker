import { ReactNode } from 'react';

interface ButtonProps {
  children: ReactNode;
  variant?: 'primary' | 'secondary' | 'ghost' | 'danger';
  size?: 'sm' | 'md' | 'lg';
  fullWidth?: boolean;
  onClick?: () => void;
  type?: 'button' | 'submit';
  disabled?: boolean;
}

export function Button({ 
  children, 
  variant = 'primary', 
  size = 'md', 
  fullWidth = false,
  onClick,
  type = 'button',
  disabled = false
}: ButtonProps) {
  const baseStyles = 'inline-flex items-center justify-center font-medium rounded-full transition-colors';
  
  const variantStyles = {
    primary: 'bg-[#0A84FF] text-white active:bg-[#0066CC] disabled:bg-gray-700 disabled:text-gray-500',
    secondary: 'bg-white/10 text-white active:bg-white/20',
    ghost: 'bg-transparent text-[#0A84FF] active:bg-white/10',
    danger: 'bg-[#FF453A]/20 text-[#FF453A] active:bg-[#FF453A]/30'
  };
  
  const sizeStyles = {
    sm: 'px-4 py-2 text-sm',
    md: 'px-6 py-2.5 text-[15px]',
    lg: 'px-8 py-3.5 text-[17px]'
  };
  
  const widthStyles = fullWidth ? 'w-full' : '';
  
  return (
    <button
      type={type}
      onClick={onClick}
      disabled={disabled}
      className={`${baseStyles} ${variantStyles[variant]} ${sizeStyles[size]} ${widthStyles}`}
    >
      {children}
    </button>
  );
}