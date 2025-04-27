export default defineNuxtConfig({
  devtools: { enabled: false },
  vite: {
    server: {
      watch: {
        usePolling: true, // ホットリロードが反応しない場合は polling を有効にする
      },
    },
  },
})
