import { defineStore } from 'pinia'

const TOKEN_KEYS = ['access-token', 'client', 'uid'] as const
type TokenKey = typeof TOKEN_KEYS[number]
type TokenHeaders = Record<TokenKey, string>

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as Record<string, any> | null,
    tokenHeaders: {
      'access-token': '',
      'client': '',
      'uid': ''
    } as TokenHeaders
  }),
  persist: true,
  actions: {
    async login(email: string, password: string, isAdmin = false) {
      const config = useRuntimeConfig()
      const baseUrl = config.public.baseUrl
      const endpoint = isAdmin ? '/admin/auth/sign_in' : '/auth/sign_in'

      const response = await fetch(`${baseUrl}${endpoint}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      })

      if (!response.ok) {
        const errorData = await response.json()
        throw new Error(errorData.error || 'ログインに失敗しました')
      }

      if (import.meta.client) {
        this.saveTokenHeadersFromResponse(response)
      }

      const data = await response.json()
      this.user = data.data || data
    },
    logout() {
      this.user = null
      if (import.meta.client) {
        this.clearTokenHeaders()
      }
    },
    loadTokens() {
      if (import.meta.client) {
        TOKEN_KEYS.forEach(key => {
          this.tokenHeaders[key] = localStorage.getItem(key) || ''
        })
      }
    },
    setUser(user: Record<string, any> | null) {
      this.user = user
    },
    setTokenHeaders(headers: TokenHeaders) {
      this.tokenHeaders = headers
    },
    saveTokenHeadersFromResponse(response: Response) {
      TOKEN_KEYS.forEach(key => {
        const value = response.headers.get(key) || ''
        this.tokenHeaders[key] = value
        localStorage.setItem(key, value)
      })
    },
    clearTokenHeaders() {
      TOKEN_KEYS.forEach(key => {
        this.tokenHeaders[key] = ''
        localStorage.removeItem(key)
      })
    }
  }
})
