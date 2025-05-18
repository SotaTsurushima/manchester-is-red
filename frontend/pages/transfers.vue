<template>
  <Background>
    <Title title="Manchester United Transfer News" subtitle="Latest Trusted Reports" />
    <LoadingSpinner v-if="loading" message="Loading transfer news..." />
    <ErrorMessage
      v-else-if="error"
      :message="'Failed to load transfer news. Please try again later.'"
    />
    <EmptyState
      v-else-if="!hasNews"
      title="No Transfer News"
      message="There are currently no transfer updates available. Check back later for the latest news."
      buttonText="Refresh News"
      :onClick="refreshNews"
    />
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
  </Background>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '../composables/api'
import Card from '../components/Card.vue'
import LoadingSpinner from '../components/LoadingSpinner.vue'
import ErrorMessage from '../components/ErrorMessage.vue'
import Title from '../components/Title.vue'
import EmptyState from '../components/EmptyState.vue'
import Background from '../components/Background.vue'

const api = useApi()
const transfers = ref({})
const loading = ref(true)
const error = ref(null)

const hasNews = computed(() => {
  return Object.values(transfers.value).some(source => source.data?.length > 0)
})

const formatSourceName = name => {
  return name.replace('_', ' ')
}

const refreshNews = async () => {
  loading.value = true
  error.value = null
  try {
    const response = await api.get('/transfers')
    transfers.value = response.data.data
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
