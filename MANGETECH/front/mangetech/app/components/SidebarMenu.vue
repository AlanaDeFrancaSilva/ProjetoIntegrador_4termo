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

    <div class="user-box" v-if="user">
      <p class="user-name">{{ user.name }}</p>
      <p class="user-email">{{ user.email }}</p>
    </div>
  </aside>
</template>

<script setup lang="ts">
import { useRoute } from 'vue-router'
import { ref, onMounted } from 'vue'
import { getCurrentUser } from '@/services/auth.services'

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

const user = ref<User | null>(null)

function isActive(path: string) {
  // usa startsWith para considerar sub-rotas (ex: /clientes/123)
  return route.path === path || route.path.startsWith(path + '/')
}

onMounted(async () => {
  try {
    user.value = await getCurrentUser()
  } catch (error: any) {
    console.error('Erro ao carregar usuário:', error)
    // opcional: redirecionar para login se necessário
    // if (!localStorage.getItem('auth_token')) navigateTo('/login')
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
    font-size: 0.9rem;

    .user-name {
      font-weight: 600;
      color: #fff;
    }

    .user-email {
      color: #888;
    }
  }
}
</style>
