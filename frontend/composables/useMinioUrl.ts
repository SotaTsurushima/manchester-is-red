export const useMinioUrl = () => {
  // Nuxt 3では useRuntimeConfig() でenvやruntime configを取得
  const config = useRuntimeConfig()
  // public側に書いた場合は config.public.MINIO_BASE_URL
  return config.public.MINIO_BASE_URL
}
