<template>
  <nav class="navbar">
    <div class="navbar-left" @click="goHome" role="button" tabindex="0" @keydown.enter="goHome">
      <img v-if="logoSrc" :src="logoSrc" alt="logo" class="logo" />
      <span class="brand">{{ brand }}</span>
    </div>

    <div class="navbar-center" v-if="showSearch">
      <form class="search-form" @submit.prevent="submitSearch" @reset.prevent="clearSearch">
        <input
          ref="searchInput"
          v-model="query"
          type="search"
          class="search-input"
          :placeholder="placeholder"
          @input="onInput"
          aria-label="搜索"
        />
        <button type="submit" class="btn-search" aria-label="搜索按钮">🔍</button>
        <button v-if="query" type="reset" class="btn-clear" aria-label="清除搜索">✖</button>
      </form>
    </div>

    <div class="navbar-right">
      <div class="user" @click="toggleMenu" ref="menuBtn" :aria-expanded="menuOpen.toString()" role="button" tabindex="0" @keydown.enter="toggleMenu">
        <img v-if="avatarSrc" :src="avatarSrc" alt="avatar" class="avatar" />
        <div v-else class="avatar placeholder">{{ initials }}</div>
        <span class="username" v-if="username">{{ username }}</span>
      </div>

      <div v-if="menuOpen" class="dropdown" ref="menu" role="menu">
        <button class="dropdown-item" @click="onProfile" role="menuitem">个人中心</button>
        <button class="dropdown-item" @click="onSettings" role="menuitem">设置</button>
        <div class="dropdown-divider"></div>
        <button class="dropdown-item danger" @click="onLogout" role="menuitem">退出登录</button>
      </div>
    </div>
  </nav>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue';

const props = defineProps({
  brand: { type: String, default: 'My Music' },
  logoSrc: { type: String, default: '' },
  showSearch: { type: Boolean, default: true },
  placeholder: { type: String, default: 'Search songs, artists, albums...' },
  username: { type: String, default: 'Guest' },
  avatarSrc: { type: String, default: '' }
});

const emit = defineEmits(['search', 'profile', 'settings', 'logout', 'home']);

const query = ref('');
const menuOpen = ref(false);
const menu = ref(null);
const menuBtn = ref(null);
const searchInput = ref(null);

function onInput() {
  emit('search', query.value);
}

function submitSearch() {
  emit('search', query.value.trim());
}

function clearSearch() {
  query.value = '';
  searchInput.value?.focus();
  emit('search', '');
}

function goHome() {
  emit('home');
}

function toggleMenu() {
  if (!props.username || props.username === 'Guest') {
    menuOpen.value = false;
    return;
  }
  menuOpen.value = !menuOpen.value;
}

function onProfile() {
  menuOpen.value = false;
  emit('profile');
}

function onSettings() {
  menuOpen.value = false;
  emit('settings');
}

function onLogout() {
  menuOpen.value = false;
  emit('logout');
}

function onDocClick(e) {
  const m = menu.value;
  const btn = menuBtn.value;
  if (!m || !btn) return;
  if (m.contains(e.target) || btn.contains(e.target)) return;
  menuOpen.value = false;
}

function onKeydown(e) {
  if (e.key === 'Escape') menuOpen.value = false;
}

onMounted(() => {
  document.addEventListener('click', onDocClick);
  document.addEventListener('keydown', onKeydown);
});

onBeforeUnmount(() => {
  document.removeEventListener('click', onDocClick);
  document.removeEventListener('keydown', onKeydown);
});

const initials = computed(() => {
  const name = props.username || '';
  return name
    .split(' ')
    .map(s => s.charAt(0).toUpperCase())
    .slice(0, 2)
    .join('');
});
</script>

<style scoped>
.navbar {
  height: 56px;
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 0 16px;
  background: #ffffff;
  border-bottom: 1px solid #e6e6e6;
  box-sizing: border-box;
  user-select: none;
}

/* left */
.navbar-left {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}
.logo { width: 36px; height: 36px; object-fit: contain; }
.brand { font-weight: 600; color: #111827; font-size: 16px; }

/* center - search */
.navbar-center { flex: 1; display: flex; justify-content: center; }
.search-form {
  display: flex;
  align-items: center;
  width: 100%;
  max-width: 640px;
  background: #f7f7f8;
  border-radius: 22px;
  padding: 6px 8px;
  box-shadow: inset 0 1px 0 rgba(255,255,255,0.6);
}
.search-input { flex: 1; border: none; outline: none; background: transparent; padding: 6px 10px; font-size: 14px; color: #111; }
.btn-search, .btn-clear { background: transparent; border: none; padding: 6px 8px; cursor: pointer; font-size: 14px; color: #666; }
.btn-clear { font-weight: 600; }

/* right - user */
.navbar-right { display: flex; align-items: center; position: relative; }
.user { display: flex; align-items: center; gap: 8px; cursor: pointer; }
.avatar { width: 36px; height: 36px; border-radius: 50%; object-fit: cover; border: 1px solid rgba(0,0,0,0.06); }
.avatar.placeholder { display: inline-flex; align-items: center; justify-content: center; background: linear-gradient(135deg,#dfe7ff,#f0f6ff); color: #314e9c; font-weight: 700; }
.username { font-size: 14px; color: #222; }

/* dropdown */
.dropdown {
  position: absolute;
  right: 0;
  top: calc(100% + 8px);
  min-width: 160px;
  background: #fff;
  border: 1px solid #e8e8ee;
  border-radius: 8px;
  box-shadow: 0 8px 20px rgba(12,20,40,0.08);
  padding: 6px 6px;
  z-index: 60;
}
.dropdown-item { width: 100%; text-align: left; padding: 8px 12px; border: none; background: transparent; cursor: pointer; font-size: 14px; color: #222; }
.dropdown-item:hover { background: #f5f7fb; border-radius: 6px; }
.dropdown-divider { height: 1px; background: #f1f2f6; margin: 6px 0; }
.danger { color: #b91c1c; }
</style>