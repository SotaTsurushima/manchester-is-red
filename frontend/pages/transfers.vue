<template>
  <div class="bg-gradient-to-b from-red-900 to-black min-h-screen py-12 px-4">
    <div class="max-w-7xl mx-auto">
      <!-- ヘッダー -->
      <h1 class="text-4xl font-bold text-white mb-8 text-center">Manchester United News</h1>

      <!-- ニュース一覧 -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="item in transfers.data"
          :key="item.url"
          class="bg-white rounded-lg overflow-hidden shadow-lg hover:shadow-xl transition-shadow duration-300"
        >
          <!-- 画像セクション -->
          <div class="relative h-48 overflow-hidden">
            <img
              v-if="item.image"
              :src="item.image"
              :alt="item.title"
              class="w-full h-full object-cover opacity-100 transition-opacity duration-300"
            />
            <div v-else class="w-full h-full bg-gray-200 flex items-center justify-center">
              <span class="text-gray-400">No image available</span>
            </div>

            <!-- 日付表示 -->
            <div
              v-if="item.date"
              class="absolute bottom-0 left-0 bg-red-600 text-white px-3 py-1 text-sm"
            >
              {{ item.date }}
            </div>
          </div>

          <!-- ニュース内容 -->
          <div class="p-4">
            <!-- タイトル -->
            <template v-if="item.title">
              <h2 class="text-xl font-bold mb-2 line-clamp-2 overflow-hidden">{{ item.title }}</h2>
            </template>
            <template v-else>
              <h2 class="text-xl font-bold mb-2 text-gray-400">No Title Available</h2>
            </template>

            <!-- 日付（画像セクションの日付が表示されない場合のバックアップ） -->
            <div v-if="item.date && !item.image" class="text-sm text-gray-500 mb-2">
              {{ item.date }}
            </div>

            <!-- リンク -->
            <div v-if="item.url" class="flex justify-end mt-4">
              <a
                :href="item.url"
                target="_blank"
                rel="noopener noreferrer"
                class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition-colors duration-300"
              >
                Read More
              </a>
            </div>
          </div>
        </div>
      </div>

      <!-- ローディング表示 -->
      <div v-if="loading" class="text-center py-8">
        <div
          class="inline-block animate-spin rounded-full h-8 w-8 border-t-2 border-b-2 border-red-600"
        ></div>
        <p class="text-white mt-2">Loading news...</p>
      </div>

      <!-- エラー表示 -->
      <div v-if="error" class="text-center py-8 text-red-500">
        {{ error }}
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '../composables/api'

const api = useApi()
const transfers = ref([])
const loading = ref(true)
const error = ref(null)

const fetchTransfers = async () => {
  try {
    const response = await api.get('/transfers')
    transfers.value = response.data || []
  } catch (err) {
    error.value = 'Failed to load news'
    console.error('Error fetching news:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  fetchTransfers()
})
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
