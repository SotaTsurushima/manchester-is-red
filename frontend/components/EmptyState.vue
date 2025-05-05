<template>
  <div class="text-center py-12">
    <div class="bg-white/10 rounded-lg p-8 mx-4">
      <svg
        class="mx-auto h-12 w-12 text-gray-400"
        fill="none"
        viewBox="0 0 24 24"
        stroke="currentColor"
      >
        <path
          stroke-linecap="round"
          stroke-linejoin="round"
          stroke-width="2"
          d="M19 20H5a2 2 0 01-2-2V6a2 2 0 012-2h10a2 2 0 012 2v1m2 13a2 2 0 01-2-2V7m2 13a2 2 0 002-2V9.5a2 2 0 00-2-2h-2"
        />
      </svg>
      <h3 class="mt-4 text-lg font-medium text-white">{{ title }}</h3>
      <p class="mt-2 text-gray-300">
        {{ message }}
      </p>
      <button
        v-if="buttonText && onClick"
        @click="onClick"
        class="mt-4 bg-red-600 text-white px-4 py-2 rounded hover:bg-red-700 transition-colors duration-300"
      >
        {{ buttonText }}
      </button>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: String,
  message: String,
  buttonText: String,
  onClick: Function
})
</script>
