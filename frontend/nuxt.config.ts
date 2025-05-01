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
      baseUrl: process.env.API_BASE_URL || 'http://localhost:8000'
    }
  },
  modules: [
    '@nuxtjs/tailwindcss', // ← 追加するだけ！
  ],
});
