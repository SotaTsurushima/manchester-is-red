<template>
  <div class="bg-gradient-to-b from-red-900 to-black min-h-screen py-12 px-4">
    <div class="max-w-7xl mx-auto">
      <h1 class="text-4xl font-bold text-white mb-8 text-center">
        Manchester United Transfer News
        <span class="block text-lg mt-2 text-gray-300">Latest Trusted Reports</span>
      </h1>

      <LoadingSpinner v-if="loading" message="Loading transfer news..." />

      <ErrorMessage v-else-if="error" :message="'Failed to load transfer news. Please try again later.'" />

      <!-- データが空の場合 -->
      <div v-else-if="!hasNews" class="text-center py-12">
        <div class="bg-white/10 rounded-lg p-8 mx-4">
          <svg
            class="mx-auto h-12 w-12 text-gray-400"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9.5a2 2 0 00-2-2h-2"
            />
          </svg>
          <h3 class="mt-4 text-lg font-medium text-white">No Transfer News</h3>
          <p class="mt-2 text-gray-300">
            There are currently no transfer updates available. Check back later for the latest news.
          </p>
          <button
            @click="refreshNews"
            class="mt-4 bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition-colors duration-300"
          >
            Refresh News
          </button>
        </div>
      </div>

      <!-- ニュース一覧 -->
      <div v-else class="space-y-12">
        <template v-for="(source, sourceName) in transfers" :key="sourceName">
          <div v-if="source.data?.length > 0" class="mb-12">
            <h2 class="text-2xl font-bold text-white mb-6 flex items-center">
              <span class="capitalize">{{ formatSourceName(sourceName) }}</span>
            </h2>
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              <Card v-for="item in source.data" :key="item.url" :item="item" type="news" />
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '../composables/api'
import Card from '../components/Card.vue'
import LoadingSpinner from '../components/LoadingSpinner.vue'
import ErrorMessage from '../components/ErrorMessage.vue'

const api = useApi()
const transfers = ref({
  sky_sports: { data: [] },
})
const loading = ref(true)
const error = ref(null)

const hasNews = computed(() => {
  return transfers.value.sky_sports?.data?.length > 0 || transfers.value.romano?.data?.length > 0
})

const formatSourceName = name => {
  return name.replace('_', ' ')
}

const refreshNews = async () => {
  loading.value = true
  error.value = null
  try {
    const response = await api.get('/transfers')
    transfers.value = response.data
  } catch (err) {
    error.value = 'Failed to load news'
    console.error('Error fetching news:', err)
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  refreshNews()
})
</script>
