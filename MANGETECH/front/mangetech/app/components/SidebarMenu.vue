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
            :class="{ active: route.path === item.path }"
          >
            {{ item.label }}
          </NuxtLink>
        </li>
      </ul>
    </nav>

    <div class="user-box">
      <p class="user-name">Usuário Adm</p>
      <p class="user-email">user@cagesystems.com</p>
    </div>
  </aside>
</template>

<script setup>
import { useRoute } from 'vue-router'

const route = useRoute()

// Defina aqui suas rotas
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
    }

    .user-email {
      color: #888;
    }
  }
}
</style>
