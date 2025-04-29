export default defineNuxtConfig({
  devtools: { enabled: false },
  vite: {
    server: {
      watch: {
        usePolling: true, // ホットリロードが反応しない場合は polling を有効にする
      },
    },
    optimizeDeps: {
      exclude: ['some-heavy-dependency'],  // 不要な依存関係を除外してビルドを軽くする
    },
  },
  modules: [
    '@nuxtjs/tailwindcss', // ← 追加するだけ！
  ]
});
