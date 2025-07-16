import { createPersistedState } from 'pinia-plugin-persistedstate'

export default defineNuxtPlugin((nuxtApp) => {
  // Piniaが存在することを確認
  if (nuxtApp.$pinia) {
    nuxtApp.$pinia.use(createPersistedState())
  }
})
