import { defineStore } from 'pinia'

const TOKEN_KEYS = ['access-token', 'client', 'uid'] as const
type TokenKey = (typeof TOKEN_KEYS)[number]
type TokenHeaders = Record<TokenKey, string>

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as Record<string, any> | null,
    tokenHeaders: {
      'access-token': '',
      client: '',
      uid: ''
    } as TokenHeaders
  }),

  actions: {
    async login(email: string, password: string, isAdmin = false) {
      const config = useRuntimeConfig()
      const baseUrl = config.public.baseUrl
      const endpoint = isAdmin ? '/admin/auth/sign_in' : '/auth/sign_in'

      const response = await fetch(`${baseUrl}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || 'ログインに失敗しました')
      }

      const data = await response.json()
      this.user = data.data || data
    },
    logout() {
      this.user = null
      console.log('Logged out, store cleared')
    },
    loadTokens() {
      if (import.meta.client) {
        TOKEN_KEYS.forEach(key => {
          this.tokenHeaders[key] = localStorage.getItem(key) || ''
        })
      }
    },
    clearTokenHeaders() {
      TOKEN_KEYS.forEach(key => {
        this.tokenHeaders[key] = ''
      })
    }
  },
  persist: true
})
