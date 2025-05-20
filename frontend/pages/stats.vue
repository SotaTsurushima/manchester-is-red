<template>
  <Background>
    <div class="max-w-2xl mx-auto p-6">
      <Title title="Stats" />
      <div class="flex border-b border-gray-700 mb-2 overflow-x-auto">
        <button
          v-for="tab in tabs"
          :key="tab.value"
          @click="activeTab = tab.value"
          :class="[
            'px-4 py-2 text-sm font-medium focus:outline-none whitespace-nowrap',
            activeTab === tab.value ? 'border-b-2 border-white text-white' : 'text-gray-400'
          ]"
        >
          {{ tab.label }}
        </button>
      </div>
      <LoadingSpinner v-if="loading" />
      <StatsTable
        :players="displayPlayers"
        :stat-label="statLabel"
        :stat-key="statKey"
        :format-value="formatValue"
      />
      <div v-if="!showAll && players.length > 5" class="flex justify-center mt-4">
        <button
          @click="showAll = true"
          class="px-4 py-2 bg-gray-700 text-white rounded hover:bg-gray-600 transition"
        >
          Show More
        </button>
      </div>
    </div>
  </Background>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useApi } from '~/composables/api'
import Background from '~/components/Background.vue'
import Title from '~/components/Title.vue'
import LoadingSpinner from '~/components/LoadingSpinner.vue'
import StatsTable from '~/components/StatsTable.vue'

const tabs = [
  { label: 'Goals', value: 'goals' },
  { label: 'Assists', value: 'assists' },
  { label: 'Yellow Cards', value: 'yellow_card' },
  { label: 'Red Cards', value: 'red_card' },
  { label: 'Appearances', value: 'appearances' },
  { label: 'Market Value', value: 'market_value' }
]

const activeTab = ref('goals')
const loading = ref(true)
const players = ref([])
const showAll = ref(false)

const statLabel = computed(() => {
  const tab = tabs.find(t => t.value === activeTab.value)
  return tab ? tab.label : ''
})

const statKey = computed(() => activeTab.value)

const formatValue = computed(() => {
  if (activeTab.value === 'market_value') {
    return value => `€${value}M`
  }
  return value => value ?? 0
})

const sortedPlayers = computed(() => {
  return [...players.value].sort((a, b) => {
    const aValue = a[statKey.value] || 0
    const bValue = b[statKey.value] || 0
    return bValue - aValue
  })
})

const displayPlayers = computed(() => {
  return showAll.value ? sortedPlayers.value : sortedPlayers.value.slice(0, 5)
})

const api = useApi()

onMounted(async () => {
  const res = await api.get('/players')
  if (res.success) {
    players.value = res.data
  }
  loading.value = false
})
</script>
