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
import { useRoute, useRouter } from 'vue-router'
import { ref, computed, onMounted } from 'vue'
import { getCurrentUser, logout } from '@/services/auth.services'
import UserDropdown from '@/components/UserDropdown.vue'
import UserProfileModal from '@/components/UserProfileModal.vue'
import { useUserStore } from '@/stores/user'

const showProfileModal = ref(false)
const showDropdown = ref(false)
const userStore = useUserStore()
const router = useRouter()
const route = useRoute()

// Funções de controle de dropdown
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

// Verifica se a rota está ativa
function isActive(path: string) {
  return route.path === path || route.path.startsWith(path + '/')
}

// Função de logout
async function handleLogout() {
  try {
    await logout()
    localStorage.removeItem('auth_token')
    userStore.setUser(null)
    router.push('/login')
  } catch (err) {
    console.error('Erro ao sair:', err)
  }
}

// Base de itens do menu
const baseMenu = [
  { label: 'Home', path: '/inicio' },
  { label: 'Chamados', path: '/tasks' },
  { label: 'Técnicos', path: '/tecnico' },
  { label: 'Clientes', path: '/clientes' },
  { label: 'Monitoramento', path: '/monitoramento' },
  { label: 'Ativos', path: '/ativos' },
  { label: 'Ambientes', path: '/ambientes' },
  { label: 'Documentação', path: '/documentacao' },
]

// Itens do menu filtrados por nível de acesso
const menuItems = computed(() => {
  const user = userStore.user
  if (!user) return []

  const group = user.groups?.[0]

  if (group === 'ADMIN') return baseMenu
  if (group === 'Técnico') {
    return baseMenu.filter(item =>
      ['Home', 'Chamados', 'Monitoramento', 'Documentação'].includes(item.label)
    )
  }
  if (group === 'Cliente') {
    return baseMenu.filter(item =>
      ['Home', 'Chamados', 'Ativos', 'Ambientes', 'Documentação'].includes(item.label)
    )
  }

  return baseMenu.filter(item => item.label === 'Home') // fallback (sem grupo reconhecido)
})

onMounted(async () => {
  window.addEventListener('click', closeDropdown)

  try {
    await userStore.fetchUser()
    console.log('Usuário carregado:', userStore.user)
    console.log('Grupo:', userStore.user?.groups)
  } catch (error: any) {
    console.error('Erro ao carregar usuário:', error)
  }
})

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
