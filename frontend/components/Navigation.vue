<template>
  <nav
    class="bg-red-700 text-white p-3 flex justify-between items-center font-sans fixed top-0 left-0 w-full z-50 shadow-md"
  >
    <div class="flex items-center w-full mx-auto">
      <a href="/" class="mr-0">
        <img
          src="https://assets.manutd.com/AssetPicker/images/0/0/3/2/197240/Header-Logo1500994616801.png"
          alt="Manchester United Club Crest"
          class="w-16 h-16"
        />
      </a>
      <div class="flex flex-col ml-3 gap-1 cursor-pointer md:hidden" @click="toggleMenu">
        <span v-for="index in 3" :key="index" class="w-6 h-1 bg-white rounded"></span>
      </div>
      <ul
        :class="[
          'list-none flex gap-1',
          menuOpen
            ? 'flex flex-col absolute top-20 left-0 w-full bg-red-700 p-5'
            : 'hidden md:flex justify-start w-full'
        ]"
      >
        <li v-for="item in navItems" :key="item.text">
          <nuxt-link
            :to="item.href"
            class="text-white font-semibold ml-2 py-2 px-4 rounded hover:bg-yellow-500 block"
          >
            {{ item.text }}
          </nuxt-link>
        </li>
      </ul>
    </div>
  </nav>
  <div class="h-[88px]"></div>
</template>

<script setup>
import { ref } from 'vue'

const navItems = [
  { href: '/', text: 'Home' },
  { href: '/players', text: 'Players' },
  { href: '/matches', text: 'Matches' },
  { href: '/transfers', text: 'Transfer' },
  { href: '/injury', text: 'Injury Report' },
  { href: '/stats', text: 'Stat Kings' },
  // { href: '/mvp', text: 'MVP' },
]

const menuOpen = ref(false)

const toggleMenu = () => {
  menuOpen.value = !menuOpen.value
}
</script>
