<template>
  <div
    class="bg-white rounded-lg overflow-hidden shadow-lg hover:shadow-xl transition-shadow duration-300"
  >
    <!-- 画像セクション -->
    <div class="relative h-48 overflow-hidden">
      <img
        v-if="item.image"
        :src="item.image"
        :alt="item.title"
        class="w-full h-full object-cover"
        @error="handleImageError"
      />
      <img v-else src="/images/bruno.jpeg" :alt="item.title" class="w-full h-full object-cover" />
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
        <button
          v-else-if="type === 'player'"
          class="bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition-colors duration-300"
        >
          View Profile
        </button>
      </div>
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
    validator: value => ['news', 'player'].includes(value)
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
