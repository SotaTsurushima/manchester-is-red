<template>
  <div>
    <div class="flex justify-between px-4 py-2 text-gray-400 text-xs border-b border-gray-700">
      <span>Player</span>
      <span class="text-right">{{ statLabel }}</span>
    </div>
    <div
      v-for="player in players"
      :key="player.name"
      class="flex items-center px-4 py-3 border-b border-gray-800 last:border-b-0"
    >
      <span class="w-6 text-gray-400">{{ player.rank }}</span>
      <img :src="player.photo" alt="photo" class="w-9 h-9 rounded-full mr-3" />
      <div class="flex-1">
        <div class="font-medium text-white">{{ player.name }}</div>
      </div>
      <span class="w-10 text-right font-semibold text-white">{{ player[statKey] }}</span>
    </div>
  </div>
</template>

<script setup>
defineProps({
  players: Array,
  statLabel: String,
  statKey: String
})
</script>
