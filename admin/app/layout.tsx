import './globals.css';
import type { Metadata } from 'next';

export const metadata: Metadata = {
  title: 'NutrIA Admin',
  description: 'Painel administrativo do NutrIA',
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return <html lang="pt-BR"><body>{children}</body></html>;
}
