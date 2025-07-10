<template>
  <div>
    <!-- 管理画面のコンテンツ -->
    <Background>
      <div class="flex flex-col items-center mb-8">
        <Title title="Admin Page" subtitle="Dashboard" />
      </div>

      <!-- 簡単な統計表示 -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white bg-opacity-10 rounded-lg p-6 text-center">
          <h3 class="text-xl font-bold text-white mb-2">選手数</h3>
          <p class="text-3xl font-bold text-blue-400">{{ totalPlayers }}人</p>
        </div>
        <div class="bg-white bg-opacity-10 rounded-lg p-6 text-center">
          <h3 class="text-xl font-bold text-white mb-2">試合数</h3>
          <p class="text-3xl font-bold text-green-400">{{ totalMatches }}試合</p>
        </div>
        <div class="bg-white bg-opacity-10 rounded-lg p-6 text-center">
          <h3 class="text-xl font-bold text-white mb-2">チーム数</h3>
          <p class="text-3xl font-bold text-yellow-400">{{ totalTeams }}チーム</p>
        </div>
      </div>
    </Background>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import Title from '../../components/Title.vue'
import Background from '../../components/Background.vue'
import { useApi } from '../../composables/api'

const api = useApi()
const totalPlayers = ref(0)
const totalMatches = ref(0)
const totalTeams = ref(0)
const recentMatches = ref([])
const topScorers = ref([])

const formatDate = dateString => {
  return new Date(dateString).toLocaleDateString('ja-JP')
}

const fetchDashboardData = async () => {
  try {
    // 選手数
    const playersRes = await api.get('/players')
    if (playersRes.success) {
      totalPlayers.value = playersRes.data.length
      topScorers.value = playersRes.data.sort((a, b) => b.goals - a.goals).slice(0, 6)
    }

    // 試合数
    const matchesRes = await api.get('/matches')
    if (matchesRes.success) {
      totalMatches.value = matchesRes.data.length
      recentMatches.value = matchesRes.data
        .sort((a, b) => new Date(b.utc_date) - new Date(a.utc_date))
        .slice(0, 6)
    }

    // チーム数（仮の値）
    totalTeams.value = 20
  } catch (e) {
    console.error('Failed to fetch dashboard data:', e)
  }
}

onMounted(() => {
  fetchDashboardData()
})
</script>
