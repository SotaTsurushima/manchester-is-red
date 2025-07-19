export default defineNuxtConfig({
  devtools: { enabled: false },
  vite: {
    server: {
      watch: {
        usePolling: true, // ホットリロードが反応しない場合は polling を有効にする
      },
    },
    optimizeDeps: {
      exclude: ['some-heavy-dependency'], // 不要な依存関係を除外してビルドを軽くする
    },
  },
  runtimeConfig: {
    public: {
      baseUrl: process.env.NODE_ENV === 'production' 
        ? 'https://manchester-is-red-backend.onrender.com'  // 本番環境のURL
        : 'http://localhost:8000',  // 開発環境のURL
      MINIO_BASE_URL: process.env.MINIO_BASE_URL || 'http://localhost:9000/manchester-united-bucket'
    }
  },
  modules: [
    '@nuxtjs/tailwindcss',
    '@pinia/nuxt',
    'pinia-plugin-persistedstate/nuxt'
  ],
  nitro: {
    routeRules: {
      '/.well-known/**': { statusCode: 404 }
    }
  }
});
