// frontend/middleware/auth.ts
import { useAuthStore } from '~/stores/auth'

export default defineNuxtRouteMiddleware((to, from) => {
  const auth = useAuthStore()
  auth.loadTokens()
  if (!auth.tokenHeaders['access-token'] || !auth.tokenHeaders['client'] || !auth.tokenHeaders['uid']) {
    // 管理画面の場合は/admin/loginにリダイレクト
    if (to.path.startsWith('/admin')) {
      return navigateTo('/admin/login')
    }
    // それ以外は通常の/loginにリダイレクト
    return navigateTo('/login')
  }

  // 未ログイン or adminでない場合はログインページへリダイレクト
  if (!auth.user || auth.user.role !== 'admin') {
    return navigateTo('/admin/login')
  }
})
