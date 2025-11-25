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
.sidebar {
  width: 250px;
  background: linear-gradient(180deg, #0d1323, #0a0f1c);
  display: flex;
  flex-direction: column;
  justify-content: space-between; /* 🔥 mantém menu em cima e user-info visível */
  padding: 30px 0;
  min-height: 100vh;
}


/* ===== LOGO ===== */
.logo {
  display: flex;
  justify-content: center;
  margin-bottom: 2rem;

  img {
    width: 150px;
    filter: brightness(1.15);
  }
}

/* ===== MENU ===== */
.menu ul {
  list-style: none;
  padding: 0;
  margin: 0;
}

/* ITEM DO MENU */
.menu ul li {
  margin-bottom: 6px;
}

/* LINKS DO MENU */
.menu ul li a {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 0.8rem 1rem;
  font-size: 0.95rem;
  font-weight: 500;
  color: #9ca3af;
  text-decoration: none;
  border-radius: 10px;
  position: relative;
  transition: all 0.3s ease;
}

/* efeito de luz ao passar o mouse */
.menu ul li a:hover {
  background: rgba(99, 102, 241, 0.08);
  color: #ffffff;
  transform: translateX(4px);
}

/* ITEM ATIVO */
.menu ul li a.active {
  background: linear-gradient(90deg, #3730a3, #4f46e5);
  color: white !important;
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.35);
  font-weight: 600;
}

/* ===== USER BOX ===== */
.user-box {
  margin-top: auto;
  padding: 1rem;
  background: rgba(255, 255, 255, 0.05);
  border-radius: 14px;
  display: flex;
  align-items: center;
  gap: 14px;
  cursor: pointer;
  transition: 0.3s ease;
}

.user-box:hover {
  background: rgba(255, 255, 255, 0.08);
}

/* AVATAR */
.user-avatar {
  width: 45px;
  height: 45px;
  border-radius: 50%;
  overflow: hidden;
  border: 2px solid #3b82f6;
  background-color: #1e293b;
}

.user-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

/* TEXTOS DO USUÁRIO */
.user-info {
  display: flex;
  flex-direction: column;
}

.user-name {
  font-weight: 600;
  color: #ffffff;
}

.user-email {
  font-size: 0.8rem;
  color: #94a3b8;
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
    align-items: center;
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
