<template>
  <div class="bg-gradient-to-b from-red-900 to-black min-h-screen py-12 px-4">
    <div class="max-w-7xl mx-auto">
      <!-- ヘッダー -->
      <h1 class="text-4xl font-bold text-white mb-8 text-center">Manchester United Transfers</h1>

      <!-- ニュース一覧 -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div
          v-for="item in transfers"
          :key="item.url"
          class="bg-white rounded-lg overflow-hidden shadow-lg hover:shadow-xl transition-shadow duration-300"
        >
          <!-- ニュース画像 -->
          <div class="relative h-48 overflow-hidden">
            <img
              :src="item.image_url || '/images/default-news.jpg'"
              :alt="item.title"
              class="w-full h-full object-cover"
            />
            <div class="absolute bottom-0 left-0 bg-red-600 text-white px-3 py-1 text-sm">
              {{ item.published_at }}
            </div>
          </div>

          <!-- ニュース内容 -->
          <div class="p-4">
            <h2 class="text-xl font-bold mb-2 line-clamp-2">{{ item.title }}</h2>
            <p class="text-gray-600 mb-4 line-clamp-3">{{ item.description }}</p>

            <!-- リンク -->
            <div class="flex justify-end">
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
        <p class="text-white mt-2">Loading transfers...</p>
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
    const data = await api.get('/transfers')
    transfers.value = data.transfers || []
  } catch (err) {
    error.value = 'Failed to load transfers'
    console.error('Error fetching transfers:', err)
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

.line-clamp-3 {
  display: -webkit-box;
  -webkit-line-clamp: 3;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
