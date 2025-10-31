<template>
  <aside class="sidebar">
    <div class="logo">
      <img src="@/assets/images/logoHome.png" alt="Logo" />
    </div>

    <nav class="menu">
      <ul>
        <li v-for="item in menuItems" :key="item.path">
          <NuxtLink
            :to="item.path"
            :class="{ active: isActive(item.path) }"
          >
            {{ item.label }}
          </NuxtLink>
        </li>
      </ul>
    </nav>

    <div class="user-box" v-if="userStore.user">
      <div class="user-info" @click.stop="toggleDropdown">
        <div class="user-avatar">
          <img src="@/assets/images/default-user-icon.jpg" alt="Avatar padrão" />
        </div>
        <div>
          <p class="user-name">{{ userStore.user?.name }}</p>
          <p class="user-email">{{ userStore.user?.email }}</p>

        </div>
      </div>

      <!-- Dropdown -->
      <UserDropdown
        v-if="showDropdown"
        @logout="handleLogout"
        @open-profile="showProfileModal = true"
      />

      <UserProfileModal 
      v-if="showProfileModal" 
      :user="userStore.user"
      @close="showProfileModal = false" />

    </div>
  </aside>
</template>

<script setup lang="ts">
import { useRoute } from 'vue-router'
import { ref, onMounted, onUnmounted } from 'vue'
import { getCurrentUser } from '@/services/auth.services'
import UserDropdown from '@/components/UserDropdown.vue'
import UserProfileModal from '@/components/UserProfileModal.vue'
import { useUserStore } from '@/stores/user'


const showProfileModal = ref(false)
const userStore = useUserStore()

export interface User {
  id: number
  name: string
  email: string
  nif: string
  phone?: string | null
  is_staff: boolean
  is_active: boolean
  creation_date: string
}

const route = useRoute()


const menuItems = [
  { label: 'Home', path: '/inicio' },
  { label: 'Chamados', path: '/tasks' },
  { label: 'Técnicos', path: '/tecnicos' },
  { label: 'Clientes', path: '/clientes' },
  { label: 'Monitoramento', path: '/monitoramento' },
  { label: 'Ativos', path: '/ativos' },
  { label: 'Ambientes', path: '/ambientes' },
  { label: 'Documentação', path: '/documentacao' },
]


const showDropdown = ref(false)

function toggleDropdown() {
  showDropdown.value = !showDropdown.value
}

function closeDropdown() {
  showDropdown.value = false
}

onMounted(async () => {
  window.addEventListener('click', closeDropdown)

  try {
    await userStore.fetchUser()
  } catch (error: any) {
    console.error('Erro ao carregar usuário:', error)
  }
})


function isActive(path: string) {
  // usa startsWith para considerar sub-rotas (ex: /clientes/123)
  return route.path === path || route.path.startsWith(path + '/')
}

</script>

<style scoped lang="scss">
.sidebar {
  width: 250px;
  background-color: #0d1323;
  display: flex;
  flex-direction: column;
  justify-content: flex-start;
  padding: 30px 0;

  .logo img {
    width: 150px;
    margin-bottom: 25px;
  }

  .menu ul {
    list-style: none;
    padding: 0;

    li {
      padding: 12px 0;

      a {
        font-weight: 500;
        color: #b3b3b3;
        text-decoration: none;
        transition: color 0.3s;
        display: block;

        &.active,
        &:hover {
          color: #1e40af;
        }
      }
    }
  }

  .user-box {
    margin-top: auto;
    display: flex;
    flex-direction: column;
    align-items: center; /* Centraliza horizontalmente */
    justify-content: center; /* Centraliza verticalmente (caso precise) */
    gap: 8px; /* Espaço entre avatar e textos */
    padding-bottom: 20px; /* Dá um respiro do fim da sidebar */
    font-size: 0.9rem;

  .user-info {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .user-avatar {
    width: 42px;
    height: 42px;
    border-radius: 50%;
    overflow: hidden;
    border: 2px solid #1e40af;
    background-color: #1e293b;
    display: flex;
    align-items: center;
    justify-content: center;

    img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
  }

  .user-name {
    font-weight: 600;
  }

  .user-email {
    color: #888;
  }
}

}
</style>
