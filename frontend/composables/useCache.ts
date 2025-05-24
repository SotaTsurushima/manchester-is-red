import { ref } from 'vue'

export function useCache(ttl = 5 * 60 * 1000) {
  const cache = ref(new Map())
  
  return {
    get: (key: string) => {
      const item = cache.value.get(key)
      if (!item || Date.now() - item.timestamp > ttl) {
        cache.value.delete(key)
        return null
      }
      return item.data
    },
    
    set: (key: string, data: any) => {
      cache.value.set(key, {
        data,
        timestamp: Date.now()
      })
    }
  }
}
