<template>
  <div class="bg-gradient-to-b from-red-900 to-black min-h-screen py-12 px-4">
    <div class="max-w-7xl mx-auto">
      <!-- ヘッダー -->
      <h1 class="text-4xl font-bold text-white mb-8 text-center">First Team Squad</h1>

      <!-- ポジション別セクション -->
      <div class="space-y-12">
        <section v-for="(players, position) in groupedPlayers" :key="position" class="mb-12">
          <h2 class="text-2xl font-bold text-red-500 mb-6 uppercase">{{ position }}</h2>

          <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-6">
            <div
              v-for="player in players"
              :key="player.id"
              class="relative w-full h-64 sm:h-72 md:h-80 lg:h-80 group bg-black rounded-lg overflow-hidden shadow-lg border-2 border-gray-200"
            >
              <!-- 選手画像 -->
              <img
                :src="player.image"
                :alt="player.name"
                class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-110"
              />

              <!-- 背番号オーバーレイ -->
              <div
                class="absolute top-0 right-0 bg-red-600 text-white text-2xl font-bold p-2 m-2 rounded z-10"
              >
                {{ player.number }}
              </div>

              <!-- グラデーションオーバーレイ -->
              <div
                class="absolute inset-0 bg-gradient-to-t from-black/90 via-black/50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300"
              ></div>

              <!-- 選手情報オーバーレイ -->
              <div
                class="absolute bottom-0 left-0 right-0 p-4 text-white transform translate-y-full group-hover:translate-y-0 transition-transform duration-300"
              >
                <h3 class="text-xl font-bold mb-1">{{ player.name }}</h3>
                <p class="text-gray-400 text-sm">{{ position }}</p>
              </div>
            </div>
          </div>
        </section>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'

// 選手データ
const players = ref([
  {
    id: 1,
    name: 'Andre Onana',
    number: '24',
    position: 'Goalkeeper',
    image:
      'https://assets.manutd.com/AssetPicker/images/0/0/18/126/1280093/Player_Profile_Thumbnail_Mens_2324_Kit_Onana1689603010606.jpg'
  },
  {
    id: 2,
    name: 'Altay Bayindir',
    number: '1',
    position: 'Goalkeeper',
    image:
      'https://assets.manutd.com/AssetPicker/images/0/0/18/126/1280094/Player_Profile_Thumbnail_Mens_2324_Kit_Bayindir1693568411772.jpg'
  },
  {
    id: 3,
    name: 'Raphael Varane',
    number: '19',
    position: 'Defender',
    image:
      'https://assets.manutd.com/AssetPicker/images/0/0/18/126/1280125/Player_Profile_Thumbnail_Mens_2324_Kit_Varane1689603012894.jpg'
  },
  {
    id: 4,
    name: 'Bruno Fernandes',
    number: '8',
    position: 'Midfielder',
    image:
      'https://assets.manutd.com/AssetPicker/images/0/0/18/126/1280099/Player_Profile_Thumbnail_Mens_2324_Kit_Bruno1689603011167.jpg'
  },
  {
    id: 5,
    name: 'Rasmus Hojlund',
    number: '11',
    position: 'Forward',
    image:
      'https://assets.manutd.com/AssetPicker/images/0/0/18/126/1280119/Player_Profile_Thumbnail_Mens_2324_Kit_Hojlund1691507055949.jpg'
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

<style scoped>
.square-container {
  position: relative;
  width: 100%;
  height: 0;
  padding-bottom: 100%; /* これにより正方形になります */
  overflow: hidden;
}

.square-container img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.square-container div {
  position: absolute;
}
</style>
