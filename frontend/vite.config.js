import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/draw': {
        target: 'https://tarot-shuffle-draw-react-backend.joshuakite.co.uk',
        changeOrigin: true,
        secure: true,
      }
    }
  }
})
