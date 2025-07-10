<template>
  <Background>
    <Title title="Manchester United Players" subtitle="Squad List" />
    <div class="space-y-12">
      <template v-for="(players, position) in groupedPlayers" :key="position">
        <div v-if="players.length > 0" class="mb-12">
          <h2 class="text-2xl font-bold text-white mb-6 flex items-center">
            <span class="capitalize">{{ position }}</span>
          </h2>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            <Card
              v-for="player in players"
              :key="player.id"
              :item="{
                id: player.id,
                title: player.name,
                image: player.image,
                description: position,
                reliability: player.number,
              }"
              type="player"
            />
          </div>
        </div>
      </template>
    </div>
  </Background>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import Card from '../../components/Card.vue'
import Title from '../../components/Title.vue'
import { useApi } from '../../composables/api'
import Background from '../../components/Background.vue'

const api = useApi()
const players = ref([])

const groupedPlayers = computed(() => {
  const groups = {
    GK: [],
    DF: [],
    MF: [],
    FW: []
  }
  players.value.forEach(player => {
    if (groups[player.position]) {
      groups[player.position].push(player)
    }
  })
  return groups
})

onMounted(async () => {
  try {
    const res = await api.get('/players')
    if (res.success) {
      players.value = res.data
    } else {
      console.error(res.error || 'Failed to fetch players')
    }
  } catch (e) {
    console.error(e)
  }
})
</script>
