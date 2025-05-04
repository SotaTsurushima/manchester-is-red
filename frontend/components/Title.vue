<template>
  <h1 class="text-4xl font-bold text-white mb-8 text-center">
    {{ title }}
    <span v-if="subtitle" class="block text-lg mt-2 text-gray-300">{{ subtitle }}</span>
  </h1>
</template>

<script setup>
const props = defineProps({
  title: {
    type: String,
    required: true
  },
  subtitle: {
    type: String,
    default: ''
  }
})
</script>
