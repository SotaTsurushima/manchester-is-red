<template>
  <div>
    <h1>Injury List Test Page</h1>
    <ul>
      <li v-for="injury in injuries" :key="injury.player">
        {{ injury.player }} - {{ injury.injury }} - {{ injury.return_date }}
      </li>
    </ul>
  </div>
</template>

<script setup>
import { ref } from 'vue'
const injuries = ref([
  { player: 'Lisandro Martínez', injury: 'Knee Injury', return_date: '2024-05-20' },
  { player: 'Luke Shaw', injury: 'Muscle Injury', return_date: '2024-06-01' }
])
</script>
