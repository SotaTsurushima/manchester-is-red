<template>
  <Background>
    <div class="max-w-2xl mx-auto">
      <div class="flex flex-col items-center mb-8">
        <Title title="Add New Player" subtitle="Register a new Manchester United player" />
        <NuxtLink
          to="/players"
          class="bg-gray-700 text-white px-4 py-2 rounded hover:bg-gray-800 transition"
        >
          Back to List
        </NuxtLink>
      </div>
      <form @submit.prevent="handleRegister" class="bg-white p-6 rounded shadow-md w-full">
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
          <input type="file" @change="onFileChange" accept="image/*" required class="w-full" />
        </div>
        <button
          type="submit"
          :disabled="!playerName || !playerNumber || !playerPosition || !selectedFile || loading"
          class="bg-blue-600 text-white px-4 py-2 rounded disabled:opacity-50"
        >
          Register
        </button>
        <div v-if="loading" class="mt-2 text-blue-600">Registering...</div>
        <div v-if="error" class="mt-2 text-red-600">{{ error }}</div>
        <div v-if="success" class="mt-4">
          <p class="text-green-600 font-bold">Registration Complete!</p>
          <img :src="imageUrl" alt="Uploaded" class="mt-2 max-h-48 rounded" />
        </div>
      </form>
    </div>
  </Background>
</template>

<script setup>
import { ref } from 'vue'
import { useApi } from '../../composables/api'
import Title from '../../components/Title.vue'
import Background from '../../components/Background.vue'

const playerName = ref('')
const playerNumber = ref('')
const playerPosition = ref('')
const selectedFile = ref(null)
const imageUrl = ref('')
const loading = ref(false)
const error = ref('')
const success = ref(false)

const api = useApi()

function onFileChange(e) {
  selectedFile.value = e.target.files[0]
  error.value = ''
}

async function handleRegister() {
  if (!playerName.value || !playerNumber.value || !playerPosition.value || !selectedFile.value)
    return
  loading.value = true
  error.value = ''
  imageUrl.value = ''
  success.value = false

  try {
    const formData = new FormData()
    formData.append('name', playerName.value)
    formData.append('number', playerNumber.value)
    formData.append('position', playerPosition.value)
    formData.append('file', selectedFile.value)
    formData.append('filename', selectedFile.value.name)

    const data = await api.post('/players', formData, true)
    if (data.success) {
      imageUrl.value = data.data.url // サーバーのrender_successで返す場合
      success.value = true
    } else {
      error.value = data.errors ? data.errors.join(', ') : data.error || 'Registration failed'
    }
  } catch (e) {
    error.value = e.message
  } finally {
    loading.value = false
  }
}
</script>
