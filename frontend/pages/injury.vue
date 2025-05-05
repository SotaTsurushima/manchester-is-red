<template>
  <Background>
    <Title title="Manchester United Injury List" subtitle="Latest Injury Updates" />
    <LoadingSpinner v-if="loading" message="Loading injuries..." />
    <ErrorMessage v-else-if="error" :message="error" />
    <EmptyState
        v-else-if="injuries.length === 0"
        title="No Injury Data"
        message="There are currently no injury updates available. Check back later for the latest info."
        buttonText="Refresh"
        :onClick="fetchInjuries"
      />
    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <Card v-for="injury in injuries" :key="injury.player" :item="injury" type="injury" />
    </div>
  </Background>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '../composables/api'
import { useMinioUrl } from '../composables/useMinioUrl'
import Card from '../components/Card.vue'
import LoadingSpinner from '../components/LoadingSpinner.vue'
import ErrorMessage from '../components/ErrorMessage.vue'
import Title from '../components/Title.vue'
import EmptyState from '../components/EmptyState.vue'
import Background from '../../components/Background.vue'

const api = useApi()
const minioUrl = useMinioUrl()
const injuries = ref([])
const players = ref([])
const loading = ref(true)
const error = ref(null)

const fetchInjuries = async () => {
  loading.value = true
  error.value = null
  try {
    const data = await api.get('/injuries')
    injuries.value = (data.injuries || data.data || []).map(injury => ({
      ...injury,
      image: injury.image || `${minioUrl}/players/bruno.jpeg`
    }))
  } catch (err) {
    error.value = 'Failed to load injuries'
    injuries.value = []
  } finally {
    loading.value = false
  }
}

const fetchPlayers = async () => {
  try {
    const res = await api.get('/players')
    if (res.success) {
      // players.value = res.data
      console.log('players:', players.value)
    } else {
      console.error(res.error || 'Failed to fetch players')
    }
  } catch (e) {
    console.error(e)
  }
}

onMounted(() => {
  fetchInjuries()
  fetchPlayers()
})
</script>
