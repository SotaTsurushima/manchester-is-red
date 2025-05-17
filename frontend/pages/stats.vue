<template>
  <Background>
    <div class="max-w-2xl mx-auto p-6">
      <Title title="Stats" />
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
      <StatsTable :players="players" :stat-label="statLabel" :stat-key="statKey" />
    </div>
  </Background>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { useApi } from '~/composables/api'
import Background from '~/components/Background.vue'
import Title from '~/components/Title.vue'
import LoadingSpinner from '~/components/LoadingSpinner.vue'
import StatsTable from '~/components/StatsTable.vue'

const tabs = ['Goals', 'Assists']
const activeTab = ref('Goals')
const loading = ref(true)
const players = ref([])

const statLabel = computed(() => activeTab.value)
const statKey = computed(() => (activeTab.value === 'Goals' ? 'goals' : 'assists'))

const api = useApi()

onMounted(async () => {
  const res = await api.get('/players')
  if (res.success) {
    players.value = res.data
  }
  loading.value = false
})
</script>
