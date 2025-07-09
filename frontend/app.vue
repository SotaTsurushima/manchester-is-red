<template>
  <div>
    <!-- 管理画面以外でナビゲーションを表示 -->
    <Navigation v-if="!isAdminPage" />
    <NuxtPage />
  </div>
</template>

<script setup>
import Navigation from '~/components/Navigation.vue'
import { useRoute } from 'vue-router'

const route = useRoute()

// 管理画面かどうかを判定
const isAdminPage = route.path.startsWith('/admin')
</script>
