import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/draw': {
        target: 'https://tarot-shuffle-draw-react-backend.joshuakite.co.uk',
        changeOrigin: true,
        secure: true,
      },
    },
  },
})
