<template>
  <Background>
    <div class="matches mx-auto p-5 max-w-screen-lg">
      <div class="match-item bg-gray-800 text-white rounded-lg shadow-lg p-5 mb-4">
        <div class="text-center text-sm text-gray-400 mb-2 text-left">
          <div>Date: {{ formatDateTime(match.utc_date, 'date') }}</div>
          <div v-if="match.referees && match.referees.length > 0">
            Referee: {{ match.referees }}
          </div>
          <div v-if="match.venue">Venue: {{ match.venue }}</div>
        </div>

        <div class="flex justify-between items-center mb-4">
          <div class="flex items-center flex-1">
            <img
              v-if="homeCrest || match.home_team?.crest_url"
              :src="homeCrest || match.home_team?.crest_url"
              alt="Home Team Crest"
              class="w-10 h-10 mr-2"
            />
            <span class="text-xl font-semibold">{{ homeName || match.home_team?.name }}</span>
          </div>
          <div class="flex-none px-4">
            <div class="text-2xl font-bold">
              {{ match.score }}
            </div>
          </div>
          <div class="flex items-center flex-1 justify-end">
            <span class="text-xl font-semibold">{{ awayName || match.away_team?.name }}</span>
            <img
              v-if="awayCrest || match.away_team?.crest_url"
              :src="awayCrest || match.away_team?.crest_url"
              alt="Away Team Crest"
              class="w-10 h-10 ml-2"
            />
          </div>
        </div>
        <div v-if="match.goals && match.goals.length > 0" class="mt-6 text-sm">
          <h4 class="font-semibold mb-2">Goals:</h4>
          <ul class="space-y-1">
            <li v-for="goal in match.goals" :key="goal.minute" class="text-center">
              {{ goal.minute }}' {{ goal.scorer }} ({{ goal.team }})
            </li>
          </ul>
        </div>
      </div>
    </div>
  </Background>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useApi } from '../../composables/api'
import Background from '../../components/Background.vue'

const route = useRoute()
const api = useApi()
const match = ref({})
const loading = ref(true)
const error = ref(null)

const homeName = computed(() => route.query.homeName)
const homeCrest = computed(() => route.query.homeCrest)
const awayName = computed(() => route.query.awayName)
const awayCrest = computed(() => route.query.awayCrest)

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
  } catch (err) {
    error.value = 'Failed to load match details'
  } finally {
    loading.value = false
  }
})
</script>
