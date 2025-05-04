export const useApi = () => {
  const config = useRuntimeConfig()
  const baseUrl = config.public.baseUrl

  const get = async (endpoint: string) => {
    const response = await fetch(`${baseUrl}${endpoint}`)
    return response.json()
  }

  const post = async (endpoint: string, data: any, isFormData = false) => {
    const options: any = {
      method: 'POST',
      body: isFormData ? data : JSON.stringify(data),
    }
    if (!isFormData) {
      options.headers = { 'Content-Type': 'application/json' }
    }
    const response = await fetch(`${baseUrl}${endpoint}`, options)
    return response.json()
  }

  return {
    get,
    post
  }
}