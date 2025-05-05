<template>
  <Background>
    <div class="max-w-xl mx-auto mt-12 bg-white rounded shadow p-8">
      <NuxtLink
        to="/players"
        class="mb-4 inline-block bg-gray-700 text-white px-4 py-2 rounded hover:bg-gray-800 transition"
      >
        Back to List
      </NuxtLink>
      <div v-if="loading" class="text-blue-600">Loading...</div>
      <div v-else-if="error" class="text-red-600">{{ error }}</div>
      <div v-else-if="player" class="flex flex-col items-center">
        <img
          :src="player.image"
          :alt="player.name"
          class="w-48 h-48 object-contain rounded mb-4 bg-gray-100"
        />
        <h1 class="text-2xl font-bold mb-2">{{ player.name }}</h1>
        <p class="mb-1">
          <strong>Number:</strong>
          {{ player.number }}
        </p>
        <p class="mb-1">
          <strong>Position:</strong>
          {{ player.position }}
        </p>
      </div>
    </div>
  </Background>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { useApi } from '../../composables/api'
import Background from '../../components/Background.vue'

const route = useRoute()
const api = useApi()
const player = ref(null)
const loading = ref(true)
const error = ref('')

onMounted(async () => {
  try {
    const res = await api.get(`/players/${route.params.id}`)
    if (res.success) {
      player.value = res.data
    } else {
      error.value = res.error || 'Player not found'
    }
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
})
</script>
