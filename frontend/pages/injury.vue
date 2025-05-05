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
      <Card v-for="injury in injuries" :key="injury.number" :item="injury" type="injury" />
    </div>
  </Background>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '../composables/api'
import Card from '../components/Card.vue'
import LoadingSpinner from '../components/LoadingSpinner.vue'
import ErrorMessage from '../components/ErrorMessage.vue'
import Title from '../components/Title.vue'
import EmptyState from '../components/EmptyState.vue'
import Background from '../../components/Background.vue'

const api = useApi()
const injuries = ref([])
const players = ref([])
const loading = ref(true)
const error = ref(null)

const fetchInjuries = async () => {
  loading.value = true
  error.value = null
  try {
    const data = await api.get('/injuries')
    let injuryList = (data.injuries || data.data || []).map(injury => ({ ...injury }))

    if (players.value.length === 0) {
      const res = await api.get('/players')
      if (res.success) {
        players.value = res.data
      }
    }

    injuryList = injuryList.map(injury => {
      const injuryNumber = String(injury.number).trim()
      const matchedPlayer = players.value.find(
        player => String(player.number).trim() === injuryNumber
      )
      return {
        ...injury,
        image: matchedPlayer ? matchedPlayer.image : undefined,
        player_name: matchedPlayer ? matchedPlayer.name : undefined
      }
    })
    injuries.value = injuryList
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
      players.value = res.data
    } else {
      console.error(res.error || 'Failed to fetch players')
    }
  } catch (e) {
    console.error(e)
  }
}

onMounted(async () => {
  await fetchPlayers()
  await fetchInjuries()
})
</script>
