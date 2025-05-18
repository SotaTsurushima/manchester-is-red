<template>
  <div>
    <div
      v-for="player in players"
      :key="player.name"
      class="flex items-center px-4 py-3 border-b border-gray-800 last:border-b-0"
    >
      <img :src="player.image" alt="photo" class="w-9 h-9 rounded-full mr-3" />
      <div class="flex-1">
        <div class="font-medium text-white">{{ player.name }}</div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  players: Array
})
</script>
