<template>
  <nav class="navbar">
    <div class="navbar-container">
      <a href="/" class="logo">
        <img src="https://assets.manutd.com/AssetPicker/images/0/0/3/2/197240/Header-Logo1500994616801.png" alt="Manchester United Club Crest">
      </a>
      <div class="menu-toggle" @click="toggleMenu">
        <span class="bar"></span>
        <span class="bar"></span>
        <span class="bar"></span>
      </div>
      <ul :class="{'nav-links': true, 'active': menuOpen}">
        <li><a href="/">Home</a></li>
        <li><a href="/matches">Matches</a></li>
        <li><a href="/news">News</a></li>
        <li><a href="/team">Team</a></li>
        <li><a href="/tickets">Tickets</a></li>
        <li><a href="/store">Store</a></li>
      </ul>
      <div class="auth-links">
        <a href="/login">Login</a>
        <a href="/signup">Sign Up</a>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref } from 'vue';

const menuOpen = ref(false);

const toggleMenu = () => {
  menuOpen.value = !menuOpen.value;
};
</script>

<style scoped>
.navbar {
  background-color: #e10017;
  color: white;
  padding: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-family: Arial, sans-serif;
}

.navbar-container {
  display: flex;
  align-items: center;
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
}

.navbar .logo img {
  width: 60px;  /* デフォルトのロゴサイズ */
  height: 60px;  /* 高さ自動調整 */
}

.nav-links {
  list-style: none;
  display: flex;
  gap: 20px;
}

.nav-links li a {
  color: white;
  text-decoration: none;
  font-weight: 600;
  padding: 10px 15px;
  border-radius: 5px;
  transition: background-color 0.3s;
}

.nav-links li a:hover {
  background-color: #f0a500;
}

.auth-links {
  display: flex;
  gap: 15px;
}

.auth-links a {
  color: white;
  text-decoration: none;
  font-weight: 600;
}

.menu-toggle {
  display: none;
  flex-direction: column;
  gap: 4px;
  cursor: pointer;
}

.menu-toggle .bar {
  width: 25px;
  height: 3px;
  background-color: white;
  border-radius: 3px;
}

@media (max-width: 768px) {
  .navbar .logo img {
    width: 100px;  /* 小さいスクリーン用にロゴをさらに小さくする */
  }

  /* メニューが開いたときのアニメーション調整 */
  .nav-links.active {
    display: flex;
    opacity: 1;
    transition: opacity 0.3s ease-in-out;
  }
  .navbar-container {
    flex-direction: column;
    align-items: flex-start;
  }

  .nav-links {
    flex-direction: column;
    gap: 10px;
    width: 100%;
    padding-left: 20px;
    display: none;
    opacity: 0;
    transition: opacity 0.3s ease-in-out;
  }

  .nav-links li a {
    padding: 10px;
    width: 100%;
    text-align: left;
  }

  .auth-links {
    margin-top: 15px;
  }

  .menu-toggle {
    display: flex;
  }
}
</style>
