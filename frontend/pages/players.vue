<template>
  <div class="bg-gray-100 py-12">
    <h1 class="text-center text-4xl font-bold mb-8">Players List</h1>
    <div class="max-w-7xl mx-auto px-4">
      <div class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-8">
        <div
          v-for="player in players"
          :key="player.id"
          class="bg-white p-6 rounded-lg shadow-lg flex flex-col items-center"
        >
          <!-- 画像（正方形いっぱいに表示） -->
          <div class="w-48 h-48 bg-gray-200 overflow-hidden rounded-lg mb-4">
            <img :src="player.image" alt="Player" class="w-full h-full object-cover" />
          </div>

          <!-- 背番号と名前 -->
          <div class="text-center">
            <p class="text-3xl font-bold text-gray-900">{{ player.number }}</p>
            <p class="text-lg font-semibold text-gray-800">{{ player.name }}</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

// 選手データ（APIから取得する場合、仮のデータを使っています）
const players = ref([]);

// 猫のデータを保存するための変数
const cats = ref([]);

// APIから猫の画像を取得する関数
const fetchCats = async () => {
  try {
    const response = await fetch('https://api.thecatapi.com/v1/images/search?limit=6'); // 6枚の猫画像を取得
    const data = await response.json();
    cats.value = data.map((cat) => cat.url); // 画像のURLをcatsに保存
  } catch (error) {
    console.error('Error fetching cats:', error);
  }
};

// ここでは、ダミーデータを使っています。通常はAPIからデータを取得します。
// onMountedでfetchCatsを呼び、猫画像のURLが取得できてからplayersの情報を更新する
onMounted(async () => {
  await fetchCats(); // 猫の画像を取得する
  // 猫の画像が取得できてからplayers.valueを更新
  players.value = [
    {
      id: 1,
      name: 'Cristiano Ronaldo',
      number: '7',
      position: 'Forward',
      club: 'Manchester United',
      image: cats.value[0] || 'https://via.placeholder.com/300',
    },
    {
      id: 2,
      name: 'Paul Pogba',
      number: '6',
      position: 'Midfielder',
      club: 'Manchester United',
      image: cats.value[1] || 'https://via.placeholder.com/300',
    },
    {
      id: 3,
      name: 'Bruno Fernandes',
      number: '18',
      position: 'Midfielder',
      club: 'Manchester United',
      image: cats.value[2] || 'https://via.placeholder.com/300',
    },
    {
      id: 4,
      name: 'Harry Maguire',
      number: '5',
      position: 'Defender',
      club: 'Manchester United',
      image: cats.value[3] || 'https://via.placeholder.com/300',
    },
    {
      id: 5,
      name: 'David De Gea',
      number: '1',
      position: 'Goalkeeper',
      club: 'Manchester United',
      image: cats.value[4] || 'https://via.placeholder.com/300',
    },
  ];
});
</script>
