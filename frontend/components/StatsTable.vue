<template>
  <div class="bg-[#18191A] min-h-screen text-white p-6">
    <div class="max-w-2xl mx-auto">
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
      <StatsList
        v-if="activeTab === 'Goals'"
        :players="topScorers"
        stat-label="Goals"
        stat-key="goals"
      />
      <!-- 他のタブも同様に追加可能 -->
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import StatsList from '~/components/StatsList.vue'

const tabs = ['Goals', 'Assists', 'Yellow cards', 'Red cards']
const activeTab = ref('Goals')

const topScorers = [
  {
    rank: 1,
    name: 'Mohamed Salah',
    team: 'Liverpool',
    teamLogo: '/teams/liverpool.png',
    goals: 28,
    photo: '/players/salah.png'
  }
  // ...他の選手
]
</script>
