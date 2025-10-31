<template>
  <div class="dropdown" @click.stop>
    <div class="header">
      <img class="avatar" src="@/assets/images/default-user-icon.jpg" />

      <button class="logout-btn" @click="$emit('logout')">
        Sair
      </button>
    </div>

    <div class="info">
      <p class="name">{{ user?.name }}</p>
      <p class="email">{{ user?.email }}</p>
    </div>

    <div class="actions">
      <button class="profile" @click="$emit('open-profile')">
        Perfil
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useUserStore } from '@/stores/user'
import { computed } from 'vue'

const userStore = useUserStore()
const user = computed(() => userStore.user)
defineEmits(['logout', 'open-profile'])

</script>

<style scoped>
.dropdown {
  position: absolute;
  bottom: 80px;
  background: #1e293b;
  padding: 14px;
  width: 220px;
  border-radius: 10px;
  box-shadow: 0 2px 8px rgba(0,0,0,.3);
  color: white;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.avatar {
  width: 55px;
  height: 55px;
  border-radius: 50%;
  border: 3px solid #1e40af;
}

.logout-btn {
  background: #dc2626;
  color: white;
  padding: 6px 10px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}
.logout-btn:hover {
  opacity: 0.85;
}

.info {
  margin-top: 10px;
}

.email {
  font-size: .8rem;
  color: #94a3b8;
}

.actions {
  margin-top: 12px;
  border-top: 1px solid #334155;
  padding-top: 10px;
  text-align: center;
}

.profile {
  background: #1e40af;
  border: none;
  padding: 6px 12px;
  border-radius: 6px;
  cursor: pointer;
  color: white;
}
.profile:hover {
  opacity: .85;
}
</style>
