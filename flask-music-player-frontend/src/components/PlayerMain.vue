// ...existing code...
<template>
  <section class="player-main">
    <aside class="playlist" aria-label="歌单列表">
      <header class="playlist-header">
        <h3>歌单</h3>
        <div class="playlist-actions">
          <button class="btn" @click="$emit('shuffle')">随机</button>
          <button class="btn" @click="$emit('clear')">清空</button>
        </div>
      </header>

      <ul class="track-list">
        <li
          v-for="(t, i) in playlist"
          :key="t.id ?? i"
          :class="['track-item', { active: i === currentIndex }]"
          @click="selectTrack(i)"
          role="button"
          tabindex="0"
          @keydown.enter="selectTrack(i)"
        >
          <img v-if="t.cover" :src="t.cover" alt="" class="thumb" />
          <div class="meta">
            <div class="title">{{ t.title || '未知曲目' }}</div>
            <div class="sub">{{ t.artist || '未知歌手' }}</div>
          </div>
          <div class="duration">{{ formatTime(t.duration) }}</div>
        </li>
        <li v-if="!playlist || playlist.length === 0" class="empty">歌单为空</li>
      </ul>
    </aside>

    <main class="player-detail" aria-live="polite">
      <div class="now-playing">
        <div class="cover-wrap">
          <img v-if="currentTrack?.cover" :src="currentTrack.cover" alt="封面" class="cover" />
          <div v-else class="cover placeholder">无封面</div>
        </div>

        <div class="info">
          <h4 class="now-title">{{ currentTrack?.title || '未播放' }}</h4>
          <div class="now-artist">{{ currentTrack?.artist || '—' }}</div>

          <div class="controls">
            <button class="ctl" @click="$emit('prev')" aria-label="上一首">⏮</button>
            <button class="ctl play" @click="togglePlay" :aria-pressed="playing">
              <span v-if="playing">⏸</span>
              <span v-else>▶️</span>
            </button>
            <button class="ctl" @click="$emit('next')" aria-label="下一首">⏭</button>

            <button class="ctl" @click="toggleLike" :class="{ liked: isLiked }" aria-label="收藏">
              ❤
            </button>
            <button class="ctl" @click="$emit('add-to-queue', currentTrack)" aria-label="加入队列">＋</button>
          </div>

          <div class="progress" ref="progressBar" @click="seekByClick" aria-label="播放进度">
            <div class="progress-track">
              <div class="progress-filled" :style="{ width: progressPercent + '%' }"></div>
            </div>
            <div class="time">
              <span>{{ formatTime(currentTime) }}</span>
              <span>{{ formatTime(currentTrack?.duration || 0) }}</span>
            </div>
          </div>

          <div class="volume-row">
            <input type="range" min="0" max="1" step="0.01" v-model.number="localVolume" @input="onVolume" aria-label="音量" />
            <span class="vol-label">{{ Math.round(localVolume * 100) }}%</span>
          </div>
        </div>
      </div>

      <section class="detail-extra">
        <h5>更多信息</h5>
        <p class="desc">{{ currentTrack?.album || '专辑信息空' }}</p>
        <div class="actions-row">
          <button class="btn" @click="$emit('download', currentTrack)">下载</button>
          <button class="btn" @click="$emit('share', currentTrack)">分享</button>
          <button class="btn" @click="$emit('remove', currentIndex)" v-if="currentTrack">从歌单移除</button>
        </div>
      </section>
    </main>
  </section>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount } from 'vue';

const props = defineProps({
  playlist: { type: Array, default: () => [] },
  currentIndex: { type: Number, default: 0 },
  playing: { type: Boolean, default: false },
  volume: { type: Number, default: 0.8 },
  liked: { type: Array, default: () => [] } // 保存已收藏曲目 id 列表
});

const emit = defineEmits([
  'select',
  'prev',
  'next',
  'play',
  'pause',
  'toggle',
  'seek',
  'change-volume',
  'like',
  'unlike',
  'shuffle',
  'clear',
  'add-to-queue',
  'download',
  'share',
  'remove'
]);

const localVolume = ref(props.volume);
watch(() => props.volume, v => (localVolume.value = v));

function onVolume() {
  emit('change-volume', localVolume.value);
}

const currentTrack = computed(() => props.playlist[props.currentIndex] || null);
const currentTime = ref(0);
const progressBar = ref(null);
const progressPercent = computed(() => {
  const d = currentTrack.value?.duration || 0;
  if (!d) return 0;
  return Math.min(100, Math.max(0, (currentTime.value / d) * 100));
});

// 简单模拟播放进度（如果播放器由上层提供真实时间，应由上层通过 prop/事件同步）
let rafId = null;
function tick() {
  if (props.playing && currentTrack.value?.duration) {
    currentTime.value = Math.min(currentTrack.value.duration, currentTime.value + 0.5);
  }
  rafId = setTimeout(tick, 500);
}

onMounted(() => {
  rafId = setTimeout(tick, 500);
});
onBeforeUnmount(() => {
  if (rafId) clearTimeout(rafId);
});

// 当切换曲目时重置当前时间
watch(() => props.currentIndex, () => {
  currentTime.value = 0;
});

// 播放/暂停切换
function togglePlay() {
  if (props.playing) emit('pause');
  else emit('play');
  emit('toggle');
}

