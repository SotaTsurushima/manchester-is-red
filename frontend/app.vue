<template>
  <div>
    <client-only>
      <AdminNavigation v-if="user && user.role === 'admin'" />
      <Navigation v-else />
    </client-only>
    <NuxtPage />
  </div>
</template>

<script setup>
import Navigation from '~/components/Navigation.vue'
import AdminNavigation from '~/components/AdminNavigation.vue'
import { useAuthStore } from '~/stores/auth'
import { computed } from 'vue'

const auth = useAuthStore()
const user = computed(() => auth.user)
</script>
