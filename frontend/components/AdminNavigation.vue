<template>
  <nav class="bg-gray-800 text-white p-4">
    <div class="max-w-7xl mx-auto flex justify-between items-center">
      <div class="flex items-center space-x-8">
        <h1 class="text-xl font-bold">Dashboard</h1>
        <div class="flex space-x-4">
          <NuxtLink
            to="/admin"
            class="hover:text-blue-300 transition"
            :class="{ 'text-blue-300': $route.path === '/admin' }"
          >
            Dashboard
          </NuxtLink>
          <NuxtLink
            to="/admin/players"
            class="hover:text-blue-300 transition"
            :class="{ 'text-blue-300': $route.path.startsWith('/admin/players') }"
          >
            Players
          </NuxtLink>
          <NuxtLink
            to="/admin/batch"
            class="hover:text-blue-300 transition"
            :class="{ 'text-blue-300': $route.path.startsWith('/admin/matches') }"
          >
            Batches
          </NuxtLink>
        </div>
      </div>
      <div class="flex items-center space-x-4">
        <span v-if="auth.user" class="mr-2">
          Logined as {{ auth.user.name || auth.user.email }}
        </span>
        <NuxtLink
          to="/"
          class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition"
        >
          Back to Site
        </NuxtLink>
        <button
          @click="handleLogout"
          class="bg-gray-600 text-white px-4 py-2 rounded hover:bg-gray-700 transition"
        >
          Logout
        </button>
      </div>
    </div>
  </nav>
</template>

<script setup lang="ts">
import { useAuthStore } from '~/stores/auth'
const auth = useAuthStore()

const handleLogout = () => {
  auth.logout()
  window.location.href = '/admin/login'
}
</script>
