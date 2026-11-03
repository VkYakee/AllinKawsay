// src/lib/design/tokens.ts
export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  '2xl': 24,
  '3xl': 32,
  '4xl': 48
} as const;

export const radius = {
  sm: 12,
  md: 18,
  lg: 24,
  xl: 32,
  '2xl': 40,
  full: 9999
} as const;

export const shadows = {
  sm: '0 2px 8px rgba(0,0,0,0.15)',
  md: '0 8px 24px rgba(0,0,0,0.25)',
  lg: '0 16px 40px rgba(0,0,0,0.40)'
} as const;