// 选择曲目
function selectTrack(i) {
  emit('select', i);
}

// 点击进度条按位置 seek
function seekByClick(e) {
  const el = progressBar.value;
  if (!el) return;
  const track = el.querySelector('.progress-track');
  const rect = track.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const percent = Math.max(0, Math.min(1, x / rect.width));
  const seconds = (currentTrack.value?.duration || 0) * percent;
  currentTime.value = seconds;
  emit('seek', seconds);
}

// 收藏/取消
const isLiked = computed(() => {
  const id = currentTrack.value?.id;
  return id != null && props.liked.includes(id);
});
function toggleLike() {
  const id = currentTrack.value?.id;
  if (id == null) return;
  if (isLiked.value) emit('unlike', id);
  else emit('like', id);
}

// 时间格式化
function formatTime(sec) {
  if (!sec && sec !== 0) return '--:--';
  const s = Math.floor(sec);
  const m = Math.floor(s / 60);
  const r = s % 60;
  return `${String(m).padStart(2, '0')}:${String(r).padStart(2, '0')}`;
}
</script>

<style scoped>
.player-main {
  display: flex;
  gap: 18px;
  padding: 18px;
  box-sizing: border-box;
  height: calc(100vh - 56px); /* 考虑 App.vue 顶部高度 56px */
  background: #fafafa;
}

/* 左侧歌单 */
.playlist {
  width: 300px;
  background: #fff;
  border-radius: 10px;
  border: 1px solid #ececec;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}
.playlist-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 12px 14px;
  border-bottom: 1px solid #f1f1f1;
}
.track-list {
  list-style: none;
  margin: 0;
  padding: 8px;
  overflow: auto;
  flex: 1;
}
.track-item {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 8px;
  border-radius: 6px;
  cursor: pointer;
}
.track-item:hover { background: #fbfbfd; }
.track-item.active {
  background: linear-gradient(90deg, rgba(79,172,254,0.08), rgba(0,242,254,0.04));
  border-left: 3px solid #4facfe;
}
.thumb {
  width: 48px;
  height: 48px;
  object-fit: cover;
  border-radius: 6px;
  flex-shrink: 0;
}
.meta { flex: 1; min-width: 0; }
.title {
  font-size: 14px;
  color: #111827;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.sub { font-size: 12px; color: #6b7280; margin-top: 4px; }
.duration { font-size: 12px; color: #9ca3af; margin-left: 8px; }

/* 主区域 */
.player-detail {
  flex: 1;
  display: flex;
  flex-direction: column;
}
.now-playing {
  display: flex;
  gap: 18px;
  background: #fff;
  padding: 18px;
  border-radius: 10px;
  border: 1px solid #ececec;
  align-items: center;
}
.cover-wrap { width: 220px; height: 220px; flex-shrink: 0; display: flex; align-items: center; justify-content: center; }
.cover {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 8px;
}
.cover.placeholder {
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg,#f3f6ff,#eef7ff);
  display: flex;
  align-items: center;
  justify-content: center;
  color: #7b8cbf;
  border-radius: 8px;
  font-size: 14px;
}

.info { flex: 1; display: flex; flex-direction: column; gap: 12px; }
.now-title { margin: 0; font-size: 20px; color: #0f172a; }
.now-artist { font-size: 14px; color: #475569; }

/* 控件 */
.controls { display: flex; gap: 8px; align-items: center; }
.ctl {
  background: #f3f4f6;
  border: none;
  padding: 10px;
  border-radius: 8px;
  cursor: pointer;
  font-size: 16px;
}
.ctl.play {
  background: linear-gradient(90deg,#4facfe,#00f2fe);
  color: white;
  font-weight: 700;
  padding: 10px 16px;
}
.ctl.liked { color: #ef4444; }

/* 进度条 */
.progress { display: flex; flex-direction: column; gap: 8px; margin-top: 6px; }
.progress-track {
  width: 100%;
  height: 10px;
  background: #f1f3f5;
  border-radius: 999px;
  overflow: hidden;
  position: relative;
  cursor: pointer;
}
.progress-filled {
  height: 100%;
  background: linear-gradient(90deg,#4facfe,#00f2fe);
  width: 0%;
  transition: width 160ms linear;
}
.time { display: flex; justify-content: space-between; font-size: 12px; color: #6b7280; }

/* 音量行 */
.volume-row { display: flex; align-items: center; gap: 8px; margin-top: 6px; }
.volume-row input[type="range"] { width: 160px; }
.vol-label { font-size: 12px; color: #6b7280; }

/* 额外信息 */
.detail-extra {
  margin-top: 14px;
  background: #fff;
  padding: 12px;
  border-radius: 10px;
  border: 1px solid #ececec;
}
.actions-row { display:flex; gap:8px; margin-top:10px; }
.btn { background: transparent; border:1px solid #e6e6e9; padding:6px 10px; border-radius:6px; cursor:pointer; }

/* 响应式 */
@media (max-width: 900px) {
  .cover-wrap { width: 140px; height: 140px; }
  .playlist { width: 220px; }
}
@media (max-width: 640px) {
  .player-main { flex-direction: column; height: auto; padding-bottom: 40px; }
  .playlist { width: 100%; order: 2; }
  .player-detail { order: 1; }
  .cover-wrap { width: 100%; height: 240px; }
}
</style>
// ...existing code...