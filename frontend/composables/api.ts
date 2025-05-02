export const useApi = () => {
  const config = useRuntimeConfig()
  const baseUrl = config.public.baseUrl

  const get = async (endpoint: string) => {
    const response = await fetch(`${baseUrl}${endpoint}`)
    return response.json()
  }

  const post = async (endpoint: string, data: any) => {
    const response = await fetch(`${baseUrl}${endpoint}`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(data)
    })
    return response.json()
  }

  return {
    get,
    post
  }
}