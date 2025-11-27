<template>
  <div class="dashboard-layout">
    
    <!-- Sidebar fixo -->
    <SidebarMenu />

    <!-- Conteúdo -->
    <main class="main-content">
      <slot />
    </main>

  </div>
</template>

<script setup>
import SidebarMenu from '@/components/SidebarMenu.vue'
</script>

<style scoped lang="scss">
.dashboard-layout {
  display: flex;
  min-height: 100vh;
  width: 100%;
  background-color: #f4f6f9;
}

/* ====== ÁREA DE CONTEÚDO ====== */
.main-content {
  flex: 1;
  padding: 2.5rem 3rem;
  background-color: #f4f6f9;
  color: #111;
  overflow-y: visible;
  display: flex;
  flex-direction: column;

  /* 🧠 Para centralizar conteúdo leve e ajudar telas vazias */
  min-height: calc(100vh - 0px);
}

/* 🔹 Ajuste para telas menores */
@media (max-width: 1024px) {
  .main-content {
    padding: 2rem;
  }
}

@media (max-width: 768px) {
  .dashboard-layout {
    flex-direction: column;
  }

  .main-content {
    padding: 1.5rem;
  }
}
</style>
