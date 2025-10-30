<template>
  <div class="dashboard-layout">
    <SidebarMenu />

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
  background-color: #ffffff;
}

.main-content {
  flex: 1;
  padding: 40px;
  background-color: #f8fafc;
  color: #111;
  overflow-y: auto;
}
</style>
