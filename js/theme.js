// Light mode = navy + orange, dark mode = black + gold.
// Follows the phone's own light / dark setting until someone taps the sun / moon button; then that choice is remembered.
const KEY = 'vm-theme';
const saved = () => { try { const v = localStorage.getItem(KEY); return v === 'light' || v === 'dark' ? v : null; } catch { return null; } };
const sys = () => (typeof matchMedia !== 'undefined' && matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
export const theme = () => document.documentElement.dataset.theme || saved() || sys();

export function applyTheme(t = saved() || sys()) {
  document.documentElement.dataset.theme = t;
  const bar = t === 'dark' ? '#0E0F11' : '#0B2A5B';
  document.querySelector('meta[name=theme-color]')?.setAttribute('content', bar);
  // Android app: status bar colour and text to match.
  const SB = typeof window !== 'undefined' && window.Capacitor?.Plugins?.StatusBar;
  SB?.setStyle?.({ style: 'DARK' }).catch?.(() => {});
  SB?.setBackgroundColor?.({ color: bar }).catch?.(() => {});
}
export function toggleTheme() { const t = theme() === 'dark' ? 'light' : 'dark'; try { localStorage.setItem(KEY, t); } catch {} applyTheme(t); return t; }
export function useSystemTheme() { try { localStorage.removeItem(KEY); } catch {} applyTheme(); }
export const themeIsAuto = () => !saved();

if (typeof matchMedia !== 'undefined') matchMedia('(prefers-color-scheme: dark)').addEventListener?.('change', () => { if (!saved()) applyTheme(); });
