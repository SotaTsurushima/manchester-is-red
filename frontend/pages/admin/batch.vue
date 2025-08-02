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

      <!-- 処理状況表示エリア -->
      <div v-if="processingStatus" class="mt-6 p-4 bg-gray-100 rounded">
        <h3 class="font-semibold mb-2">処理状況</h3>
        <p>{{ processingStatus }}</p>
        <p class="text-sm text-gray-600 mt-2">処理完了まで数分かかる場合があります</p>
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

const processingStatus = ref('')

const runBatch = async type => {
  loading.value[type] = true
  processingStatus.value = 'バッチ処理を開始しました...'

  let endpoint = ''
  if (type === 'matches') endpoint = '/admin/batch/matches'
  if (type === 'players_stats') endpoint = '/admin/batch/players_stats'
  if (type === 'teams') endpoint = '/admin/batch/teams'

  try {
    const res = await api.post(endpoint)
    if (res.success) {
      ElMessage.success(res.message || 'Batch started successfully!')
      processingStatus.value = '処理中です。完了までお待ちください...'

      // 3秒後に完了メッセージを表示
      setTimeout(() => {
        processingStatus.value = '処理が完了しました！'
        ElMessage.success('バッチ処理が完了しました')
      }, 3000)
    } else {
      ElMessage.error(res.error || 'Failed to start batch.')
      processingStatus.value = ''
    }
  } catch (e) {
    ElMessage.error(e.message || 'An error occurred while starting the batch.')
    processingStatus.value = ''
  } finally {
    loading.value[type] = false
  }
}
</script>
