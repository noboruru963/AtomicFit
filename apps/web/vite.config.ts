import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';

// PWA is delivered via a hand-written service worker (public/sw.js) and manifest
// (public/manifest.json) using only standard web APIs (Rule I-09). vite-plugin-pwa
// is listed as a devDependency for future generation but is not required here.
export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
  server: {
    port: 5173,
  },
});
