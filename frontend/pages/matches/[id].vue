<template>
  <Background>
    <div class="max-w-screen-md mx-auto p-6 bg-gray-900 text-white rounded-lg shadow-lg">
      <div v-if="loading">Loading...</div>
      <div v-else-if="error">{{ error }}</div>
      <div v-else>
        <h2 class="text-2xl font-bold mb-4">
          {{ match.home_team?.name }} vs {{ match.away_team?.name }}
        </h2>
        <div class="flex justify-between items-center mb-4">
          <div class="flex items-center">
            <img
              v-if="match.home_team?.crest_url"
              :src="match.home_team.crest_url"
              alt="Home Team Crest"
              class="w-10 h-10 mr-2"
            />
            <span class="text-xl font-semibold">{{ match.home_team?.name }}</span>
          </div>
          <div class="text-2xl font-bold">
            {{ match.score }}
          </div>
          <div class="flex items-center">
            <span class="text-xl font-semibold">{{ match.away_team?.name }}</span>
            <img
              v-if="match.away_team?.crest_url"
              :src="match.away_team.crest_url"
              alt="Away Team Crest"
              class="w-10 h-10 ml-2"
            />
          </div>
        </div>
        <div class="mb-2">Date: {{ formatDateTime(match.utc_date, 'date') }}</div>
        <div class="mb-2">Venue: {{ match.venue }}</div>
        <div class="mb-2">Status: {{ match.status }}</div>
        <div class="mb-2">Referee: {{ match.referees }}</div>
        <div class="mb-2">Competition: {{ match.competition }}</div>
        <div v-if="match.goals && match.goals.length > 0" class="mt-4">
          <h4 class="font-semibold mb-2">Goals:</h4>
          <ul>
            <li v-for="goal in match.goals" :key="goal.minute">
              {{ goal.minute }}' {{ goal.scorer }} ({{ goal.team }})
            </li>
          </ul>
        </div>
      </div>
    </div>
  </Background>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useApi } from '../../composables/api'
import Background from '../../components/Background.vue'

const route = useRoute()
const api = useApi()
const match = ref({})
const loading = ref(true)
const error = ref(null)

function formatDateTime(utc_date, type = 'date') {
  const date = new Date(utc_date)
  return type === 'date'
    ? date.toLocaleDateString('en-US', {
        year: 'numeric',
        month: 'long',
        day: 'numeric',
        weekday: 'long'
      })
    : date.toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit',
        hour12: true
      })
}

onMounted(async () => {
  loading.value = true
  try {
    const response = await api.get(`/matches/${route.params.id}`)
    match.value = response.match
    console.log("🚀 ~ onMounted ~ response:", response)
  } catch (err) {
    error.value = 'Failed to load match details'
  } finally {
    loading.value = false
  }
})
</script>
