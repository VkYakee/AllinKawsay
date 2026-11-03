// src/lib/design/typography.ts
export const typography = {
  h1: { size: 32, weight: 800, lineHeight: 1.1, letterSpacing: -1.0 },
  h2: { size: 24, weight: 700, lineHeight: 1.2, letterSpacing: -0.5 },
  h3: { size: 20, weight: 700, lineHeight: 1.25, letterSpacing: -0.3 },
  title: { size: 17, weight: 600, lineHeight: 1.3, letterSpacing: -0.4 },
  subtitle: { size: 15, weight: 500, lineHeight: 1.35, letterSpacing: -0.2 },
  body: { size: 15, weight: 400, lineHeight: 1.5, letterSpacing: 0 },
  bodySm: { size: 13, weight: 400, lineHeight: 1.45, letterSpacing: 0 },
  caption: { size: 12, weight: 500, lineHeight: 1.4, letterSpacing: 0.1 },
  captionXs: { size: 11, weight: 500, lineHeight: 1.35, letterSpacing: 0.2 },
  label: { size: 12, weight: 700, lineHeight: 1.3, letterSpacing: 0.5 },
  eyebrow: { size: 10, weight: 700, lineHeight: 1.3, letterSpacing: 1.5 }
} as const;