import { useAuth } from '~/composables/useAuth'

export default defineNuxtRouteMiddleware(to => {
  if (!import.meta.client) return

  const auth = useAuth()

  const hasTokens =
    auth.tokenHeaders &&
    auth.tokenHeaders['access-token'] &&
    auth.tokenHeaders['client'] &&
    auth.tokenHeaders['uid']

  if (!auth.user || auth.user.role !== 'admin' || !hasTokens) {
    return navigateTo('/admin/login')
  }
})
