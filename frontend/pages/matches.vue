<template>
  <div class="matches mx-auto p-5 max-w-screen-lg bg-black">
    <h1 class="text-3xl font-bold mb-6 text-center text-white">Manchester United Matches</h1>
    <div v-if="loading" class="text-center text-xl text-white">Loading...</div>
    <div v-else>
      <div v-if="matches.length === 0" class="text-center text-xl text-gray-400">
        No matches found.
      </div>
      <div
        v-for="match in matches"
        :key="match.id"
        class="text-center match-item p-5 mb-4 border rounded-lg bg-gray-800 text-white shadow-lg hover:shadow-2xl"
      >
        <!-- 試合日時と主審 -->
        <div class="text-center text-sm text-gray-400 mb-2 text-left">
          <div>Date: {{ new Date(match.utcDate).toLocaleString() }}</div>
          <div v-if="match.referees && match.referees.length > 0">
            Referee: {{ match.referees[0].name }}
          </div>
        </div>
        <div class="flex justify-between items-center">
          <!-- 左側: ホームチームエンブレムと名前 -->
          <div class="flex items-center">
            <img
              v-if="match.homeTeam.crest"
              :src="match.homeTeam.crest"
              alt="Home Team Crest"
              class="w-8 h-8 mr-2"
            />
            <span class="text-xl font-semibold">{{ match.homeTeam.name }}</span>
          </div>

          <!-- 右側: アウェイチームエンブレムと名前 -->
          <div class="flex items-center">
            <span class="text-xl font-semibold">{{ match.awayTeam.name }}</span>
            <img
              v-if="match.awayTeam.crest"
              :src="match.awayTeam.crest"
              alt="Away Team Crest"
              class="w-8 h-8 ml-2"
            />
          </div>
        </div>

        <!-- スコア -->
        <div
          v-if="match.status === 'FINISHED'"
          class="text-center text-3xl font-bold text-white mt-2"
        >
          {{ match.score.fullTime.home }} - {{ match.score.fullTime.away }}
        </div>

        <!-- 得点者表示 -->
        <div v-if="match.goals && match.goals.length > 0" class="text-white mt-2">
          <h4 class="text-lg font-semibold">Goals:</h4>
          <ul class="mt-1 space-y-1 text-sm text-gray-300">
            {{
              match.goals
            }}
            <li v-for="(goal, index) in match.goals" :key="index">
              <span v-if="goal.team === 'HOME'" class="text-left block">
                ⚽ {{ goal.minute }}' {{ goal.scorer }} (Home)
              </span>
              <span v-else class="text-right block">
                ⚽ {{ goal.minute }}' {{ goal.scorer }} (Away)
              </span>
            </li>
          </ul>
        </div>

        <!-- ラインナップ表示（仮定） -->
        <div v-if="match.lineups && match.lineups.home.length > 0" class="mt-4">
          <h3 class="text-xl font-semibold text-white">Home Team Lineup</h3>
          <ul class="list-disc ml-5 text-gray-300">
            <li v-for="player in match.lineups.home" :key="player.id" class="text-lg">
              {{ player.name }}
            </li>
          </ul>
        </div>

        <div v-if="match.lineups && match.lineups.away.length > 0" class="mt-4">
          <h3 class="text-xl font-semibold text-white">Away Team Lineup</h3>
          <ul class="list-disc ml-5 text-gray-300">
            <li v-for="player in match.lineups.away" :key="player.id" class="text-lg">
              {{ player.name }}
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue';

const matches = ref([]);
const loading = ref(true);

async function fetchMatches() {
  try {
    const response = await fetch('http://localhost:8000/matches');
    const data = await response.json();
    matches.value = data.matches;
    console.log('🚀 ~ fetchMatches ~ matches.value:', matches.value);
    loading.value = false;
  } catch (error) {
    console.error('Error fetching matches:', error);
    loading.value = false;
  }
}

onMounted(() => {
  fetchMatches();
});
</script>

<style scoped>
body {
  background-color: #1a1a1a;
  color: #e0e0e0;
}
.match-item {
  background-color: #333;
  border-color: #444;
}
h1,
h2,
h3 {
  color: #ffffff;
}
</style>
