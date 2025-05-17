<template>
  <Background>
    <div class="max-w-2xl mx-auto p-6">
      <h2 class="text-2xl font-bold mb-4">Stats</h2>
      <div class="flex border-b border-gray-700 mb-2">
        <button
          v-for="tab in tabs"
          :key="tab"
          @click="activeTab = tab"
          :class="[
            'px-4 py-2 text-sm font-medium focus:outline-none',
            activeTab === tab ? 'border-b-2 border-white text-white' : 'text-gray-400'
          ]"
        >
          {{ tab }}
        </button>
      </div>
      <LoadingSpinner v-if="loading" />
      <StatsTable v-else :players="players" :stat-label="statLabel" :stat-key="statKey" />
    </div>
  </Background>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import Background from '~/components/Background.vue'
import LoadingSpinner from '~/components/LoadingSpinner.vue'
import StatsTable from '~/components/StatsTable.vue'

const tabs = ['Goals', 'Assists', 'Yellow cards', 'Red cards']
const activeTab = ref('Goals')
const loading = ref(true)

const topScorers = [
  {
    rank: 1,
    name: 'Mohamed Salah',
    team: 'Liverpool',
    teamLogo: '/teams/liverpool.png',
    goals: 28,
    photo: '/players/salah.png'
  },
  {
    rank: 2,
    name: 'Alexander Isak',
    team: 'Newcastle',
    teamLogo: '/teams/newcastle.png',
    goals: 23,
    photo: '/players/isak.png'
  }
  // ...他の選手
]

const statLabel = computed(() => {
  switch (activeTab.value) {
    case 'Goals':
      return 'Goals'
    case 'Assists':
      return 'Assists'
    case 'Yellow cards':
      return 'Yellow Cards'
    case 'Red cards':
      return 'Red Cards'
    default:
      return ''
  }
})

const statKey = computed(() => {
  switch (activeTab.value) {
    case 'Goals':
      return 'goals'
    case 'Assists':
      return 'assists'
    case 'Yellow cards':
      return 'yellowCards'
    case 'Red cards':
      return 'redCards'
    default:
      return ''
  }
})

const players = computed(() => {
  // activeTabに応じてデータを切り替え
  return topScorers
})

onMounted(() => {
  setTimeout(() => {
    loading.value = false
  }, 1200) // ローディングのデモ
})
</script>
