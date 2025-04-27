<template>
  <nav class="bg-red-700 text-white p-3 flex justify-between items-center font-sans">
    <div class="flex items-center w-full mx-auto">
      <a href="/" class="mr-0">
        <img
          src="https://assets.manutd.com/AssetPicker/images/0/0/3/2/197240/Header-Logo1500994616801.png"
          alt="Manchester United Club Crest"
          class="w-16 h-16"
        />
      </a>
      <div class="flex flex-col gap-1 cursor-pointer md:hidden" @click="toggleMenu">
        <span class="w-6 h-1 bg-white rounded"></span>
        <span class="w-6 h-1 bg-white rounded"></span>
        <span class="w-6 h-1 bg-white rounded"></span>
      </div>
      <ul :class="[ 
        'list-none flex gap-1', 
        menuOpen ? 'flex flex-col absolute top-20 left-0 w-full bg-red-700 p-5' : 'hidden md:flex justify-start w-full'
      ]">
        <li v-for="item in navItems" :key="item.text">
          <a :href="item.href" class="text-white font-semibold ml-2 py-2 px-4 rounded hover:bg-yellow-500 block">
            {{ item.text }}
          </a>
        </li>
      </ul>
    </div>
  </nav>
</template>

<script setup>
import { ref } from 'vue'

// ナビゲーション項目の配列を定義
const navItems = [
  { href: '/', text: 'Home' },
  { href: '/matches', text: 'Matches' },
  { href: '/news', text: 'News' },
  { href: '/transfer', text: 'Transfer' },
  { href: '/team', text: 'Team' },
  { href: '/injury', text: 'Injury Report' },
]

const menuOpen = ref(false)

const toggleMenu = () => {
  menuOpen.value = !menuOpen.value
}
</script>
