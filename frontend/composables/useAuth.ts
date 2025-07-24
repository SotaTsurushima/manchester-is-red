import { useAuthStore } from '~/stores/auth'

export const useAuth = () => {
  const auth = useAuthStore()
  return auth
}
