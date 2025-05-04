<template>
  <div class="bg-gradient-to-b from-red-900 to-black min-h-screen py-12 px-4">
    <div class="max-w-7xl mx-auto">
      <Title title="Manchester United Players" subtitle="Squad List" />

      <!-- ポジション別セクション -->
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
                  title: player.name,
                  image: player.image,
                  description: position,
                  reliability: player.number,
                  date: '',
                  url: '#'
                }"
              />
            </div>
          </div>
        </template>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import Card from '../components/Card.vue'
import Title from '../components/Title.vue'

// 選手データ
const players = ref([
  {
    id: 1,
    name: 'Andre Onana',
    number: '24',
    position: 'Goalkeeper',
    image: '/images/bruno.jpeg'
  },
  {
    id: 2,
    name: 'Altay Bayindir',
    number: '1',
    position: 'Goalkeeper',
    image: '/images/bruno.jpeg'
  },
  {
    id: 3,
    name: 'Raphael Varane',
    number: '19',
    position: 'Defender',
    image: '/images/bruno.jpeg'
  },
  {
    id: 4,
    name: 'Bruno Fernandes',
    number: '8',
    position: 'Midfielder',
    image: '/images/bruno.jpeg'
  },
  {
    id: 5,
    name: 'Rasmus Hojlund',
    number: '11',
    position: 'Forward',
    image: '/images/bruno.jpeg'
  }
  // 他の選手も同様に追加
])

// ポジション別にグループ化
const groupedPlayers = computed(() => {
  const groups = {}
  const positions = ['Goalkeeper', 'Defender', 'Midfielder', 'Forward']

  positions.forEach(position => {
    groups[position] = players.value.filter(player => player.position === position)
  })

  return groups
})

onMounted(async () => {
  // 将来的にAPIからデータを取得する場合はここに実装
})
</script>
