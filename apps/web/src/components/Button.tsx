// @atomfit/web/src/components/Button.tsx
export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'outlined' | 'secondary' | 'danger' | 'link';
  size?: 'small' | 'medium';
}

export function Button({ variant = 'primary', size = 'medium', className, children, ...props }: ButtonProps) {
  const base = 'btn';
  const variants = {
    primary: 'btn-primary',
    outlined: 'btn-primary outlined',
    secondary: 'btn-secondary',
    danger: 'btn-danger',
    link: 'btn-link',
  };
  const sizes = { small: 'btn-icon small', medium: '' };
  return (
    <button
      className={[base, variants[variant], sizes[size], className].filter(Boolean).join(' ')}
      {...props}
    >
      {children}
    </button>
  );
}
