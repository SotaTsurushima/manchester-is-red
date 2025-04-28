<template>
  <div class="relative min-h-screen flex flex-col items-center justify-center text-white overflow-hidden">
    <!-- 背景画像 (Parallax効果付き) -->
    <div class="absolute inset-0 bg-fixed overflow-hidden">
      <img
        src="/images/old_trafford.jpg"
        alt="Old Trafford Stadium"
        class="w-full h-full object-cover parallax-bg"
      />
      <!-- 黒のオーバーレイ -->
      <div class="absolute inset-0 bg-black opacity-60"></div>
    </div>

    <!-- コンテンツ -->
    <div class="relative z-10 p-10 text-center animate-fadeIn">
      <h1 class="text-6xl font-extrabold mb-6 drop-shadow-lg text-6xl font-[Anton] tracking-wide">
        Manchester United
      </h1>
      <p class="text-3xl font-semibold mb-6 tracking-wider">
        Theatre of Dreams
      </p>

      <!-- テキストアニメーション ("Glory Glory Man United") -->
      <div class="text-5xl font-bold mt-6 glory-text tracking-wide">
        Glory Glory Man United
      </div>
    </div>
  </div>
</template>

<style scoped>
/* フェードインアニメーション */
@keyframes fadeIn {
  0% { opacity: 0; }
  100% { opacity: 1; }
}

.animate-fadeIn {
  animation: fadeIn 2s ease-out;
}

/* Parallax効果 */
.parallax-bg {
  transform: translateY(-10%);
  animation: parallax 10s infinite alternate;
  will-change: transform;
}

@keyframes parallax {
  0% {
    transform: translateY(0%);
  }
  100% {
    transform: translateY(10%);
  }
}

/* "Glory Glory Man United" のテキストアニメーション */
@keyframes gloryTextAnim {
  0% {
    opacity: 0;
    transform: translateY(30px);
  }
  50% {
    opacity: 1;
    transform: translateY(0);
  }
  100% {
    opacity: 0;
    transform: translateY(-30px);
  }
}

.glory-text {
  animation: gloryTextAnim 5s ease-in-out infinite;
  letter-spacing: 1px;
}

/* 余白の問題を防ぐ */
body, html {
  height: 100%;
  margin: 0;
}

.relative {
  position: relative;
}

.overflow-hidden {
  overflow: hidden;
}

.parallax-bg {
  transform: translateY(-10%);
  animation: parallax 10s infinite alternate;
  will-change: transform;
  filter: brightness(1.3) contrast(1) saturate(2);
}
</style>
