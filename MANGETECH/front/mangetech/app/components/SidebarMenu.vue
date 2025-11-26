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
  { label: 'Ativos', path: '/equipments' },
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
/* ======= SIDEBAR DESIGN PREMIUM ======= */
/* ======= SIDEBAR PREMIUM ======= */
.sidebar {
  width: 250px;
  background: linear-gradient(180deg, #0b0f1a, #0d1224); /* 🔥 Mais elegante */
  display: flex;
  flex-direction: column;
  padding: 32px 0;
  min-height: 100vh;
  box-shadow: 4px 0 18px rgba(0, 0, 0, 0.35); /* Sombra lateral premium */
}

/* ===== LOGO ===== */
.logo {
  display: flex;
  justify-content: center;
  margin-bottom: 2.2rem;

  img {
    width: 160px;
    filter: brightness(1.2);
  }
}

/* ===== MENU ===== */
.menu ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

.menu ul li {
  margin-bottom: 8px;
}

.menu ul li a {
  display: block;
  padding: 0.85rem 1rem;
  font-size: 0.95rem;
  font-weight: 500;
  color: #a7b3c9;
  text-decoration: none;
  border-radius: 12px;
  transition: all 0.3s ease;
}

/* Hover elegante */
.menu ul li a:hover {
  background: rgba(88, 92, 255, 0.1);
  color: white;
  transform: translateX(6px);
}

/* Ativo */
.menu ul li a.active {
  background: linear-gradient(90deg, #3740a3, #4e52d9);
  color: white !important;
  box-shadow: 0 4px 16px rgba(78, 82, 217, 0.45);
}

/* ===== USER BOX ===== */
.user-box {
  margin-top: auto;
  padding: 0.8rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 14px;
  display: flex;
  align-items: center;
  gap: 14px;
  cursor: pointer;
  transition: 0.3s ease;
  margin: 0 1rem;
}

/* Hover mais refinado */
.user-box:hover {
  background: rgba(255, 255, 255, 0.08);
  box-shadow: 0 2px 10px rgba(0,0,0,0.35);
}

/* Avatar */
.user-avatar {
  width: 48px;
  height: 48px;
  border-radius: 50%;
  overflow: hidden;
  border: 2px solid #1f2937;
  background: transparent; /* 🔥 remove fundo cinza total */
}

.user-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  filter: none; /* Sem filtros cinzas */
}

/* Informações do usuário */
.user-info {
  display: flex;
  flex-direction: column;
  line-height: 1.2;
}

.user-name {
  font-weight: 600;
  color: #ffffff;
  font-size: 0.95rem;
}

.user-email {
  font-size: 0.8rem;
  color: #9ca3af;
}

/* ===== RESPONSIVIDADE ===== */
@media (max-width: 900px) {
  .sidebar {
    width: 220px;
  }

  .menu ul li a {
    font-size: 0.9rem;
    padding: 0.7rem;
  }
}

@media (max-width: 600px) {
  .sidebar {
    width: 100%;
    min-height: auto;
    flex-direction: row;
    justify-content: space-between;
    padding: 0.8rem 1rem;
  }

  .menu ul {
    display: flex;
    gap: 14px;
  }

  .user-box {
    margin-top: 0;
    padding: 0.5rem;
  }
}

</style>
