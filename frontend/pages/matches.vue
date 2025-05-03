<template>
  <div class="matches mx-auto p-5 max-w-screen-lg bg-black">
    <h1 class="text-3xl font-bold mb-6 text-center text-white">Manchester United Matches</h1>

    <!-- 大会選択トグル -->
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
        No matches found for {{ getCompetitionName(selectedCompetition) }}.
      </div>
      <div
        v-for="match in sortedMatches"
        :key="match.id"
        class="text-center match-item p-5 mb-4 rounded-lg bg-gray-800 text-white shadow-lg hover:shadow-2xl transition-all duration-200"
      >
        <!-- 試合日時と主審 -->
        <div class="text-center text-sm text-gray-400 mb-2 text-left">
          <div>Date: {{ formatDate(match.utcDate) }}</div>
          <div v-if="match.referees && match.referees.length > 0">
            Referee: {{ match.referees[0].name }}
          </div>
          <div v-if="match.venue">Venue: {{ match.venue }}</div>
        </div>

        <!-- チーム情報とスコア -->
        <div class="flex justify-between items-center">
          <!-- ホームチーム -->
          <div class="flex items-center flex-1">
            <img
              v-if="match.homeTeam.crest"
              :src="match.homeTeam.crest"
              :alt="match.homeTeam.name"
              class="w-8 h-8 mr-2"
            />
            <span class="text-xl font-semibold">{{ match.homeTeam.name }}</span>
          </div>

          <!-- スコア（中央） -->
          <div class="flex-none px-4">
            <div v-if="match.status === 'FINISHED'" class="text-2xl font-bold">
              {{ match.score.fullTime.home }} - {{ match.score.fullTime.away }}
            </div>
            <div v-else-if="match.status === 'IN_PLAY'" class="text-green-500">Live</div>
            <div v-else class="text-yellow-500">
              {{ formatTime(match.utcDate) }}
            </div>
          </div>

          <!-- アウェイチーム -->
          <div class="flex items-center flex-1 justify-end">
            <span class="text-xl font-semibold">{{ match.awayTeam.name }}</span>
            <img
              v-if="match.awayTeam.crest"
              :src="match.awayTeam.crest"
              :alt="match.awayTeam.name"
              class="w-8 h-8 ml-2"
            />
          </div>
        </div>

        <!-- 試合詳細（得点者など） -->
        <div v-if="match.goals && match.goals.length > 0" class="mt-4 text-sm">
          <h4 class="font-semibold mb-2">Goals:</h4>
          <div class="grid grid-cols-2 gap-2">
            <div class="text-left">
              <div v-for="goal in homeGoals(match)" :key="goal.minute" class="text-gray-300">
                ⚽ {{ goal.minute }}' {{ goal.scorer }}
              </div>
            </div>
            <div class="text-right">
              <div v-for="goal in awayGoals(match)" :key="goal.minute" class="text-gray-300">
                {{ goal.scorer }} {{ goal.minute }}' ⚽
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '../composables/api'
import LoadingSpinner from '../components/LoadingSpinner.vue'
import ErrorMessage from '../components/ErrorMessage.vue'

const api = useApi()
const matches = ref([])
const loading = ref(true)
const error = ref(null)
const selectedCompetition = ref('PL')

const competitions = [
  { id: 'PL', name: 'Premier League' },
  { id: 'CL', name: 'Champions League' }
  // { id: 'FA', name: 'FA Cup' },
  // { id: 'EFL', name: 'League Cup' }
  // { id: 'UEL', name: 'Europe League' }
]

const sortedMatches = computed(() => {
  const now = new Date()

  return [...matches.value].sort((a, b) => {
    const dateA = new Date(a.utcDate)
    const dateB = new Date(b.utcDate)

    // 未来の試合（これから行われる試合）
    const aIsFuture = dateA > now
    const bIsFuture = dateB > now

    // 両方とも未来の試合の場合は、より近い日付が先頭に
    if (aIsFuture && bIsFuture) {
      return dateA - dateB
    }
    // 両方とも過去の試合の場合は、より古い日付が後ろに
    else if (!aIsFuture && !bIsFuture) {
      return dateB - dateA
    }
    // 未来の試合を過去の試合より前に
    else {
      return aIsFuture ? -1 : 1
    }
  })
})

// 大会名を取得
function getCompetitionName(id) {
  const competition = competitions.find(c => c.id === id)
  return competition ? competition.name : ''
}

// 日付フォーマット
function formatDate(utcDate) {
  return new Date(utcDate).toLocaleDateString('ja-JP', {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    weekday: 'long'
  })
}

// 時刻フォーマット
function formatTime(utcDate) {
  return new Date(utcDate).toLocaleTimeString('ja-JP', {
    hour: '2-digit',
    minute: '2-digit'
  })
}

// ホームチームの得点者
function homeGoals(match) {
  return match.goals?.filter(goal => goal.team === 'HOME') || []
}

// アウェイチームの得点者
function awayGoals(match) {
  return match.goals?.filter(goal => goal.team === 'AWAY') || []
}

const fetchMatches = async () => {
  try {
    const data = await api.get('/matches')
    matches.value = data.matches
  } catch (err) {
    error.value = 'Failed to load matches'
    console.error('Error fetching matches:', err)
  } finally {
    loading.value = false
  }
}

function selectCompetition(competitionId) {
  selectedCompetition.value = competitionId
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
</style>
