<template>
  <div class="flex flex-col items-center justify-center py-12">
    <div class="inline-block animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-red-600"></div>
    <p class="text-white mt-4 text-lg">{{ message }}</p>
  </div>
</template>

<script setup>
const props = defineProps({
  message: {
    type: String,
    default: 'Loading...'
  }
})
</script>