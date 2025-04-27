<template>
  <div>
    <h1>Manchester United Information</h1>
    <div v-if="teamData">
      <p>Name: {{ teamData.name }}</p>
      <p>Short Name: {{ teamData.shortName }}</p>
      <p>Founded: {{ teamData.founded }}</p>
      <p>Stadium: {{ teamData.stadium }}</p>
      <p>Country: {{ teamData.country }}</p>
    </div>
    <div v-else>
      <p>Loading...</p>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'

const teamData = ref(null)

onMounted(async () => {
  // const response = await fetch('http://localhost:8000/manchester_united')
  // if (response.ok) {
  //   teamData.value = await response.json()
  // } else {
  //   console.error('Failed to fetch data')
  // }
})
</script>

<style scoped>
h1 {
  color: #c8102e; /* Manchester United's red */
}
</style>