<template>
  <div class="bg-gradient-to-b from-red-900 to-black min-h-screen py-12 px-4">
    <div class="max-w-7xl mx-auto">
      <h1 class="text-4xl font-bold text-white mb-8 text-center">
        Manchester United Injury List
        <span class="block text-lg mt-2 text-gray-300">Latest Injury Updates</span>
      </h1>

      <LoadingSpinner v-if="loading" message="Loading injury news..." />

      <ErrorMessage v-else-if="error" :message="'Failed to load injuries. Please try again later.'" />

      <!-- データが空の場合 -->
      <div v-else-if="injuries.length === 0" class="text-center py-12">
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
          <h3 class="mt-4 text-lg font-medium text-white">No Injury Data</h3>
          <p class="mt-2 text-gray-300">
            There are currently no injury updates available. Check back later for the latest info.
          </p>
          <button
            @click="fetchInjuries"
            class="mt-4 bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition-colors duration-300"
          >
            Refresh
          </button>
        </div>
      </div>

      <!-- 怪我人カード一覧 -->
      <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <Card
          v-for="injury in injuries"
          :key="injury.player"
          :item="injuryCard(injury)"
          type="player"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '../composables/api'
import Card from '../components/Card.vue'
import LoadingSpinner from '../components/LoadingSpinner.vue'
import ErrorMessage from '../components/ErrorMessage.vue'

const api = useApi()
const injuries = ref([])
const loading = ref(true)
const error = ref(null)

const fetchInjuries = async () => {
  loading.value = true
  error.value = null
  try {
    const data = await api.get('/injuries')
    injuries.value = data.injuries || data.data || []
  } catch (err) {
    error.value = 'Failed to load injuries'
    injuries.value = []
  } finally {
    loading.value = false
  }
}

// Card用にinjuryデータを整形
const injuryCard = injury => ({
  title: injury.player,
  description: `${injury.injury}（復帰予定: ${injury.return_date}）`,
  image: '', // 画像があればURLをセット
  reliability: '' // 必要ならセット
})

onMounted(() => {
  fetchInjuries()
})
</script>
