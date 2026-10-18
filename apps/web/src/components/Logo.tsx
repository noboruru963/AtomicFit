// @atomfit/web/src/components/Logo.tsx
// Single replaceable logo asset (BA-006). Swapping the logo touches one place here.
export function Logo({ className }: { className?: string }) {
  return (
    <img
      src="/logo.svg"
      alt="AtomFit logo"
      className={className ?? ''}
      width="32"
      height="32"
      aria-label="AtomFit"
    />
  );
}
