<template>
  <Background>
    <div class="max-w-2xl mx-auto mt-8">
      <Title title="Batch Jobs" />
      <div class="space-y-4 mt-6">
        <button
          class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700 transition w-full disabled:opacity-50 disabled:cursor-not-allowed"
          @click="runBatch('matches')"
          :disabled="loading.matches"
        >
          <span v-if="loading.matches">Running...</span>
          <span v-else>Run Matches Batch</span>
        </button>
        <button
          class="bg-green-600 text-white px-4 py-2 rounded hover:bg-green-700 transition w-full disabled:opacity-50 disabled:cursor-not-allowed"
          @click="runBatch('players_stats')"
          :disabled="loading.players_stats"
        >
          <span v-if="loading.players_stats">Running...</span>
          <span v-else>Run Players Stats Batch</span>
        </button>
        <button
          class="bg-yellow-600 text-white px-4 py-2 rounded hover:bg-yellow-700 transition w-full disabled:opacity-50 disabled:cursor-not-allowed"
          @click="runBatch('teams')"
          :disabled="loading.teams"
        >
          <span v-if="loading.teams">Running...</span>
          <span v-else>Run Teams Batch</span>
        </button>
      </div>
    </div>
  </Background>
</template>

<script setup>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import Background from '@/components/Background.vue'
import Title from '@/components/Title.vue'
import { useApi } from '@/composables/api'

const api = useApi()
const loading = ref({
  matches: false,
  players_stats: false,
  teams: false
})

const runBatch = async type => {
  loading.value[type] = true
  let endpoint = ''
  if (type === 'matches') endpoint = '/admin/batch/matches'
  if (type === 'players_stats') endpoint = '/admin/batch/players_stats'
  if (type === 'teams') endpoint = '/admin/batch/teams'

  try {
    const res = await api.post(endpoint)
    if (res.success) {
      ElMessage.success(res.message || 'Batch started successfully!')
    } else {
      ElMessage.error(res.error || 'Failed to start batch.')
    }
  } catch (e) {
    ElMessage.error(e.message || 'An error occurred while starting the batch.')
  } finally {
    loading.value[type] = false
  }
}
</script>
