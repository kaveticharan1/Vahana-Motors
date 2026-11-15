// Day mode (navy + orange) is the default. Dark mode is black + gold.
// The choice is remembered on the phone: 'light', 'dark', or 'auto' (follow the phone's own setting).
const KEY = 'vm-theme';
const mode = () => { try { const v = localStorage.getItem(KEY); return v === 'dark' || v === 'auto' ? v : 'light'; } catch { return 'light'; } };
const sys = () => (typeof matchMedia !== 'undefined' && matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
const resolve = () => (mode() === 'auto' ? sys() : mode());
export const theme = () => document.documentElement.dataset.theme || resolve();
export const themeMode = () => mode();

export function applyTheme(t = resolve()) {
  document.documentElement.dataset.theme = t;
  const bar = t === 'dark' ? '#0E0F11' : '#0B2A5B';
  document.querySelector('meta[name=theme-color]')?.setAttribute('content', bar);
  const SB = typeof window !== 'undefined' && window.Capacitor?.Plugins?.StatusBar;
  SB?.setStyle?.({ style: 'DARK' }).catch?.(() => {});
  SB?.setBackgroundColor?.({ color: bar }).catch?.(() => {});
}
export function setThemeMode(m) { try { localStorage.setItem(KEY, m); } catch {} applyTheme(); }
export function toggleTheme() { const t = theme() === 'dark' ? 'light' : 'dark'; setThemeMode(t); return t; }

if (typeof matchMedia !== 'undefined') matchMedia('(prefers-color-scheme: dark)').addEventListener?.('change', () => { if (mode() === 'auto') applyTheme(); });
