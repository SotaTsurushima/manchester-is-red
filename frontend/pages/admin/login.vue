<template>
  <Background>
    <div
      class="min-h-screen flex flex-col items-center justify-center bg-gradient-to-b from-[#7b1f1f] to-[#1a0000]"
    >
      <div class="w-full max-w-xl bg-white rounded-lg shadow-lg p-10">
        <h1 class="text-3xl font-bold text-center text-gray-900 mb-2">Admin Login</h1>
        <form class="space-y-6" @submit.prevent="onLogin">
          <div>
            <label for="email" class="block text-sm font-medium text-gray-700 mb-1">
              Email Address
            </label>
            <input
              id="email"
              v-model="email"
              name="email"
              type="email"
              autocomplete="email"
              required
              class="input"
              placeholder="Email"
            />
          </div>
          <div>
            <label for="password" class="block text-sm font-medium text-gray-700 mb-1">
              Password
            </label>
            <input
              id="password"
              v-model="password"
              name="password"
              type="password"
              autocomplete="current-password"
              required
              class="input"
              placeholder="Password"
            />
          </div>
          <button type="submit" class="btn btn-primary w-full">Sign In</button>
          <ErrorMessage v-if="error" :message="error" class="mt-2" />
        </form>
      </div>
    </div>
  </Background>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useAuthStore } from '~/stores/auth'
import Background from '~/components/Background.vue'
import ErrorMessage from '~/components/ErrorMessage.vue'

const auth = useAuthStore()
const email = ref('')
const password = ref('')
const error = ref('')

const onLogin = async () => {
  error.value = ''
  try {
    await auth.login(email.value, password.value, true)
    await navigateTo('/admin')
  } catch (e) {
    error.value = 'ログインに失敗しました。管理者アカウントでログインしてください。'
  }
}
</script>

<style scoped>
.input {
  @apply appearance-none rounded-md block w-full px-3 py-2 border border-gray-300 placeholder-gray-500 text-gray-900 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm;
}
.btn-primary {
  @apply bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-md focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500;
}
</style>
