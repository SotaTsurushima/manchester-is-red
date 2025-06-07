<template>
  <Background>
    <div class="matches mx-auto p-5 max-w-screen-lg">
      <Title title="Manchester United Matches" />
      <div class="flex justify-center space-x-4 mb-6">
        <button
          v-for="competition in competitions"
          :key="competition.id"
          @click="selectCompetition(competition.id)"
          :class="[
            'px-4 py-2 rounded-lg transition-all duration-200',
            selectedCompetition === competition.id
              ? 'bg-red-600 text-white'
              : 'bg-gray-700 text-gray-300 hover:bg-gray-600'
          ]"
        >
          {{ competition.name }}
          <span
            v-if="competition.id === selectedCompetition"
            class="ml-2 text-xs bg-white text-red-600 px-2 py-1 rounded-full"
          >
            Active
          </span>
        </button>
      </div>

      <LoadingSpinner v-if="loading" message="Loading matches..." />
      <ErrorMessage v-else-if="error" :message="error" />

      <!-- 試合一覧 -->
      <div v-else>
        <div v-if="matches.length === 0" class="text-center text-xl text-gray-400">
          No matches found for {{ selectedCompetition }}.
        </div>
        <div v-for="match in matches" :key="match.id">
          <NuxtLink :to="`/matches/${match.id}`" class="block">
            <div
              class="text-center match-item p-5 mb-4 rounded-lg bg-gray-800 text-white shadow-lg hover:shadow-2xl transition-all duration-200"
            >
              <!-- 試合日時と主審 -->
              <div class="text-center text-sm text-gray-400 mb-2 text-left">
                <div>Date: {{ formatDateTime(match.utc_date, 'date') }}</div>
                <div v-if="match.referees && match.referees.length > 0">
                  Referee: {{ match.referees }}
                </div>
                <div v-if="match.venue">Venue: {{ match.venue }}</div>
              </div>

              <!-- チーム情報とスコア -->
              <div class="flex justify-between items-center">
                <!-- ホームチーム -->
                <div class="flex items-center flex-1">
                  <img
                    v-if="match.home_team?.crest_url"
                    :src="match.home_team.crest_url"
                    alt="Home Team Crest"
                    class="w-8 h-8 mr-2 inline-block align-middle"
                  />
                  <span class="text-xl font-semibold">{{ match.home_team?.name }}</span>
                </div>

                <div class="flex-none px-4">
                  <div v-if="match.status" class="text-2xl font-bold">
                    {{ displayScore(match) }}
                  </div>
                  <div v-else class="text-2xl font-bold text-yellow-500">
                    {{ formatDateTime(match.utc_date, 'time') }}
                  </div>
                </div>

                <!-- アウェイチーム -->
                <div class="flex items-center flex-1 justify-end">
                  <span class="text-xl font-semibold">{{ match.away_team?.name }}</span>
                  <img
                    v-if="match.away_team?.crest_url"
                    :src="match.away_team.crest_url"
                    alt="Away Team Crest"
                    class="w-8 h-8 ml-2 inline-block align-middle"
                  />
                </div>
              </div>

              <!-- 試合詳細（得点者など） -->
              <div v-if="match.goals && match.goals.length > 0" class="mt-4 text-sm">
                <h4 class="font-semibold mb-2">Goals:</h4>
                <div class="grid grid-cols-2 gap-2">
                  <div class="text-left">
                    <div
                      v-for="goal in getGoals(match, 'HOME')"
                      :key="goal.minute"
                      class="text-gray-300"
                    >
                      ⚽ {{ goal.minute }}' {{ goal.scorer }}
                    </div>
                  </div>
                  <div class="text-right">
                    <div
                      v-for="goal in getGoals(match, 'AWAY')"
                      :key="goal.minute"
                      class="text-gray-300"
                    >
                      {{ goal.scorer }} {{ goal.minute }}' ⚽
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </NuxtLink>
        </div>
      </div>

      <div v-if="total > 0" class="flex justify-center mt-6">
        <el-pagination
          v-model:current-page="currentPage"
          :page-size="10"
          :total="total"
          layout="prev, pager, next"
          @current-change="goToPage"
        />
      </div>
    </div>
  </Background>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useApi } from '../../composables/api'
import LoadingSpinner from '../components/LoadingSpinner.vue'
import ErrorMessage from '../components/ErrorMessage.vue'
import Title from '../components/Title.vue'
import Background from '../components/Background.vue'

const api = useApi()
const matches = ref([])
const loading = ref(true)
const error = ref(null)
const selectedCompetition = ref('Premier League')
const currentPage = ref(1)
const total = ref(0)

const competitions = [
  { id: 'Premier League', name: 'Premier League' },
  { id: 'Europa Lg', name: 'Europa League' },
  { id: 'FA Cup', name: 'FA Cup' },
  { id: 'EFL Cup', name: 'League Cup' }
]

// 日付と時間のフォーマット
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

function getGoals(match, team) {
  return match.goals?.filter(goal => goal.team === team) || []
}

function displayScore(match) {
  if (!match.score) return ''
  const [home, away] = match.score.split('-').map(s => s.trim())
  if (match.away_team?.name === 'Manchester United') {
    return `${away} - ${home}`
  }
  return match.score
}

const fetchMatches = async () => {
  loading.value = true
  error.value = null

  try {
    const params = new URLSearchParams({
      competition_id: selectedCompetition.value,
      page: currentPage.value,
      per_page: 10
    })
    const response = await api.get(`/matches?${params.toString()}`)
    matches.value = response.matches?.matches || []
    total.value = response.matches?.total || 0
  } catch (err) {
    matches.value = []
    error.value = 'Failed to load matches'
    console.error('Error fetching matches:', err)
  } finally {
    loading.value = false
  }
}

function selectCompetition(competitionId) {
  selectedCompetition.value = competitionId
  currentPage.value = 1 // ページをリセット
  fetchMatches()
}

function goToPage(page) {
  if (page < 1) return
  currentPage.value = page
  fetchMatches()
}

onMounted(() => {
  fetchMatches()
})
</script>

<style scoped>
.match-item {
  transition: transform 0.2s ease;
}

.match-item:hover {
  transform: translateY(-2px);
}

:deep(.el-pagination) {
  @apply bg-gray-900 rounded-lg px-6 py-2 shadow-lg flex justify-center;
}
:deep(.el-pagination .el-pager li) {
  @apply bg-black text-red-700 rounded font-bold mx-1 transition cursor-pointer border border-gray-300 hover:bg-red-100;
}
:deep(.el-pagination .el-pager li.is-active) {
  @apply bg-red-700 text-white border-red-700;
}
:deep(.el-pagination button) {
  @apply bg-black text-red-700 rounded font-bold mx-1 transition border border-gray-300 px-2 hover:bg-red-100;
}
:deep(.el-pagination button:disabled) {
  @apply opacity-50 cursor-not-allowed;
}
</style>
