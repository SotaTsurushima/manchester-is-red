export const useApi = () => {
  const config = useRuntimeConfig()
  const baseUrl = config.public.baseUrl
  const auth = useAuthStore()

  const getAuthHeaders = () => {
    const headers: Record<string, string> = {}

    // 認証トークンがある場合は追加
    if (auth.tokenHeaders['access-token']) {
      headers['access-token'] = auth.tokenHeaders['access-token']
      headers['client'] = auth.tokenHeaders['client']
      headers['uid'] = auth.tokenHeaders['uid']
    }

    return headers
  }

  const get = async (endpoint: string) => {
    const headers = getAuthHeaders()
    const response = await fetch(`${baseUrl}${endpoint}`, { headers })
    return response.json()
  }

  const post = async (endpoint: string, data: any, isFormData = false) => {
    const headers = getAuthHeaders()
    const options: any = {
      method: 'POST',
      body: isFormData ? data : JSON.stringify(data),
      headers
    }
    if (!isFormData) {
      headers['Content-Type'] = 'application/json'
    }
    const response = await fetch(`${baseUrl}${endpoint}`, options)
    return response.json()
  }

  const put = async (endpoint: string, data: any, isFormData = false) => {
    const headers = getAuthHeaders()
    const options: any = {
      method: 'PUT',
      body: isFormData ? data : JSON.stringify(data),
      headers
    }
    if (!isFormData) {
      headers['Content-Type'] = 'application/json'
    }
    const response = await fetch(`${baseUrl}${endpoint}`, options)
    return response.json()
  }

  const del = async (endpoint: string) => {
    const headers = getAuthHeaders()
    const response = await fetch(`${baseUrl}${endpoint}`, {
      method: 'DELETE',
      headers
    })
    return response.json()
  }

  return {
    get,
    post,
    put,
    delete: del
  }
}
