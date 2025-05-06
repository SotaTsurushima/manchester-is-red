<template>
  <div
    class="bg-white rounded-lg overflow-hidden shadow-lg hover:shadow-xl transition-shadow duration-300"
  >
    <!-- 画像セクション -->
    <div class="relative w-full h-40 md:h-56 bg-gray-200 overflow-hidden">
      <img
        v-if="type === 'injury'"
        :src="item.image || '/images/bruno.jpeg'"
        :alt="item.player_name || item.player"
        class="absolute inset-0 w-full h-full object-contain"
        @error="handleImageError"
      />
      <img
        v-else
        :src="item.image || '/images/bruno.jpeg'"
        :alt="item.title"
        class="absolute inset-0 w-full h-full object-contain"
        @error="handleImageError"
      />
      <div
        class="absolute bottom-0 left-0 right-0 bg-black bg-opacity-50 text-white px-3 py-1 text-sm flex justify-between items-center"
      >
        <span class="flex items-center">
          <!-- ニュース用 -->
          <template v-if="type === 'news'">
            <span :class="['text-xs px-2 py-0.5 rounded mr-2', reliabilityColor]">
              {{ item.reliability }}
            </span>
            {{ formattedDate }}
          </template>
          <!-- 選手用 -->
          <template v-else-if="type === 'player'">
            <span class="bg-red-600 text-white text-lg font-bold px-2 py-0.5 rounded">
              #{{ item.reliability }}
            </span>
          </template>
        </span>
      </div>
    </div>

    <!-- ニュース内容 -->
    <div class="p-4">
      <!-- injury用 -->
      <template v-if="type === 'injury'">
        <h2 class="text-xl font-bold mb-2 line-clamp-2">{{ item.player_name || item.player }}</h2>
        <div class="flex flex-wrap gap-2 mb-2">
          <span
            v-if="item.injury"
            class="inline-flex items-center bg-red-100 text-red-800 text-xs font-semibold px-3 py-1 rounded-full border border-red-300"
          >
            <svg
              class="w-4 h-4 mr-1 text-red-500"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              viewBox="0 0 24 24"
            >
              <path
                d="M19 7l-.867 12.142A2 2 0 0 1 16.138 21H7.862a2 2 0 0 1-1.995-1.858L5 7m5-4h4a2 2 0 0 1 2 2v2H7V5a2 2 0 0 1 2-2zm0 0V3m0 0a2 2 0 0 1 2 2v2"
              ></path>
            </svg>
            Injury: {{ item.injury }}
          </span>
          <span
            v-if="item.return_date"
            class="inline-flex items-center bg-green-100 text-green-800 text-xs font-semibold px-3 py-1 rounded-full border border-green-300"
          >
            <svg
              class="w-4 h-4 mr-1 text-green-500"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              viewBox="0 0 24 24"
            >
              <path
                d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 0 0 2-2V7a2 2 0 0 0-2-2H5a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2z"
              ></path>
            </svg>
            Expected Return: {{ item.return_date }}
          </span>
          <span
            v-if="item.return_date"
            class="inline-flex items-center bg-blue-100 text-blue-800 text-xs font-semibold px-3 py-1 rounded-full border border-blue-300"
          >
            <svg
              class="w-4 h-4 mr-1 text-blue-500"
              fill="none"
              stroke="currentColor"
              stroke-width="2"
              viewBox="0 0 24 24"
            >
              <path d="M12 8v4l3 3"></path>
              <circle cx="12" cy="12" r="10"></circle>
            </svg>
            Days Until Return: {{ daysUntilReturn }} days
          </span>
        </div>
        <p v-if="item.fee" class="text-gray-600 mb-2">Fee: {{ item.fee }}</p>
      </template>
      <!-- ニュース内容・選手用 -->
      <template v-else>
        <h2 class="text-xl font-bold mb-2 line-clamp-2">{{ item.title }}</h2>
        <p v-if="item.description" class="text-gray-600 mb-4 line-clamp-2">
          {{ item.description }}
        </p>
        <div class="flex justify-end mt-4">
          <!-- ニュース用 -->
          <a
            v-if="type === 'news' && item.url !== '#'"
            :href="item.url"
            target="_blank"
            rel="noopener noreferrer"
            class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition-colors duration-300"
          >
            Read More
          </a>
          <!-- 選手用 -->
          <NuxtLink
            v-else-if="type === 'player'"
            :to="item.url"
            class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition-colors duration-300"
          >
            View Profile
          </NuxtLink>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  item: {
    type: Object,
    required: true
  },
  type: {
    type: String,
    default: 'player',
    validator: value => ['news', 'player', 'injury'].includes(value)
  }
})

const formattedDate = computed(() => {
  if (!props.item.date) return ''
  return new Date(props.item.date).toLocaleDateString('en-GB', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  })
})

const reliabilityColor = computed(() => {
  const colors = {
    'Tier 1': 'bg-green-500',
    'Tier 2': 'bg-blue-500',
    'Tier 3': 'bg-yellow-500',
    'Tier 4': 'bg-orange-500',
    'Tier 5': 'bg-red-500',
    default: 'bg-gray-500'
  }
  return colors[props.item.reliability] || colors.default
})

const daysUntilReturn = computed(() => {
  if (!props.item.return_date) return null
  const today = new Date()
  const returnDate = new Date(props.item.return_date)
  const diffTime = returnDate - today
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  return diffDays >= 0 ? diffDays : 0
})

const handleImageError = event => {
  event.target.style.display = 'none'
  event.target.parentElement.querySelector('.bg-gray-200').style.display = 'flex'
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
