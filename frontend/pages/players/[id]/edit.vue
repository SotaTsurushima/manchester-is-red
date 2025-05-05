<template>
  <Background>
    <div class="max-w-2xl mx-auto">
      <div class="flex flex-col items-center mb-8">
        <Title title="Edit Player" subtitle="Update player information" />
        <NuxtLink
          :to="`/players`"
          class="bg-gray-700 text-white px-4 py-2 rounded hover:bg-gray-800 transition mb-4"
        >
          Back to Players
        </NuxtLink>
      </div>
      <form @submit.prevent="handleUpdate" class="bg-white p-6 rounded shadow-md w-full">
        <div class="mb-4">
          <label class="block mb-1 font-semibold">Name</label>
          <input
            type="text"
            v-model="playerName"
            required
            class="w-full border px-3 py-2 rounded"
            placeholder="Player Name"
          />
        </div>
        <div class="mb-4">
          <label class="block mb-1 font-semibold">Squad Number</label>
          <input
            type="number"
            v-model="playerNumber"
            required
            min="0"
            class="w-full border px-3 py-2 rounded"
            placeholder="7"
          />
        </div>
        <div class="mb-4">
          <label class="block mb-1 font-semibold">Position</label>
          <select v-model="playerPosition" required class="w-full border px-3 py-2 rounded">
            <option value="" disabled>Select Position</option>
            <option value="FW">FW</option>
            <option value="MF">MF</option>
            <option value="DF">DF</option>
            <option value="GK">GK</option>
          </select>
        </div>
        <div class="mb-4">
          <label class="block mb-1 font-semibold">Photo</label>
          <input type="file" @change="onFileChange" accept="image/*" class="w-full" />
          <div v-if="previewImage" class="mt-2">
            <img :src="previewImage" alt="Preview" class="max-h-48 rounded" />
          </div>
          <div v-else-if="currentImage" class="mt-2">
            <img :src="currentImage" alt="Current" class="max-h-48 rounded" />
          </div>
          <div v-if="selectedFile" class="mt-2 text-sm text-gray-600">
            Selected file: {{ selectedFile.name }}
          </div>
          <div v-else-if="currentImage" class="mt-2 text-sm text-gray-600">
            Current file: {{ extractFileName(currentImage) }}
          </div>
        </div>
        <div class="flex justify-end gap-4 mt-6">
          <button
            type="submit"
            :disabled="!playerName || !playerNumber || !playerPosition || loading"
            class="bg-blue-600 text-white px-4 py-2 rounded disabled:opacity-50"
          >
            Update
          </button>
          <button
            type="button"
            @click="handleDelete"
            class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition"
          >
            Delete
          </button>
        </div>
        <div v-if="loading" class="mt-2 text-blue-600">Updating...</div>
        <div v-if="error" class="mt-2 text-red-600">{{ error }}</div>
        <div v-if="success" class="mt-4 text-green-600 font-bold">Update Complete!</div>
      </form>
    </div>
  </Background>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useApi } from '../../../composables/api'
import Title from '../../../components/Title.vue'
import Background from '../../../components/Background.vue'

const route = useRoute()
const router = useRouter()
const api = useApi()

const playerName = ref('')
const playerNumber = ref('')
const playerPosition = ref('')
const selectedFile = ref(null)
const currentImage = ref('')
const previewImage = ref('')
const loading = ref(false)
const error = ref('')
const success = ref(false)

onMounted(async () => {
  try {
    const res = await api.get(`/players/${route.params.id}`)
    if (res.success) {
      playerName.value = res.data.name
      playerNumber.value = res.data.number
      playerPosition.value = res.data.position
      currentImage.value = res.data.image
    } else {
      error.value = res.error || 'Player not found'
    }
  } catch (e) {
    error.value = e.message
  }
})

function onFileChange(e) {
  selectedFile.value = e.target.files[0]
  if (selectedFile.value) {
    previewImage.value = URL.createObjectURL(selectedFile.value)
  } else {
    previewImage.value = ''
  }
  error.value = ''
}

async function handleUpdate() {
  if (!playerName.value || !playerNumber.value || !playerPosition.value) return
  loading.value = true
  error.value = ''
  success.value = false

  try {
    let formData
    let isFormData = false
    if (selectedFile.value) {
      formData = new FormData()
      const fields = {
        name: playerName.value,
        number: playerNumber.value,
        position: playerPosition.value,
        file: selectedFile.value,
        filename: selectedFile.value.name
      }
      Object.entries(fields).forEach(([key, value]) => {
        formData.append(key, value)
      })
      isFormData = true
    } else {
      formData = {
        name: playerName.value,
        number: playerNumber.value,
        position: playerPosition.value
      }
    }

    const res = await api.put(`/players/${route.params.id}`, formData, isFormData)
    if (res.success) {
      success.value = true
      setTimeout(() => {
        router.push(`/players/${route.params.id}`)
      }, 1000)
    } else {
      error.value = res.errors ? res.errors.join(', ') : res.error || 'Update failed'
    }
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

async function handleDelete() {
  if (!confirm('Are you sure you want to delete this player?')) return
  loading.value = true
  error.value = ''
  try {
    const res = await api.delete(`/players/${route.params.id}`)
    if (res.success) {
      router.push('/players')
    } else {
      error.value = res.error || 'Delete failed'
    }
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}

function extractFileName(url) {
  if (!url) return ''
  try {
    return url.split('/').pop()
  } catch {
    return ''
  }
}
</script>
