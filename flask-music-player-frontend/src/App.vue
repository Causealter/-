<template>
  <div id="app">
    <HeaderBar
      :brand="brand"
      :logo-src="logoSrc"
      :show-search="true"
      :placeholder="searchPlaceholder"
      :username="username"
      :avatar-src="avatarSrc"
      @search="onSearch"
      @home="onHome"
      @profile="onProfile"
      @settings="onSettings"
      @logout="onLogout"
    />

    <PlayerMain
      :playlist="playlist"
      :currentIndex="currentIndex"
      :playing="playing"
      :volume="volume"
      :liked="liked"
      @select="onSelect"
      @prev="onPrev"
      @next="onNext"
      @play="onPlay"
      @pause="onPause"
      @seek="onSeek"
      @change-volume="onChangeVolume"
      @like="onLike"
      @unlike="onUnlike"
      @shuffle="onShuffle"
      @clear="onClear"
      @add-to-queue="onAddToQueue"
      @download="onDownload"
      @share="onShare"
      @remove="onRemove"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue';
import HeaderBar from './components/HeaderBar.vue';
import PlayerMain from './components/PlayerMain.vue';

// 头部导航配置
const brand = ref('我的音乐');
const logoSrc = ref('');
const searchPlaceholder = ref('搜索歌曲、艺术家、专辑...');
const username = ref('Guest');
const avatarSrc = ref('');

// 导航事件处理
function onSearch(query) {
  console.log('搜索:', query);
  // 实现搜索逻辑
}

function onHome() {
  console.log('返回首页');
  // 实现首页导航
}

function onProfile() {
  console.log('打开个人中心');
  // 实现个人中心导航
}

function onSettings() {
  console.log('打开设置');
  // 实现设置导航
}

function onLogout() {
  console.log('退出登录');
  username.value = 'Guest';
  // 实现登出逻辑
}

// 播放器状态
const playlist = ref([
  { id: 1, title: '歌一', artist: '歌手 A', duration: 215, cover: '', album: '专辑 A' },
  { id: 2, title: '歌二', artist: '歌手 B', duration: 187, cover: '', album: '专辑 B' },
  { id: 3, title: '歌三', artist: '歌手 C', duration: 240, cover: '', album: '专辑 C' }
]);
const currentIndex = ref(0);
const playing = ref(false);
const volume = ref(0.8);
const liked = ref([]);

// 播放器事件处理
function onSelect(i) {
  if (i >= 0 && i < playlist.value.length) { 
    currentIndex.value = i; 
    playing.value = true; 
  }
}

function onPrev() {
  if (!playlist.value.length) return;
  currentIndex.value = (currentIndex.value - 1 + playlist.value.length) % playlist.value.length;
  playing.value = true;
}

function onNext() {
  if (!playlist.value.length) return;
  currentIndex.value = (currentIndex.value + 1) % playlist.value.length;
  playing.value = true;
}

function onPlay() { playing.value = true; }
function onPause() { playing.value = false; }
function onSeek(seconds) { /* 实现进度跳转 */ }
function onChangeVolume(v) { volume.value = v; }
function onLike(id) { if (!liked.value.includes(id)) liked.value.push(id); }
function onUnlike(id) { liked.value = liked.value.filter(x => x !== id); }

function onShuffle() {
  for (let i = playlist.value.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [playlist.value[i], playlist.value[j]] = [playlist.value[j], playlist.value[i]];
  }
  currentIndex.value = 0;
}

function onClear() { 
  playlist.value = []; 
  currentIndex.value = 0; 
  playing.value = false; 
}

function onAddToQueue(track) { 
  if (!track) return; 
  playlist.value.push({ ...track, id: Date.now() }); 
}

function onDownload(track) { /* 实现下载逻辑 */ }
function onShare(track) { /* 实现分享逻辑 */ }

function onRemove(idx) {
  if (idx == null) return;
  playlist.value.splice(idx, 1);
  if (currentIndex.value >= playlist.value.length) {
    currentIndex.value = Math.max(0, playlist.value.length - 1);
  }
}
</script>

<style>
#app {
  height: 100vh;
  display: flex;
  flex-direction: column;
}
</style>