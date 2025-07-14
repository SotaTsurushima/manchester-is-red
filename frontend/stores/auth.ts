import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as Record<string, any> | null,
    tokenHeaders: {
      'access-token': '',
      'client': '',
      'uid': ''
    }
  }),
  actions: {
    async login(email: string, password: string, isAdmin = false) {
      const config = useRuntimeConfig()
      const baseUrl = config.public.baseUrl

      // 管理画面ならadmin用API、通常は一般用API
      const endpoint = isAdmin ? '/admin/auth/sign_in' : '/auth/sign_in'

      const response = await fetch(`${baseUrl}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })

      // ここで401などを判定して例外を投げる
      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || 'ログインに失敗しました')
      }

      // レスポンスヘッダーからトークンを取得
      if (process.client) {
        for (const key of ['access-token', 'client', 'uid']) {
          const value = response.headers.get(key) || ''
          this.tokenHeaders[key] = value
          localStorage.setItem(key, value)
        }
      }

      // レスポンスボディ（ユーザー情報）を保存
      const data = await response.json()
      this.user = data.data || data
    },

    logout() {
      this.user = null
      if (process.client) {
        for (const key of ['access-token', 'client', 'uid']) {
          this.tokenHeaders[key] = ''
          localStorage.removeItem(key)
        }
      }
    },

    loadTokens() {
      if (process.client) {
        for (const key of ['access-token', 'client', 'uid']) {
          this.tokenHeaders[key] = localStorage.getItem(key) || ''
        }
      }
    }
  }
})
