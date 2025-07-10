<template>
  <div>
    <!-- 管理画面専用のナビゲーション -->
    <nav class="bg-gray-800 text-white p-4">
      <div class="max-w-7xl mx-auto flex justify-between items-center">
        <div class="flex items-center space-x-8">
          <h1 class="text-xl font-bold">Dashboard</h1>
          <div class="flex space-x-4">
            <NuxtLink
              to="/admin"
              class="hover:text-blue-300 transition"
              :class="{ 'text-blue-300': $route.path === '/admin' }"
            >
              dashboard
            </NuxtLink>
            <NuxtLink
              to="/admin/players"
              class="hover:text-blue-300 transition"
              :class="{ 'text-blue-300': $route.path.startsWith('/admin/players') }"
            >
              Players
            </NuxtLink>
            <NuxtLink
              to="/admin/matches"
              class="hover:text-blue-300 transition"
              :class="{ 'text-blue-300': $route.path.startsWith('/admin/matches') }"
            >
              matches
            </NuxtLink>
          </div>
        </div>
        <NuxtLink
          to="/"
          class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition"
        >
          サイトに戻る
        </NuxtLink>
      </div>
    </nav>

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

      <!-- 最近の試合 -->
      <div class="mb-8">
        <h2 class="text-2xl font-bold text-white mb-6">最近の試合</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div
            v-for="match in recentMatches"
            :key="match.id"
            class="bg-white bg-opacity-10 rounded-lg p-4"
          >
            <h3 class="text-lg font-bold text-white mb-2">
              {{ match.home_team.name }} vs {{ match.away_team.name }}
            </h3>
            <p class="text-gray-300 mb-1">{{ match.competition }}</p>
            <p class="text-gray-300 mb-2">{{ formatDate(match.utc_date) }}</p>
            <p class="text-xl font-bold text-white">{{ match.score || '未実施' }}</p>
          </div>
        </div>
      </div>

      <!-- 得点ランキング -->
      <div class="mb-8">
        <h2 class="text-2xl font-bold text-white mb-6">得点ランキング</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div
            v-for="player in topScorers"
            :key="player.id"
            class="bg-white bg-opacity-10 rounded-lg p-4"
          >
            <h3 class="text-lg font-bold text-white mb-2">{{ player.name }}</h3>
            <p class="text-gray-300 mb-1">{{ player.goals }}得点</p>
            <p class="text-gray-300 mb-1">{{ player.assists }}アシスト</p>
            <p class="text-gray-300">MVP: {{ player.mvp }}回</p>
          </div>
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
