<template>
  <div class="min-h-screen flex flex-col items-center justify-center bg-gray-100">
    <h1 class="text-2xl font-bold mb-4">画像アップロード</h1>
    <form @submit.prevent="handleUpload" class="bg-white p-6 rounded shadow-md w-full max-w-md">
      <input type="file" @change="onFileChange" accept="image/*" class="mb-4" />
      <button
        type="submit"
        :disabled="!selectedFile || loading"
        class="bg-blue-600 text-white px-4 py-2 rounded disabled:opacity-50"
      >
        アップロード
      </button>
      <div v-if="loading" class="mt-2 text-blue-600">アップロード中...</div>
      <div v-if="error" class="mt-2 text-red-600">{{ error }}</div>
      <div v-if="imageUrl" class="mt-4">
        <p>アップロード完了！</p>
        <img :src="imageUrl" alt="Uploaded" class="mt-2 max-h-48 rounded" />
      </div>
    </form>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '../composables/api'

const selectedFile = ref(null)
const imageUrl = ref('')
const loading = ref(false)
const error = ref('')

const api = useApi()

function onFileChange(e) {
  selectedFile.value = e.target.files[0]
  error.value = ''
}

async function handleUpload() {
  if (!selectedFile.value) return
  loading.value = true
  error.value = ''
  imageUrl.value = ''

  try {
    const formData = new FormData()
    formData.append('file', selectedFile.value)

    // injury.vueと同じAPI呼び出しスタイル
    const data = await api.post('/upload', formData, true)
    imageUrl.value = data.url // APIが返す画像URL
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}
</script>
