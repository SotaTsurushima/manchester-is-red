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

      this.setTokensFromResponse(response)
      const data = await response.json()
      this.user = data.data || data
    },

    logout() {
      this.user = null
      this.clearTokens()
    },

    setTokensFromResponse(response: Response) {
      const tokens = {
        'access-token': response.headers.get('access-token'),
        client: response.headers.get('client'),
        uid: response.headers.get('uid')
      }

      if (Object.values(tokens).every(Boolean)) {
        Object.assign(this.tokenHeaders, tokens as Record<string, string>)
        this.saveTokensToStorage(tokens as Record<string, string>)
      }
    },

    loadTokensFromStorage() {
      if (!import.meta.client) return

      TOKEN_KEYS.forEach(key => {
        this.tokenHeaders[key] = localStorage.getItem(key) || ''
      })
    },

    saveTokensToStorage(tokens: Record<string, string>) {
      if (!import.meta.client) return

      Object.entries(tokens).forEach(([key, value]) => {
        localStorage.setItem(key, value)
      })
    },

    clearTokens() {
      TOKEN_KEYS.forEach(key => {
        this.tokenHeaders[key] = ''
        if (import.meta.client) {
          localStorage.removeItem(key)
        }
      })
    }
  },

  persist: true
})
