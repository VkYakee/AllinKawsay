// src/lib/design/motion.ts
export const duration = {
  instant: 80,
  fast: 150,
  normal: 300,
  slow: 500
} as const;

export const easing = {
  spring: 'cubic-bezier(0.175, 0.885, 0.32, 1.275)',
  bouncy: 'cubic-bezier(0.34, 1.56, 0.64, 1)',
  smooth: 'cubic-bezier(0.25, 1, 0.5, 1)',
  snap: 'cubic-bezier(0.4, 0, 0.2, 1)'
} as const;